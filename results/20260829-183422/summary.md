# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 24911 | 0.26 | 0.66 | 2.98 | 2.52–3.38 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 2651 | 3.03 | 7.34 | 13.08 | 12.83–13.94 | 2.54 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 23050 | 0.26 | 0.77 | 3.28 | 3.20–3.55 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 1991 | 4.20 | 9.38 | 16.56 | 15.08–17.29 | 3.56 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 23391 | 0.26 | 0.73 | 3.48 | 2.63–3.51 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 1961 | 4.04 | 10.09 | 16.93 | 16.44–17.61 | 3.30 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 3547 | 2.35 | 5.27 | 8.80 | 8.46–8.90 |  |  | 2.09 |
| gomodel | chat/stream | 100000/0 | 1444 | 6.22 | 11.67 | 18.27 | 17.08–18.66 | 5.90 | 0.00 | 3.19 |
| gomodel | responses/nonstream | 100000/0 | 2377 | 3.43 | 7.81 | 16.61 | 15.54–18.08 |  |  | 3.17 |
| gomodel | responses/stream | 100000/0 | 1424 | 6.30 | 11.88 | 19.42 | 18.36–20.43 | 5.99 | 0.00 | 2.10 |
| gomodel | messages/nonstream | 100000/0 | 3553 | 2.35 | 5.26 | 8.66 | 8.48–8.92 |  |  | 2.09 |
| gomodel | messages/stream | 100000/0 | 839 | 11.03 | 19.50 | 29.00 | 28.47–30.06 | 9.67 | 0.00 | 6.99 |
| litellm | chat/nonstream | 68153/0 | 235 | 42.44 | 53.51 | 61.93 | 57.35–74.24 |  |  | 42.18 |
| litellm | chat/stream | 17786/0 | 59 | 166.32 | 239.49 | 276.84 | 221.10–344.51 | 166.30 | 0.00 | 163.29 |
| litellm | responses/nonstream | 64773/0 | 222 | 48.93 | 57.85 | 68.04 | 57.73–77.88 |  |  | 48.67 |
| litellm | responses/stream | 43899/0 | 146 | 67.07 | 79.08 | 92.25 | 88.97–99.52 | 67.05 | 0.00 | 62.87 |
| litellm | messages/nonstream | 55783/0 | 193 | 51.87 | 58.57 | 67.15 | 63.77–96.08 |  |  | 51.61 |
| litellm | messages/stream | 36048/0 | 121 | 77.06 | 102.95 | 114.95 | 100.64–151.12 | 32.65 | 0.84 | 73.02 |
| portkey | chat/nonstream | 100000/0 | 836 | 9.87 | 16.22 | 32.14 | 31.89–32.42 |  |  | 9.61 |
| portkey | chat/stream | 100000/0 | 338 | 28.56 | 32.97 | 47.07 | 46.64–48.61 | 28.54 | 0.00 | 25.53 |
| portkey | responses/nonstream | 100000/0 | 876 | 9.88 | 14.73 | 29.82 | 29.41–31.00 |  |  | 9.62 |
| portkey | responses/stream | 100000/0 | 337 | 28.65 | 32.98 | 46.12 | 45.90–47.41 | 28.62 | 0.00 | 24.45 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 1941 | 3.82 | 10.70 | 27.80 | 24.92–32.77 |  |  | 3.56 |
| bifrost | chat/stream | 100000/0 | 526 | 17.99 | 28.86 | 42.28 | 40.66–42.53 | 14.80 | 0.02 | 14.96 |
| bifrost | responses/nonstream | 100000/0 | 1946 | 3.70 | 10.72 | 28.72 | 26.65–30.94 |  |  | 3.44 |
| bifrost | responses/stream | 24850/50 | 83 | 20.07 | 33.98 | 55.18 | 52.68–57.92 | 17.35 | 0.02 | 15.87 |
| bifrost | messages/nonstream | 100000/0 | 1755 | 3.86 | 11.83 | 36.24 | 30.97–38.13 |  |  | 3.60 |
| bifrost | messages/stream | 0/50 | 0 | — | — | — | — | — | — | — |
| tensorzero | chat/nonstream | 60166/0 | 201 | 49.97 | 50.27 | 60.15 | 60.13–60.17 |  |  | 49.71 |
| tensorzero | chat/stream | 97373/0 | 325 | 46.84 | 50.29 | 60.18 | 60.14–60.19 | 1.74 | 0.00 | 43.81 |
| tensorzero | responses/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | responses/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| tensorzero | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| omniroute | chat/nonstream | 15275/0 | 51 | 186.63 | 236.11 | 456.23 | 432.07–501.45 |  |  | 186.37 |
| omniroute | chat/stream | 12667/0 | 42 | 229.63 | 279.07 | 539.60 | 490.09–588.57 | 215.61 | 0.00 | 226.60 |
| omniroute | responses/nonstream | 14828/0 | 49 | 193.88 | 242.37 | 504.14 | 429.72–517.92 |  |  | 193.62 |
| omniroute | responses/stream | 11532/0 | 39 | 253.81 | 282.59 | 543.98 | 523.91–590.63 | 244.25 | 0.00 | 249.61 |
| omniroute | messages/nonstream | 14742/0 | 49 | 194.08 | 245.16 | 479.08 | 431.05–539.99 |  |  | 193.82 |
| omniroute | messages/stream | 11541/0 | 38 | 252.32 | 284.05 | 559.46 | 549.93–584.58 | 242.90 | 0.00 | 248.28 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13052 | 18400 | 23611 | 24012 | 24483 | 24899 | 23879 | 24486 | 22207 | 24899 | 32 | 8 |
| gomodel | 2140 | 2906 | 3459 | 3590 | 3610 | 3575 | 3403 | 3231 | 2962 | 3610 | 16 | 4 |
| litellm | 189 | 228 | 234 | 240 | 212 | 250 | 234 | 235 | 242 | 250 | 32 | 8 |
| portkey | 625 | 867 | 907 | 898 | 877 | 890 | 851 | 831 | 822 | 907 | 4 | 2 |
| bifrost | 1401 | 1925 | 1982 | 1992 | 1987 | 1978 | 1951 | 1917 | 1981 | 1992 | 8 | 2 |
| tensorzero | 20 | 40 | 80 | 159 | 315 | 637 | 1273 | 2561 | 4498 | 4498 | 256 | 256 |
| omniroute | 44 | 50 | 49 | 53 | 50 | 52 | 52 | 48 | 42 | 53 | 8 | 8 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 14.4 | 39.2 | 0.58 | 42.7 | 24.8 | 100.1 | 3653 | 36.5 |
| litellm | 353.9 | 1133.8 | 31.25 | 2172.9 | 2172.9 | 101.4 | 198 | 2.0 |
| portkey | 57.9 | 177.4 | 2.17 | 123.9 | 115.2 | 117.1 | 892 | 7.6 |
| bifrost | 81.6 | 247.7 | 8.67 | 275.8 | 201.2 | 130.8 | 1924 | 14.7 |
| tensorzero | 88.0 | 246.9 | 0.58 | 105.2 | 80.6 | 10.0 | 198 | 19.8 |
| omniroute | 1182.3 | 3950.2 | 6.41 | 934.9 | 936.1 | 107.7 | 45 | 0.4 |
