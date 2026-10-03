# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 25626 | 0.26 | 0.60 | 2.90 | 2.55–3.23 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 4311 | 2.02 | 3.90 | 6.96 | 6.57–7.37 | 1.82 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 25006 | 0.28 | 0.64 | 3.18 | 2.38–3.37 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 3476 | 2.50 | 4.82 | 8.21 | 8.05–9.10 | 2.24 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 25247 | 0.28 | 0.63 | 2.75 | 2.52–3.62 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 3309 | 2.67 | 5.04 | 8.32 | 8.27–9.20 | 2.35 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 4005 | 2.22 | 4.12 | 6.88 | 6.65–7.11 |  |  | 1.96 |
| gomodel | chat/stream | 100000/0 | 1645 | 5.56 | 9.64 | 14.00 | 13.55–14.34 | 4.95 | 0.00 | 3.54 |
| gomodel | responses/nonstream | 100000/0 | 2834 | 3.10 | 6.02 | 10.14 | 9.79–10.37 |  |  | 2.82 |
| gomodel | responses/stream | 100000/0 | 1485 | 6.22 | 10.49 | 15.61 | 15.34–16.11 | 5.49 | 0.00 | 3.72 |
| gomodel | messages/nonstream | 100000/0 | 4076 | 2.18 | 4.03 | 6.59 | 6.52–6.76 |  |  | 1.90 |
| gomodel | messages/stream | 100000/0 | 1152 | 8.00 | 13.72 | 19.53 | 19.28–19.65 | 7.00 | 0.00 | 5.33 |
| litellm | chat/nonstream | 55228/0 | 176 | 55.76 | 59.04 | 66.60 | 65.71–89.32 |  |  | 55.50 |
| litellm | chat/stream | 16476/0 | 57 | 174.68 | 254.15 | 296.17 | 259.28–670.53 | 105.34 | 0.00 | 172.66 |
| litellm | responses/nonstream | 56792/0 | 176 | 56.32 | 59.38 | 64.85 | 62.04–78.55 |  |  | 56.04 |
| litellm | responses/stream | 40034/0 | 132 | 76.90 | 109.79 | 125.64 | 93.56–152.68 | 76.87 | 0.00 | 74.40 |
| litellm | messages/nonstream | 53456/0 | 192 | 52.31 | 65.39 | 72.77 | 63.05–78.43 |  |  | 52.03 |
| litellm | messages/stream | 35297/0 | 118 | 79.35 | 88.75 | 98.83 | 94.12–147.40 | 40.15 | 0.86 | 76.68 |
| portkey | chat/nonstream | 100000/0 | 869 | 9.63 | 15.17 | 29.11 | 28.69–30.06 |  |  | 9.37 |
| portkey | chat/stream | 100000/0 | 349 | 27.81 | 31.05 | 43.58 | 43.10–44.11 | 27.79 | 0.00 | 25.79 |
| portkey | responses/nonstream | 100000/0 | 915 | 9.65 | 13.38 | 27.71 | 27.44–28.38 |  |  | 9.37 |
| portkey | responses/stream | 100000/0 | 349 | 27.87 | 31.11 | 43.08 | 42.02–43.83 | 27.84 | 0.00 | 25.37 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 1980 | 4.18 | 9.91 | 18.92 | 18.62–19.69 |  |  | 3.92 |
| bifrost | chat/stream | 100000/0 | 674 | 13.79 | 23.07 | 32.69 | 32.34–33.57 | 11.86 | 0.00 | 11.77 |
| bifrost | responses/nonstream | 100000/0 | 1961 | 4.25 | 9.90 | 18.65 | 18.21–19.69 |  |  | 3.97 |
| bifrost | responses/stream | 100000/0 | 589 | 15.94 | 26.20 | 37.41 | 37.19–38.16 | 14.66 | 0.00 | 13.44 |
| bifrost | messages/nonstream | 100000/0 | 1922 | 4.33 | 10.00 | 19.25 | 19.10–20.02 |  |  | 4.05 |
| bifrost | messages/stream | 100000/0 | 731 | 12.58 | 21.53 | 31.97 | 31.33–32.57 | 11.10 | 0.00 | 9.91 |
| tensorzero | chat/nonstream | 60141/0 | 201 | 49.98 | 50.13 | 60.05 | 60.04–60.06 |  |  | 49.72 |
| tensorzero | chat/stream | 100000/0 | 449 | 3.26 | 50.04 | 60.00 | 60.00–60.03 | 1.29 | 0.00 | 1.24 |
| tensorzero | responses/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | responses/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| tensorzero | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| omniroute | chat/nonstream | 19678/0 | 66 | 145.23 | 174.91 | 391.68 | 362.63–409.76 |  |  | 144.97 |
| omniroute | chat/stream | 15953/0 | 53 | 181.57 | 217.77 | 434.04 | 428.18–460.23 | 169.25 | 0.00 | 179.55 |
| omniroute | responses/nonstream | 18954/0 | 63 | 150.77 | 181.65 | 399.70 | 364.39–425.41 |  |  | 150.49 |
| omniroute | responses/stream | 14796/0 | 49 | 197.20 | 219.70 | 470.71 | 460.83–474.35 | 188.99 | 0.00 | 194.70 |
| omniroute | messages/nonstream | 18527/0 | 62 | 154.20 | 189.40 | 393.86 | 363.07–418.56 |  |  | 153.92 |
| omniroute | messages/stream | 14770/0 | 49 | 196.83 | 221.62 | 468.97 | 451.73–488.35 | 187.19 | 0.00 | 194.16 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13361 | 20021 | 26342 | 27725 | 28052 | 27918 | 26892 | 26906 | 27576 | 28052 | 16 | 8 |
| gomodel | 2164 | 3281 | 3769 | 4133 | 4382 | 4498 | 4442 | 4281 | 3856 | 4498 | 32 | 16 |
| litellm | 159 | 214 | 214 | 216 | 168 | 220 | 214 | 217 | 199 | 220 | 32 | 2 |
| portkey | 642 | 884 | 924 | 934 | 924 | 923 | 899 | 869 | 854 | 934 | 8 | 4 |
| bifrost | 1328 | 1893 | 1985 | 2045 | 2053 | 2073 | 2079 | 2061 | 1976 | 2079 | 64 | 4 |
| tensorzero | 20 | 40 | 80 | 161 | 323 | 633 | 1262 | 2552 | 4784 | 4784 | 256 | 256 |
| omniroute | 57 | 64 | 67 | 64 | 65 | 64 | 61 | 58 | 59 | 67 | 4 | 2 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 20.6 | 60.0 | 0.81 | 73.6 | 50.5 | 105.8 | 4158 | 39.3 |
| litellm | 365.0 | 1140.0 | 26.77 | 1487.9 | 1486.8 | 189.2 | 214 | 1.1 |
| portkey | 57.9 | 177.4 | 2.30 | 126.7 | 117.6 | 112.6 | 927 | 8.2 |
| bifrost | 84.8 | 255.8 | 6.50 | 289.9 | 225.7 | 133.8 | 1996 | 14.9 |
| tensorzero | 88.0 | 246.9 | 0.60 | 106.7 | 92.0 | 5.7 | 200 | 35.2 |
| omniroute | 1182.3 | 3950.2 | 6.24 | 946.7 | 954.4 | 105.7 | 60 | 0.6 |
