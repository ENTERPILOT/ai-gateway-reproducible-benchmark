# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=8000 c=10 trials=2`

_Latency = median across 2 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 16000/0 | 29812 | 0.23 | 0.47 | 2.77 | 2.51–3.04 |  |  | 0.00 |
| baseline | chat/stream | 16000/0 | 4305 | 1.94 | 4.15 | 7.21 | 7.03–7.38 | 1.60 | 0.00 | 0.00 |
| baseline | responses/nonstream | 16000/0 | 28091 | 0.26 | 0.55 | 2.33 | 2.23–2.42 |  |  | 0.00 |
| baseline | responses/stream | 16000/0 | 3339 | 2.51 | 5.41 | 9.60 | 8.71–10.48 | 1.96 | 0.00 | 0.00 |
| baseline | messages/nonstream | 16000/0 | 28368 | 0.26 | 0.51 | 2.23 | 1.89–2.57 |  |  | 0.00 |
| baseline | messages/stream | 16000/0 | 2993 | 2.83 | 6.13 | 10.02 | 9.98–10.05 | 2.20 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 16000/0 | 4636 | 1.81 | 3.92 | 6.88 | 6.76–6.99 |  |  | 1.58 |
| gomodel | chat/stream | 16000/0 | 1800 | 4.95 | 9.23 | 14.43 | 14.17–14.70 | 4.71 | 0.00 | 3.02 |
| gomodel | responses/nonstream | 16000/0 | 4238 | 2.01 | 4.16 | 7.28 | 7.24–7.31 |  |  | 1.75 |
| gomodel | responses/stream | 16000/0 | 1797 | 5.00 | 8.96 | 14.14 | 13.63–14.64 | 4.69 | 0.00 | 2.49 |
| gomodel | messages/nonstream | 16000/0 | 4770 | 1.76 | 3.78 | 6.59 | 6.52–6.66 |  |  | 1.50 |
| gomodel | messages/stream | 16000/0 | 1085 | 8.38 | 15.24 | 22.59 | 22.44–22.73 | 7.50 | 0.00 | 5.55 |
| litellm | chat/nonstream | 6462/0 | 323 | 30.56 | 33.76 | 39.26 | 39.04–39.48 |  |  | 30.33 |
| litellm | chat/stream | 1185/0 | 59 | 151.95 | 192.60 | 776.27 | 725.46–827.07 | 151.94 | 0.00 | 150.01 |
| litellm | responses/nonstream | 6095/0 | 305 | 39.12 | 43.80 | 48.60 | 39.48–57.72 |  |  | 38.87 |
| litellm | responses/stream | 4181/0 | 209 | 47.55 | 56.60 | 64.47 | 63.99–64.96 | 47.53 | 0.00 | 45.03 |
| litellm | messages/nonstream | 3798/0 | 190 | 61.06 | 88.00 | 98.12 | 87.28–108.97 |  |  | 60.81 |
| litellm | messages/stream | 4072/0 | 204 | 48.89 | 53.83 | 62.05 | 58.78–65.32 | 48.86 | 0.00 | 46.06 |
| portkey | chat/nonstream | 16000/0 | 852 | 9.70 | 17.18 | 30.54 | 30.43–30.64 |  |  | 9.46 |
| portkey | chat/stream | 6876/0 | 344 | 27.98 | 32.49 | 43.64 | 43.64–43.65 | 27.97 | 0.00 | 26.05 |
| portkey | responses/nonstream | 16000/0 | 948 | 9.07 | 13.50 | 26.92 | 26.67–27.17 |  |  | 8.81 |
| portkey | responses/stream | 6921/0 | 346 | 27.93 | 31.71 | 44.08 | 41.83–46.32 | 27.90 | 0.00 | 25.41 |
| portkey | messages/nonstream | 0/16000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/16000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 16000/0 | 2949 | 2.51 | 6.66 | 18.27 | 17.96–18.58 |  |  | 2.27 |
| bifrost | chat/stream | 15825/0 | 791 | 11.89 | 19.51 | 27.62 | 27.62–27.62 | 9.02 | 0.02 | 9.96 |
| bifrost | responses/nonstream | 16000/0 | 2920 | 2.73 | 6.54 | 16.55 | 14.96–18.14 |  |  | 2.47 |
| bifrost | responses/stream | 9900/0 | 495 | 14.94 | 25.20 | 47.99 | 47.96–48.02 | 12.87 | 0.01 | 12.43 |
| bifrost | messages/nonstream | 16000/0 | 2887 | 2.65 | 6.52 | 19.08 | 18.61–19.55 |  |  | 2.39 |
| bifrost | messages/stream | 0/0 | 0 | — | — | — | — | — | — | — |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=16 | c=128 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|
| baseline | 15510 | 29701 | 30015 | 30015 | 128 | 16 |
| gomodel | 2745 | 4928 | 4567 | 4928 | 16 | 16 |
| litellm | 227 | 324 | 254 | 324 | 16 | 16 |
| portkey | 636 | 946 | 900 | 946 | 16 | 16 |
| bifrost | 1885 | 3088 | 2904 | 3088 | 16 | 16 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | — | 47.2 | 0.56 | 54.7 | 37.0 | 92.6 | 4824 | 52.1 |
| litellm | — | 1159.9 | 25.49 | 2273.3 | 2272.3 | 101.1 | 261 | 2.6 |
| portkey | — | 177.4 | 1.05 | 124.4 | 112.0 | 116.9 | 960 | 8.2 |
| bifrost | — | 230.7 | 7.07 | 164.1 | 143.0 | 117.6 | 2977 | 25.3 |
