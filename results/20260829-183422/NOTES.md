# Notes for run 20260829-183422

First run with TensorZero and OmniRoute. c7i.large, N=20,000, c=10, 5 trials, every
gateway from its public `latest` image on 29 Aug 2026.

## Versus the previous run (20260820-183544)

- **This box was ~9% slower across the board.** The no-gateway baseline dropped from
  27.1k to 24.9k req/s (chat non-stream) and every unchanged-code path moved by about the
  same amount, so compare gateways within a run, not absolute numbers across runs.
- **GoModel 0.1.79 → 0.1.83:** p50 2.06 → 2.35 ms, peak 4,212 → 3,610 req/s — within the
  box difference. Idle RSS 60 → 43 MB.
- **Bifrost 1.6.11 → 2.0.0:** p99 19.2 → 27.8 ms (+45%) and peak 2,624 → 1,992 req/s
  (−24%) — more than the box accounts for, so 2.0.0 looks like a real tail-latency
  regression. Cold start 6.7 → 8.7 s. Still 5/6: Anthropic Messages streaming falls
  back to the idle timeout (0 completed), Responses streaming is idle-bound (~83 req/s).
- **Portkey 1.15.2 (unchanged):** within the box difference. Still 4/6 (no Messages).
- **LiteLLM 1.97.0 → 1.98.0:** p50 35.9 → 42.4 ms, chat streaming p50 143 → 166 ms;
  ~15–20%, i.e. a little beyond the box difference. RAM 2.1 GB, cold start 31 s.

## TensorZero 2026.6.0 (2/6 variants)

- Only `/openai/v1/chat/completions` (and embeddings) on the client-facing
  OpenAI-compatible surface; no Responses endpoint and no Anthropic Messages endpoint
  (verified in source and empirically, 404). Responses/Messages are recorded as failed.
- Runs with no database; observability and usage analytics off in `tensorzero.toml`.
  Cold start 0.58 s, image 88 MB, RSS ~105 MB — the lightest footprint after GoModel.
- **~45 ms per request on keep-alive connections.** The server (axum/hyper) never sets
  `TCP_NODELAY` and writes chunked responses in several segments, so on a persistent
  connection the last segment waits for the client's delayed ACK. Fresh connection:
  ~1.5 ms; second and later requests on the same connection: ~41 ms (measured with curl
  locally); on the instance p50 = 49.97 ms in all five trials with ~0.2 ms variance,
  TTFT for streaming 1.7 ms (the stall is at the end of the response). Throughput
  therefore scales linearly with connections: 20 req/s at c=1, 4,498 at c=256 — the
  "peak req/s" in the table is the top of the sweep, not a capacity ceiling. Only 10%
  CPU under load. Worth reporting upstream (`axum::serve(..).tcp_nodelay(true)`).

## OmniRoute 3.8.50 (6/6 variants)

- Next.js/Node application: 1.18 GB compressed image (3.95 GB on disk), ~935 MB RSS,
  6.4 s cold start including the provider seeding done by `bootstrap.mjs`.
- Serves Chat Completions, Responses and Anthropic Messages, all translated to chat
  completions upstream; every variant completed with zero failures.
- p50 187 ms, p99 ~460 ms at c=10, 45–53 req/s at every concurrency, CPU-bound (~108%
  of the 2 vCPUs). That is the pipeline itself (auth, routing, translation, admission
  control, per-request bookkeeping in Node).
- **Default per-provider request queue.** As shipped, every API-key provider gets a
  Bottleneck limiter (60 req/min, 350 ms minimum gap, 6 concurrent) which serializes
  traffic at ~3 req/s. Disabled with `RATE_LIMIT_AUTO_ENABLE=false` for parity (no other
  gateway throttles upstream calls). Also off: request logs, background services,
  SQLite auto-backup, file logging. Upstream on a private docker address needs
  `OMNIROUTE_ALLOW_PRIVATE_PROVIDER_URLS=true`.
- Headless setup path: `POST /api/auth/login` (INITIAL_PASSWORD) → `POST /api/provider-nodes`
  (OpenAI-compatible node with `baseUrl`) → `POST /api/providers` (connection). Model
  name is then `<node prefix>/<model>`. `OMNIROUTE_API_KEY` makes a fixed inference key
  valid without creating a key row.
- Observed locally, not in this run: a burst of client-aborted requests left it
  answering 15–30 s per request for a while before recovering.

## Harness

- Gateway contract gained optional `CHAT_PATH` / `RESPONSES_PATH` (TensorZero's paths
  are under `/openai`); readiness probe follows `CHAT_PATH`.
- Preflight: refuse to start if a selected gateway's host port already answers. A dev
  GoModel on the laptop's `:8080` had answered the probes (401) instead of the container
  during a local check.
- `run.sh`: Ctrl-C/kill after the benchmark is running leaves the instance up and
  points at `./run.sh collect` (the orchestrator was killed once during this run and
  its EXIT trap started `terraform destroy`; the destroy died before acting and
  `collect` recovered the run). Poll ceiling raised to 3 h for six gateways.
- Peak RAM is now `max(idle, under-load peak)`; several gateways reported a lower
  under-load peak than idle (GC after warm-up).
- Variants that cannot finish N=20,000 in 60 s are capped (`capped` flag in the raw
  JSON): LiteLLM, TensorZero, OmniRoute and Bifrost streaming over Responses. Their
  rps/latency columns are still valid; `ok` counts are lower.
