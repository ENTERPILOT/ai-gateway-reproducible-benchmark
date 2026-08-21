# AI gateway reproducible benchmark

One command that benchmarks **[GoModel](https://github.com/ENTERPILOT/GoModel), LiteLLM, Portkey and Bifrost**
on a fresh AWS box and records the numbers here, so the comparison can be tracked over time
instead of trusted from a blog post.

Every gateway runs from its latest public Docker image, one at a time, against the same
in-memory mock backend. The numbers are therefore **gateway overhead** (routing, translation,
streaming), not model or network latency.

<!-- history:start -->
![History chart](results/charts/history.svg)

> Moved here from the [GoModel repository](https://github.com/ENTERPILOT/GoModel)
> (`docs/2026-06-25_aws_gateway_benchmark`) on 20 August 2026. The runs from June and
> July 2026 were made with that original harness and are part of the history.

Latest run — `20260820-183544` · 2026-08-20 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | 0.1.79 | `enterpilot/gomodel:latest` | 2.06 | 7.79 | 4,212 | 60.1 | 0.76 | 14.1 | 6/6 |
| Bifrost | 1.6.11 | `maximhq/bifrost:latest` | 3.04 | 19.23 | 2,624 | 179.5 | 6.71 | 80.3 | 5/6 |
| Portkey | 1.15.2 | `portkeyai/gateway:latest` | 9.14 | 29.37 | 982 | 110.0 | 0.99 | 57.9 | 4/6 |
| LiteLLM | 1.97.0 | `litellm/litellm:main-stable` | 35.85 | 53.32 | 276 | 2,092 | 26.50 | 353.9 | 6/6 |

All 5 runs: [results/HISTORY.md](results/HISTORY.md) · machine-readable: [results/history.json](results/history.json)
<!-- history:end -->

## Run it

Needs AWS credentials (`aws sts get-caller-identity` works), Terraform ≥ 1.6, `ssh`, `rsync`
and Python 3.

```bash
git clone https://github.com/ENTERPILOT/ai-gateway-reproducible-benchmark.git
cd ai-gateway-reproducible-benchmark
./run.sh
```

That provisions a `c7i.large` (2 vCPU, 4 GiB) in `us-east-1`, runs everything (~75 min),
copies the results into `results/<timestamp>/`, regenerates the chart and tables, and
destroys the instance. Commit the new `results/` directory to publish your run.

### Pick the gateway versions

By default every gateway runs from its current public image. To benchmark specific
releases, pass the image tags you want; the versions each run actually used are recorded
in `results/<timestamp>/*_image.json` (tag, resolved version, digest) and shown in the
tables above:

```bash
GOMODEL_IMAGE=enterpilot/gomodel:0.1.79 \
LITELLM_IMAGE=litellm/litellm:v1.97.0 \
PORTKEY_IMAGE=portkeyai/gateway:1.15.2 \
BIFROST_IMAGE=maximhq/bifrost:v1.6.11 \
./run.sh
```

Those are the versions of the latest recorded run, so this command repeats it on the same
gateway releases. Use `image@sha256:…` from the `*_image.json` files for a byte-exact pin.

> **Cost:** `c7i.large` is not free tier — about `$0.09`/hour, so well under `$1` per run.
> The instance is destroyed on exit even on failure. If you pass `KEEP=1` or the teardown
> fails, destroy it yourself: `cd terraform && terraform destroy -auto-approve`.

The benchmark runs detached on the instance, so a closed laptop, a dropped SSH session or a
changed public IP does not lose the measurement. If `run.sh` itself was interrupted, re-attach
with `./run.sh collect`: it waits for the run to finish, collects and records it, and destroys
the instance.

Useful knobs (all env vars):

| Variable | Default | Meaning |
|---|---|---|
| `N` / `C` / `REPEATS` | `20000` / `10` / `5` | requests per variant, concurrency, latency trials |
| `GATEWAYS` | `gomodel litellm portkey bifrost` | subset to run |
| `GOMODEL_IMAGE`, `LITELLM_IMAGE`, `PORTKEY_IMAGE`, `BIFROST_IMAGE` | `enterpilot/gomodel:latest`, `litellm/litellm:main-stable`, `portkeyai/gateway:latest`, `maximhq/bifrost:latest` | gateway versions to benchmark (tag or digest) |
| `GOMODEL_SOURCE` | – | path to a GoModel checkout: build and benchmark that instead of the published image |
| `INSTANCE_TYPE` / `REGION` | `c7i.large` / `us-east-1` | hardware; `t2.micro` is free tier but burstable |
| `KEEP` | `0` | `1` leaves the instance running |

### Without AWS

The instance-side harness runs on any Docker host (results are then not comparable with
the AWS history, but it is the quickest way to check the setup):

```bash
cd remote
N=300 REPEATS=1 SWEEP_CONCURRENCY="1 16" ./run-on-instance.sh
python3 ../scripts/summarize.py --results-dir results
```

The gateways are published on host ports 8080, 4000, 8787 and 8089 for readiness probes;
if one is taken, override it, e.g. `GOMODEL_HOST_PORT=18080`.

## What is measured

- **Workloads:** `/v1/chat/completions`, `/v1/responses` and Anthropic `/v1/messages`,
  each streaming and non-streaming, plus a no-gateway baseline against the mock.
- **Latency:** p50/p90/p99 and TTFT for streaming, median across `REPEATS` randomized-order
  trials.
- **Capacity:** sustained req/s across a concurrency sweep (the "peak req/s" above).
- **Footprint:** compressed image size, cold start to the first HTTP 200, idle and peak RSS
  and average CPU under sustained load.
- **Parity:** retries off everywhere, GoModel's circuit breaker off, LiteLLM at its
  recommended one worker per vCPU, per-variant warm-up before measuring. Per-request
  logging is off on every gateway (GoModel's audit log and usage tracking, Bifrost's
  request logs, LiteLLM's spend logs), so the numbers are routing overhead only.

Everything specific to one gateway lives in its own folder under
[`remote/gateways/`](remote/gateways): the compose service (image, ports, environment), a
`gateway.env` describing how the harness talks to it (default image, port, model name, extra
request headers, where it serves the Anthropic Messages dialect), and any config file it
needs. The load generator and mock are in [`remote/bench-tools/`](remote/bench-tools).

### Add a gateway

1. Create `remote/gateways/<name>/` with a `compose.yml` (one service named `<name>`, in
   profile `<name>`, using `${<NAME>_IMAGE:?}` and `${<NAME>_HOST_PORT:-<port>}`), a
   `gateway.env` (copy one of the existing ones), and any config file.
2. Add `gateways/<name>/compose.yml` to the `include:` list in `remote/compose.yml`.

`run-on-instance.sh` discovers the folder, and the tables and chart pick the gateway up on
the next recorded run. `GATEWAYS="gomodel <name>" ./run.sh` runs a subset.

## Layout

```
run.sh                  orchestrator: terraform apply -> run -> collect -> record -> destroy
terraform/              one EC2 instance, SSH key, security group
remote/                 everything shipped to the instance
  compose.yml           shared mock backend + include of every gateway
  gateways/<name>/      one folder per gateway: compose.yml, gateway.env, config file
  bench-tools/          Go mock backend + load generator (one small image)
  run-on-instance.sh    the benchmark itself: latency trials, capacity sweep, footprint
scripts/summarize.py    raw JSON -> summary.json / summary.md for one run
scripts/record_run.py   copy a run into results/ and rebuild the history
scripts/build_history.py results/*/summary.json -> history.json, charts, README tables
results/                one directory per recorded run + history.json + HISTORY.md + charts
```

## Caveats

A zero-latency mock magnifies gateway differences that real model latency usually hides;
the relative ordering is what transfers, not the absolute milliseconds. Runs on the same
instance type are comparable; the chart plots only those. Older write-ups:
[June 2026 article](https://enterpilot.io/blog/benchmarking-ai-gateways-gomodel-litellm-portkey-bifrost-june-2026/).

MIT licensed.
