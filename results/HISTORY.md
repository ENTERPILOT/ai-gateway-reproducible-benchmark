# Run history

Newest first. Latency is chat/completions non-streaming, median across trials. Peak req/s comes from the capacity sweep, RAM from `docker stats` under sustained load. Raw data for each run is in the directory named after it; `history.json` holds the same numbers in machine-readable form.

![History chart](charts/history.svg)

## 2026-09-18 — 20260918-212130

`20260918-212130` · 2026-09-18 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | 0.1.94 | `enterpilot/gomodel:latest` | 2.34 | 7.19 | 4,215 | 91.8 | 1.03 | 20.6 | 6/6 |
| Bifrost | 2.2.1 | `maximhq/bifrost:latest` | 4.30 | 20.50 | 1,984 | 298.9 | 7.80 | 84.6 | 6/6 |
| Portkey † | 1.15.2 | `portkeyai/gateway:latest` | 9.87 | 32.14 | 907 | 123.9 | 2.17 | 57.9 | 4/6 |
| LiteLLM | 1.101.0 | `litellm/litellm:main-stable` | 44.05 | 67.30 | 242 | 1,352 | 22.08 | 357.9 | 6/6 |
| TensorZero † | 2026.6.0 | `tensorzero/gateway:latest` | 49.97 | 60.15 | 4,498 | 105.2 | 0.58 | 88.0 | 2/6 |
| OmniRoute | 3.8.50 | `diegosouzapw/omniroute:latest` | 170.84 | 399.48 | 56 | 1,098 | 10.76 | 1,182 | 6/6 |

† not re-measured in this run — values carried over from an earlier run on the same hardware and load: Portkey (from `20260829-183422`), TensorZero (from `20260829-183422`).

Full tables: [`20260918-212130/summary.md`](20260918-212130/summary.md)

## 2026-08-29 — 20260829-183422

`20260829-183422` · 2026-08-29 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | 0.1.83 | `enterpilot/gomodel:latest` | 2.35 | 8.80 | 3,610 | 42.7 | 0.58 | 14.4 | 6/6 |
| Bifrost | 2.0.0 | `maximhq/bifrost:latest` | 3.82 | 27.80 | 1,992 | 275.8 | 8.67 | 81.6 | 5/6 |
| Portkey | 1.15.2 | `portkeyai/gateway:latest` | 9.87 | 32.14 | 907 | 123.9 | 2.17 | 57.9 | 4/6 |
| LiteLLM | 1.98.0 | `litellm/litellm:main-stable` | 42.44 | 61.93 | 250 | 2,173 | 31.25 | 353.9 | 6/6 |
| TensorZero | 2026.6.0 | `tensorzero/gateway:latest` | 49.97 | 60.15 | 4,498 | 105.2 | 0.58 | 88.0 | 2/6 |
| OmniRoute | 3.8.50 | `diegosouzapw/omniroute:latest` | 186.63 | 456.23 | 53 | 936.1 | 6.41 | 1,182 | 6/6 |

Full tables: [`20260829-183422/summary.md`](20260829-183422/summary.md)

## 2026-08-20 — 20260820-183544

`20260820-183544` · 2026-08-20 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | 0.1.79 | `enterpilot/gomodel:latest` | 2.06 | 7.79 | 4,212 | 98.4 | 0.76 | 14.1 | 6/6 |
| Bifrost | 1.6.11 | `maximhq/bifrost:latest` | 3.04 | 19.23 | 2,624 | 220.7 | 6.71 | 80.3 | 5/6 |
| Portkey | 1.15.2 | `portkeyai/gateway:latest` | 9.14 | 29.37 | 982 | 120.1 | 0.99 | 57.9 | 4/6 |
| LiteLLM | 1.97.0 | `litellm/litellm:main-stable` | 35.85 | 53.32 | 276 | 2,092 | 26.50 | 353.9 | 6/6 |

Full tables: [`20260820-183544/summary.md`](20260820-183544/summary.md)

## 2026-07-21 — 20260721-121034

`20260721-121034` · 2026-07-21 · AWS **c7i.large** (2 vCPU) · N=20,000 per variant · c=10 · 5 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | — | `gomodel-bench:local` | 2.19 | 8.30 | 4,154 | 76.7 | 0.62 | 16.8 | 6/6 |
| Bifrost | — | `maximhq/bifrost:latest` | 3.09 | 20.85 | 2,534 | 216.3 | 5.25 | 79.0 | 5/6 |
| Portkey | — | `portkeyai/gateway:latest` | 10.13 | 32.02 | 883 | 119.7 | 1.09 | 57.9 | 4/6 |
| LiteLLM | — | `ghcr.io/berriai/litellm:main-stable` | 38.78 | 54.18 | 265 | 2,264 | 28.93 | 334.2 | 6/6 |

Full tables: [`20260721-121034/summary.md`](20260721-121034/summary.md)

## 2026-06-25 — 20260625-182538

`20260625-182538` · 2026-06-25 · AWS **c7i.large** (2 vCPU) · N=8,000 per variant · c=10 · 2 trial(s) · LiteLLM workers=2

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | — | `gomodel-bench:local` | 1.81 | 6.88 | 4,928 | 54.7 | 0.56 | — | 6/6 |
| Bifrost | — | `maximhq/bifrost:latest` | 2.51 | 18.27 | 3,088 | 164.1 | 7.07 | — | 5/6 |
| Portkey | — | `portkeyai/gateway:latest` | 9.70 | 30.54 | 946 | 124.4 | 1.05 | — | 4/6 |
| LiteLLM | — | `ghcr.io/berriai/litellm:main-stable` | 30.56 | 39.26 | 324 | 2,273 | 25.49 | — | 6/6 |

Full tables: [`20260625-182538/summary.md`](20260625-182538/summary.md)

## 2026-06-25 — 20260625-160856

`20260625-160856` · 2026-06-25 · AWS **c7i.large** (2 vCPU) · N=8,000 per variant · c=10 · 2 trial(s) · LiteLLM workers=1

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | — | `gomodel-bench:local` | 2.16 | 8.29 | 4,202 | 51.3 | 0.66 | — | 6/6 |
| Bifrost | — | `maximhq/bifrost:latest` | 2.91 | 21.01 | 2,664 | 159.0 | 6.74 | — | 5/6 |
| Portkey | — | `portkeyai/gateway:latest` | 11.39 | 35.47 | 758 | 114.2 | 1.07 | — | 4/6 |
| LiteLLM | — | `ghcr.io/berriai/litellm:main-stable` | 44.45 | 61.71 | 223 | 1,009 | 14.82 | — | 6/6 |

Full tables: [`20260625-160856/summary.md`](20260625-160856/summary.md)

## 2026-06-20 — 20260620-202320

`20260620-202320` · 2026-06-20 · AWS **t2.micro** (1 vCPU) · N=300 per variant · c=10 · 1 trial(s) · LiteLLM workers=1

| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |
|---|---|---|--:|--:|--:|--:|--:|--:|:-:|
| GoModel | — | `gomodel-bench:local` | 9.20 | 19.10 | — | 32.4 | — | — | 6/6 |
| Bifrost | — | `maximhq/bifrost:latest` | 1.12 | 223.05 | — | 266.6 | — | — | 6/6 |
| Portkey | — | `portkeyai/gateway:latest` | 38.71 | 72.77 | — | 64.9 | — | — | 4/6 |
| LiteLLM | — | `ghcr.io/berriai/litellm:main-stable` | 71.96 | 96.96 | — | 559.3 | — | — | 6/6 |

Full tables: [`20260620-202320/summary.md`](20260620-202320/summary.md)
