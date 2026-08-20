# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 22818 | 0.36 | 0.66 | 2.26 | 2.20–2.52 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 3858 | 2.14 | 4.69 | 8.33 | 7.60–8.75 | 1.78 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 23231 | 0.34 | 0.65 | 2.34 | 2.23–2.77 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 2867 | 2.91 | 6.42 | 10.93 | 9.51–11.34 | 2.28 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 22968 | 0.35 | 0.65 | 2.21 | 1.90–2.36 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 2549 | 3.31 | 7.33 | 11.92 | 10.55–12.43 | 2.53 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 3863 | 2.19 | 4.66 | 8.30 | 8.15–8.72 |  |  | 1.83 |
| gomodel | chat/stream | 100000/0 | 1582 | 5.67 | 10.30 | 16.54 | 16.24–17.11 | 5.34 | 0.00 | 3.53 |
| gomodel | responses/nonstream | 59968/0 | 200 | 44.23 | 89.40 | 143.77 | 140.29–144.89 |  |  | 43.89 |
| gomodel | responses/stream | 100000/0 | 1565 | 5.67 | 10.42 | 16.58 | 16.24–16.71 | 5.25 | 0.00 | 2.76 |
| gomodel | messages/nonstream | 100000/0 | 3929 | 2.18 | 4.53 | 7.95 | 7.70–8.09 |  |  | 1.83 |
| gomodel | messages/stream | 100000/0 | 946 | 9.64 | 17.39 | 25.56 | 25.47–26.15 | 8.61 | 0.00 | 6.33 |
| litellm | chat/nonstream | 73560/0 | 263 | 38.78 | 47.44 | 54.18 | 47.52–57.26 |  |  | 38.42 |
| litellm | chat/stream | 16060/0 | 55 | 175.25 | 223.36 | 280.60 | 234.24–322.22 | 175.23 | 0.00 | 173.11 |
| litellm | responses/nonstream | 70507/0 | 249 | 46.55 | 50.64 | 57.76 | 56.48–84.63 |  |  | 46.21 |
| litellm | responses/stream | 48660/0 | 171 | 65.36 | 76.74 | 86.92 | 74.29–108.82 | 65.32 | 0.00 | 62.45 |
| litellm | messages/nonstream | 67221/0 | 224 | 48.57 | 64.44 | 73.37 | 55.19–80.11 |  |  | 48.22 |
| litellm | messages/stream | 48527/0 | 153 | 65.35 | 73.24 | 81.73 | 71.39–92.66 | 65.32 | 0.00 | 62.04 |
| portkey | chat/nonstream | 100000/0 | 811 | 10.13 | 16.68 | 32.02 | 31.77–33.23 |  |  | 9.77 |
| portkey | chat/stream | 100000/0 | 339 | 28.29 | 32.88 | 46.70 | 46.30–47.34 | 28.27 | 0.00 | 26.15 |
| portkey | responses/nonstream | 100000/0 | 844 | 10.21 | 15.06 | 31.25 | 29.38–31.97 |  |  | 9.87 |
| portkey | responses/stream | 100000/0 | 338 | 28.49 | 33.14 | 46.62 | 45.87–48.67 | 28.46 | 0.00 | 25.58 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 2454 | 3.09 | 8.29 | 20.85 | 19.55–21.35 |  |  | 2.73 |
| bifrost | chat/stream | 100000/0 | 676 | 13.96 | 22.70 | 33.05 | 32.52–33.33 | 10.54 | 0.02 | 11.82 |
| bifrost | responses/nonstream | 100000/0 | 2381 | 3.24 | 8.16 | 20.94 | 18.40–23.69 |  |  | 2.90 |
| bifrost | responses/stream | 24850/50 | 83 | 17.21 | 28.58 | 53.09 | 49.30–56.64 | 14.62 | 0.01 | 14.30 |
| bifrost | messages/nonstream | 100000/0 | 2351 | 3.05 | 8.25 | 22.98 | 22.27–25.65 |  |  | 2.70 |
| bifrost | messages/stream | 0/50 | 0 | — | — | — | — | — | — | — |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13252 | 19707 | 24365 | 25344 | 25760 | 25940 | 26130 | 26094 | 25783 | 26130 | 64 | 8 |
| gomodel | 2424 | 3514 | 4090 | 4132 | 4154 | 4110 | 4085 | 3899 | 3445 | 4154 | 16 | 4 |
| litellm | 193 | 258 | 260 | 263 | 265 | 220 | 261 | 256 | 223 | 265 | 16 | 2 |
| portkey | 607 | 863 | 875 | 883 | 881 | 860 | 828 | 807 | 810 | 883 | 8 | 2 |
| bifrost | 1655 | 2367 | 2512 | 2528 | 2534 | 2516 | 2471 | 2475 | 2409 | 2534 | 16 | 4 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 16.8 | 50.3 | 0.62 | 76.7 | 39.7 | 94.2 | 4008 | 42.5 |
| litellm | 334.2 | 1057.1 | 28.93 | 2264.1 | 2264.1 | 187.7 | 258 | 1.4 |
| portkey | 57.9 | 177.4 | 1.09 | 119.7 | 110.9 | 115.8 | 852 | 7.4 |
| bifrost | 79.0 | 243.5 | 5.25 | 216.3 | 194.6 | 119.9 | 2449 | 20.4 |
