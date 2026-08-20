# AI gateway reproducible benchmark

One command that benchmarks **[GoModel](https://github.com/ENTERPILOT/GoModel), LiteLLM, Portkey and Bifrost**
on a fresh AWS box and records the numbers here, so the comparison can be tracked over time
instead of trusted from a blog post.

Every gateway runs from its latest public Docker image, one at a time, against the same
in-memory mock backend. The numbers are therefore **gateway overhead** (routing, translation,
streaming), not model or network latency.

<!-- history:start -->
Latest run — `20260820-183544` · 2026-08-20 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | `enterpilot/gomodel:latest` | 2.06 | 7.79 | 4,212 | 60.1 | 0.76 | 14.1 | 6/6 |
| Bifrost | `maximhq/bifrost:latest` | 3.04 | 19.23 | 2,624 | 179.5 | 6.71 | 80.3 | 5/6 |
| Portkey | `portkeyai/gateway:latest` | 9.14 | 29.37 | 982 | 110.0 | 0.99 | 57.9 | 4/6 |
| LiteLLM | `litellm/litellm:main-stable` | 35.85 | 53.32 | 276 | 2,092 | 26.50 | 353.9 | 6/6 |

![History chart](results/charts/history.svg)

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
| `GOMODEL_IMAGE`, `LITELLM_IMAGE`, `PORTKEY_IMAGE`, `BIFROST_IMAGE` | `enterpilot/gomodel:latest`, `litellm/litellm:main-stable`, `portkeyai/gateway:latest`, `maximhq/bifrost:latest` | pin an image or digest |
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
  recommended one worker per vCPU, per-variant warm-up before measuring.

Gateway-specific configuration lives in [`remote/configs/`](remote/configs) and
[`remote/docker-compose.yml`](remote/docker-compose.yml); the load generator and mock are
in [`remote/bench-tools/`](remote/bench-tools).

## Layout

```
run.sh                  orchestrator: terraform apply -> run -> collect -> record -> destroy
terraform/              one EC2 instance, SSH key, security group
remote/                 everything shipped to the instance (compose file, configs, bench tools)
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
