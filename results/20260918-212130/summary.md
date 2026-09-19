# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 25450 | 0.27 | 0.59 | 3.11 | 2.71–3.32 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 4313 | 1.99 | 3.93 | 6.84 | 6.16–7.19 | 1.81 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 25143 | 0.27 | 0.62 | 2.80 | 2.47–3.17 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 3369 | 2.59 | 4.96 | 8.30 | 7.30–8.78 | 2.31 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 25397 | 0.26 | 0.59 | 2.96 | 2.86–3.38 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 3222 | 2.72 | 5.21 | 8.78 | 7.65–8.85 | 2.41 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 3749 | 2.34 | 4.55 | 7.19 | 7.10–7.65 |  |  | 2.07 |
| gomodel | chat/stream | 100000/0 | 1601 | 5.76 | 9.96 | 14.30 | 13.80–14.80 | 5.14 | 0.00 | 3.77 |
| gomodel | responses/nonstream | 100000/0 | 2670 | 3.26 | 6.47 | 10.66 | 10.43–11.31 |  |  | 2.99 |
| gomodel | responses/stream | 100000/0 | 1466 | 6.22 | 10.82 | 15.90 | 15.35–16.57 | 5.64 | 0.00 | 3.63 |
| gomodel | messages/nonstream | 100000/0 | 3825 | 2.31 | 4.37 | 7.16 | 6.86–7.81 |  |  | 2.05 |
| gomodel | messages/stream | 100000/0 | 1074 | 8.65 | 14.72 | 21.12 | 20.33–21.18 | 7.49 | 0.00 | 5.93 |
| litellm | chat/nonstream | 67934/0 | 228 | 44.05 | 57.77 | 67.30 | 54.02–78.83 |  |  | 43.78 |
| litellm | chat/stream | 17129/0 | 56 | 174.42 | 224.15 | 268.70 | 237.73–380.70 | 174.38 | 0.00 | 172.43 |
| litellm | responses/nonstream | 63371/0 | 209 | 51.74 | 65.76 | 76.07 | 59.83–101.38 |  |  | 51.47 |
| litellm | responses/stream | 41114/0 | 140 | 70.32 | 80.14 | 93.39 | 88.23–136.37 | 70.28 | 0.00 | 67.73 |
| litellm | messages/nonstream | 56188/0 | 192 | 59.96 | 76.94 | 89.61 | 69.26–115.93 |  |  | 59.70 |
| litellm | messages/stream | 34810/0 | 116 | 79.71 | 91.30 | 102.87 | 89.37–160.63 | 40.30 | 0.83 | 76.99 |
| portkey | chat/nonstream | 100000/0 | 836 | 9.87 | 16.22 | 32.14 | 31.89–32.42 |  |  | 9.60 |
| portkey | chat/stream | 100000/0 | 338 | 28.56 | 32.97 | 47.07 | 46.64–48.61 | 28.54 | 0.00 | 26.57 |
| portkey | responses/nonstream | 100000/0 | 876 | 9.88 | 14.73 | 29.82 | 29.41–31.00 |  |  | 9.61 |
| portkey | responses/stream | 100000/0 | 337 | 28.65 | 32.98 | 46.12 | 45.90–47.41 | 28.62 | 0.00 | 26.06 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 1901 | 4.30 | 10.24 | 20.50 | 18.90–20.93 |  |  | 4.03 |
| bifrost | chat/stream | 100000/0 | 602 | 15.54 | 25.83 | 37.42 | 35.55–37.92 | 12.66 | 0.00 | 13.55 |
| bifrost | responses/nonstream | 100000/0 | 1885 | 4.37 | 10.28 | 20.28 | 19.70–21.64 |  |  | 4.10 |
| bifrost | responses/stream | 100000/0 | 559 | 16.80 | 27.67 | 39.82 | 38.11–41.31 | 13.94 | 0.00 | 14.21 |
| bifrost | messages/nonstream | 100000/0 | 1875 | 4.44 | 10.38 | 20.24 | 19.76–21.22 |  |  | 4.18 |
| bifrost | messages/stream | 100000/0 | 667 | 13.54 | 24.05 | 37.55 | 36.17–38.10 | 11.61 | 0.00 | 10.82 |
| tensorzero | chat/nonstream | 60166/0 | 201 | 49.97 | 50.27 | 60.15 | 60.13–60.17 |  |  | 49.70 |
| tensorzero | chat/stream | 97373/0 | 325 | 46.84 | 50.29 | 60.18 | 60.14–60.19 | 1.74 | 0.00 | 44.85 |
| tensorzero | responses/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | responses/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| tensorzero | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| omniroute | chat/nonstream | 16548/0 | 56 | 170.84 | 217.20 | 399.48 | 347.26–449.21 |  |  | 170.57 |
| omniroute | chat/stream | 13511/0 | 45 | 211.12 | 259.59 | 496.68 | 464.98–544.23 | 200.19 | 0.00 | 209.13 |
| omniroute | responses/nonstream | 15890/0 | 54 | 177.23 | 223.93 | 460.18 | 377.14–516.63 |  |  | 176.96 |
| omniroute | responses/stream | 12337/0 | 42 | 233.80 | 264.58 | 541.03 | 500.06–572.46 | 225.78 | 0.00 | 231.21 |
| omniroute | messages/nonstream | 16010/0 | 53 | 175.97 | 225.91 | 436.54 | 395.15–493.03 |  |  | 175.71 |
| omniroute | messages/stream | 12461/0 | 42 | 234.32 | 264.60 | 560.57 | 496.34–568.80 | 226.18 | 0.00 | 231.60 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13436 | 19581 | 26152 | 27585 | 28209 | 28357 | 27366 | 26520 | 26355 | 28357 | 32 | 8 |
| gomodel | 2127 | 3198 | 3615 | 3926 | 4167 | 4215 | 4112 | 3870 | 3351 | 4215 | 32 | 16 |
| litellm | 178 | 239 | 237 | 236 | 242 | 236 | 234 | 237 | 211 | 242 | 16 | 2 |
| portkey | 625 | 867 | 907 | 898 | 877 | 890 | 851 | 831 | 822 | 907 | 4 | 2 |
| bifrost | 1287 | 1864 | 1915 | 1965 | 1984 | 1934 | 1946 | 1884 | 1875 | 1984 | 16 | 4 |
| tensorzero | 20 | 40 | 80 | 159 | 315 | 637 | 1273 | 2561 | 4498 | 4498 | 256 | 256 |
| omniroute | 47 | 51 | 53 | 53 | 53 | 56 | 52 | 48 | 50 | 56 | 32 | 4 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 20.6 | 60.2 | 1.03 | 91.8 | 53.8 | 107.7 | 3958 | 36.8 |
| litellm | 357.9 | 1119.2 | 22.08 | 1351.7 | 1350.7 | 188.1 | 228 | 1.2 |
| portkey | 57.9 | 177.4 | 2.17 | 123.9 | 115.2 | 117.1 | 892 | 7.6 |
| bifrost | 84.6 | 255.5 | 7.80 | 298.9 | 249.4 | 133.4 | 1929 | 14.5 |
| tensorzero | 88.0 | 246.9 | 0.58 | 105.2 | 80.6 | 10.0 | 198 | 19.8 |
| omniroute | 1182.3 | 3950.2 | 10.76 | 1094.7 | 1097.7 | 104.3 | 49 | 0.5 |
