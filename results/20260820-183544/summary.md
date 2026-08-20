# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 27149 | 0.23 | 0.59 | 2.96 | 2.75–3.52 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 2921 | 2.67 | 6.77 | 11.69 | 10.58–12.70 | 2.25 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 26207 | 0.23 | 0.65 | 2.98 | 2.85–3.13 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 2180 | 3.81 | 8.64 | 14.54 | 14.52–15.58 | 3.18 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 26150 | 0.22 | 0.62 | 3.01 | 2.83–3.19 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 2151 | 3.76 | 9.03 | 15.47 | 14.47–16.21 | 3.09 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 4058 | 2.06 | 4.48 | 7.79 | 7.38–7.98 |  |  | 1.83 |
| gomodel | chat/stream | 100000/0 | 1549 | 5.87 | 10.72 | 16.13 | 15.60–16.28 | 5.60 | 0.00 | 3.20 |
| gomodel | responses/nonstream | 100000/0 | 2620 | 3.02 | 7.09 | 16.23 | 15.18–18.21 |  |  | 2.79 |
| gomodel | responses/stream | 100000/0 | 1512 | 5.90 | 11.09 | 17.74 | 16.08–18.57 | 5.60 | 0.00 | 2.09 |
| gomodel | messages/nonstream | 100000/0 | 3994 | 2.09 | 4.52 | 7.81 | 7.65–8.30 |  |  | 1.87 |
| gomodel | messages/stream | 100000/0 | 935 | 9.71 | 17.67 | 27.18 | 25.73–27.44 | 8.67 | 0.00 | 5.95 |
| litellm | chat/nonstream | 80581/0 | 276 | 35.85 | 46.64 | 53.32 | 47.82–71.41 |  |  | 35.62 |
| litellm | chat/stream | 20532/0 | 69 | 142.95 | 159.23 | 193.90 | 186.00–281.78 | 142.94 | 0.00 | 140.28 |
| litellm | responses/nonstream | 79218/0 | 265 | 38.45 | 54.63 | 61.48 | 49.57–79.37 |  |  | 38.22 |
| litellm | responses/stream | 54442/0 | 185 | 55.12 | 79.09 | 90.55 | 73.93–107.29 | 55.09 | 0.00 | 51.31 |
| litellm | messages/nonstream | 68843/0 | 238 | 43.92 | 52.28 | 58.14 | 52.92–68.69 |  |  | 43.70 |
| litellm | messages/stream | 41328/0 | 138 | 50.91 | 115.49 | 126.78 | 100.88–133.13 | 18.94 | 0.85 | 47.15 |
| portkey | chat/nonstream | 100000/0 | 899 | 9.14 | 14.97 | 29.37 | 28.14–29.43 |  |  | 8.91 |
| portkey | chat/stream | 100000/0 | 347 | 27.95 | 31.66 | 44.25 | 42.87–44.45 | 27.93 | 0.00 | 25.28 |
| portkey | responses/nonstream | 100000/0 | 946 | 9.13 | 13.63 | 27.76 | 27.06–28.51 |  |  | 8.90 |
| portkey | responses/stream | 100000/0 | 347 | 27.98 | 31.59 | 44.02 | 42.94–44.07 | 27.96 | 0.00 | 24.17 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 2541 | 3.04 | 7.78 | 19.23 | 17.02–20.85 |  |  | 2.81 |
| bifrost | chat/stream | 100000/0 | 627 | 15.25 | 24.15 | 34.56 | 33.94–36.48 | 12.56 | 0.02 | 12.58 |
| bifrost | responses/nonstream | 100000/0 | 2473 | 3.13 | 7.98 | 19.88 | 19.11–22.13 |  |  | 2.90 |
| bifrost | responses/stream | 24850/50 | 83 | 17.99 | 30.01 | 48.59 | 46.27–49.69 | 15.56 | 0.02 | 14.18 |
| bifrost | messages/nonstream | 100000/0 | 2355 | 3.03 | 7.95 | 26.54 | 23.99–28.69 |  |  | 2.81 |
| bifrost | messages/stream | 0/50 | 0 | — | — | — | — | — | — | — |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 14242 | 21372 | 26307 | 27736 | 27731 | 26964 | 27799 | 27063 | 26292 | 27799 | 64 | 8 |
| gomodel | 2307 | 3529 | 4090 | 4163 | 4212 | 3992 | 3981 | 3689 | 3329 | 4212 | 16 | 4 |
| litellm | 207 | 275 | 276 | 266 | 236 | 269 | 273 | 247 | 267 | 276 | 4 | 2 |
| portkey | 686 | 952 | 955 | 982 | 970 | 946 | 950 | 884 | 887 | 982 | 8 | 2 |
| bifrost | 1690 | 2265 | 2606 | 2624 | 2582 | 2574 | 2550 | 2531 | 2554 | 2624 | 8 | 4 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 14.1 | 38.9 | 0.76 | 98.4 | 60.1 | 98.4 | 4140 | 42.1 |
| litellm | 353.9 | 1131.7 | 26.50 | 2092.0 | 2092.0 | 183.0 | 258 | 1.4 |
| portkey | 57.9 | 177.4 | 0.99 | 120.1 | 110.0 | 114.4 | 962 | 8.4 |
| bifrost | 80.3 | 247.1 | 6.71 | 220.7 | 179.5 | 119.6 | 2508 | 21.0 |
