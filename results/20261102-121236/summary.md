# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 27152 | 0.25 | 0.55 | 2.74 | 2.44–3.27 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 4445 | 1.94 | 3.80 | 6.97 | 6.55–7.35 | 1.73 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 24986 | 0.30 | 0.68 | 2.16 | 2.05–2.42 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 2734 | 3.22 | 6.12 | 9.99 | 8.81–10.17 | 2.80 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 26737 | 0.26 | 0.60 | 2.49 | 2.47–2.85 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 3479 | 2.56 | 4.75 | 7.80 | 7.61–8.03 | 2.27 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 4182 | 2.12 | 3.90 | 6.45 | 6.29–6.61 |  |  | 1.87 |
| gomodel | chat/stream | 100000/0 | 1734 | 5.33 | 9.04 | 13.13 | 12.93–13.41 | 4.26 | 0.00 | 3.39 |
| gomodel | responses/nonstream | 100000/0 | 2876 | 3.04 | 5.89 | 10.13 | 9.61–10.41 |  |  | 2.74 |
| gomodel | responses/stream | 100000/0 | 1075 | 8.71 | 14.57 | 20.91 | 20.11–21.47 | 6.80 | 0.00 | 5.49 |
| gomodel | messages/nonstream | 100000/0 | 4253 | 2.10 | 3.84 | 6.45 | 6.22–6.52 |  |  | 1.84 |
| gomodel | messages/stream | 100000/0 | 1230 | 7.58 | 12.79 | 18.44 | 17.53–18.80 | 5.73 | 0.00 | 5.02 |
| litellm | chat/nonstream | 53141/0 | 165 | 60.16 | 65.00 | 74.10 | 71.60–85.46 |  |  | 59.91 |
| litellm | chat/stream | 15933/0 | 55 | 176.60 | 271.99 | 306.43 | 230.82–375.52 | 117.41 | 0.00 | 174.66 |
| litellm | responses/nonstream | 56150/0 | 188 | 53.14 | 67.82 | 78.51 | 68.34–104.15 |  |  | 52.84 |
| litellm | responses/stream | 27201/0 | 91 | 110.48 | 145.72 | 175.99 | 170.07–178.14 | 110.42 | 0.00 | 107.26 |
| litellm | messages/nonstream | 49556/0 | 165 | 74.55 | 99.93 | 111.05 | 78.03–115.32 |  |  | 74.29 |
| litellm | messages/stream | 21291/0 | 70 | 144.09 | 205.10 | 238.96 | 226.59–247.54 | 37.30 | 1.33 | 141.53 |
| portkey | chat/nonstream | 100000/0 | 888 | 9.36 | 15.12 | 29.50 | 28.26–30.19 |  |  | 9.11 |
| portkey | chat/stream | 100000/0 | 349 | 27.84 | 31.33 | 43.23 | 42.88–44.05 | 27.82 | 0.00 | 25.90 |
| portkey | responses/nonstream | 100000/0 | 921 | 9.48 | 13.87 | 27.32 | 27.26–28.61 |  |  | 9.18 |
| portkey | responses/stream | 100000/0 | 342 | 28.31 | 32.32 | 44.82 | 43.95–45.70 | 28.27 | 0.00 | 25.09 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 1925 | 4.33 | 9.98 | 19.07 | 18.57–19.82 |  |  | 4.08 |
| bifrost | chat/stream | 100000/0 | 631 | 14.73 | 24.78 | 35.49 | 34.56–36.09 | 12.77 | 0.00 | 12.79 |
| bifrost | responses/nonstream | 100000/0 | 1787 | 4.73 | 10.80 | 21.04 | 20.05–21.53 |  |  | 4.43 |
| bifrost | responses/stream | 100000/0 | 462 | 20.46 | 33.02 | 47.06 | 46.76–47.70 | 18.97 | 0.00 | 17.24 |
| bifrost | messages/nonstream | 100000/0 | 1753 | 4.82 | 11.13 | 21.29 | 20.43–21.37 |  |  | 4.56 |
| bifrost | messages/stream | 100000/0 | 524 | 18.01 | 29.30 | 41.89 | 40.75–42.00 | 16.20 | 0.00 | 15.45 |
| tensorzero | chat/nonstream | 60043/0 | 200 | 49.98 | 50.20 | 60.09 | 60.05–60.11 |  |  | 49.73 |
| tensorzero | chat/stream | 100000/0 | 449 | 3.23 | 50.04 | 59.99 | 59.99–60.03 | 1.23 | 0.00 | 1.29 |
| tensorzero | responses/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | responses/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| tensorzero | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| tensorzero | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| omniroute | chat/nonstream | 26878/0 | 89 | 107.04 | 138.39 | 231.31 | 197.40–252.10 |  |  | 106.79 |
| omniroute | chat/stream | 20300/0 | 67 | 144.84 | 172.26 | 299.92 | 286.46–305.63 | 133.36 | 0.00 | 142.90 |
| omniroute | responses/nonstream | 26934/0 | 90 | 107.78 | 136.78 | 212.95 | 207.72–232.83 |  |  | 107.48 |
| omniroute | responses/stream | 18435/0 | 62 | 158.46 | 180.37 | 325.24 | 313.69–336.86 | 150.61 | 0.00 | 155.24 |
| omniroute | messages/nonstream | 27771/0 | 92 | 103.97 | 134.16 | 219.34 | 199.16–237.65 |  |  | 103.71 |
| omniroute | messages/stream | 19528/0 | 65 | 149.37 | 170.24 | 307.11 | 290.75–320.53 | 141.25 | 0.00 | 146.81 |
| llmgateway | chat/nonstream | 100000/0 | 566 | 16.55 | 24.95 | 46.69 | 43.13–56.27 |  |  | 16.30 |
| llmgateway | chat/stream | 85283/0 | 284 | 31.38 | 46.67 | 91.15 | 86.93–104.08 | 27.32 | 0.00 | 29.44 |
| llmgateway | responses/nonstream | 100000/0 | 494 | 16.10 | 27.21 | 47.55 | 42.79–54.69 |  |  | 15.80 |
| llmgateway | responses/stream | 71867/0 | 239 | 37.70 | 50.29 | 84.24 | 79.82–93.01 | 32.27 | 0.00 | 34.48 |
| llmgateway | messages/nonstream | 100000/0 | 556 | 14.13 | 23.98 | 37.92 | 36.77–38.89 |  |  | 13.87 |
| llmgateway | messages/stream | 100000/0 | 360 | 23.31 | 34.38 | 53.52 | 52.21–56.25 | 18.38 | 0.00 | 20.75 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13681 | 21288 | 27268 | 29672 | 30085 | 29725 | 29159 | 27878 | 28782 | 30085 | 16 | 8 |
| gomodel | 2162 | 3340 | 3765 | 4306 | 4590 | 4901 | 4861 | 4730 | 4217 | 4901 | 32 | 32 |
| litellm | 150 | 153 | 162 | 200 | 199 | 203 | 191 | 196 | 163 | 203 | 32 | 8 |
| portkey | 676 | 920 | 932 | 942 | 967 | 922 | 906 | 881 | 862 | 967 | 16 | 2 |
| bifrost | 1278 | 1886 | 1922 | 2002 | 2005 | 1980 | 1986 | 1927 | 1930 | 2005 | 16 | 4 |
| tensorzero | 20 | 41 | 79 | 160 | 319 | 637 | 1258 | 2541 | 4667 | 4667 | 256 | 256 |
| omniroute | 70 | 86 | 83 | 84 | 89 | 91 | 92 | 80 | 80 | 92 | 64 | 16 |
| llmgateway | 109 | 216 | 364 | 587 | 798 | 1140 | 1028 | 1248 | 1127 | 1248 | 128 | 128 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 22.1 | 64.3 | 0.60 | 72.6 | 42.8 | 106.7 | 4287 | 40.2 |
| litellm | 391.8 | 1234.9 | 32.74 | 1632.3 | 1632.3 | 100.8 | 162 | 1.6 |
| portkey | 57.9 | 177.4 | 2.35 | 129.2 | 116.1 | 112.9 | 955 | 8.5 |
| bifrost | 97.7 | 291.6 | 9.03 | 380.3 | 377.5 | 134.7 | 1938 | 14.4 |
| tensorzero | 88.0 | 246.9 | 0.60 | 115.0 | 97.0 | 7.1 | 200 | 28.1 |
| omniroute | 415.9 | 1329.4 | 5.35 | 699.8 | 711.4 | 100.0 | 90 | 0.9 |
| llmgateway | 745.8 | 2877.8 | 15.34 | 754.5 | 754.4 | 123.0 | 621 | 5.0 |
