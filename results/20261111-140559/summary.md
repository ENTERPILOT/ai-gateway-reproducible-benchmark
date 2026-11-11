# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=3`

_Latency = median across 3 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 60000/0 | 29171 | 0.24 | 0.52 | 2.45 | 2.28–3.20 |  |  | 0.00 |
| baseline | chat/stream | 60000/0 | 4780 | 1.82 | 3.52 | 6.55 | 6.43–6.64 | 1.63 | 0.00 | 0.00 |
| baseline | responses/nonstream | 60000/0 | 27418 | 0.27 | 0.62 | 1.96 | 1.91–2.00 |  |  | 0.00 |
| baseline | responses/stream | 60000/0 | 3036 | 2.91 | 5.46 | 8.57 | 8.39–9.31 | 2.59 | 0.00 | 0.00 |
| baseline | messages/nonstream | 60000/0 | 29443 | 0.23 | 0.53 | 2.48 | 2.36–2.54 |  |  | 0.00 |
| baseline | messages/stream | 60000/0 | 3748 | 2.36 | 4.43 | 7.45 | 7.44–7.60 | 2.10 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 60000/0 | 4506 | 1.98 | 3.59 | 5.81 | 5.80–6.02 |  |  | 1.74 |
| gomodel | chat/stream | 60000/0 | 1845 | 4.98 | 8.46 | 12.52 | 11.85–12.82 | 4.01 | 0.00 | 3.16 |
| gomodel | responses/nonstream | 60000/0 | 3129 | 2.72 | 5.42 | 9.59 | 9.34–10.14 |  |  | 2.45 |
| gomodel | responses/stream | 60000/0 | 1174 | 7.97 | 13.22 | 18.77 | 18.72–18.78 | 6.25 | 0.00 | 5.06 |
| gomodel | messages/nonstream | 60000/0 | 4465 | 2.02 | 3.61 | 6.03 | 6.00–6.22 |  |  | 1.79 |
| gomodel | messages/stream | 60000/0 | 1334 | 6.96 | 11.71 | 16.60 | 16.46–16.76 | 5.25 | 0.00 | 4.60 |
| litellm | chat/nonstream | 34416/0 | 191 | 51.95 | 57.95 | 68.47 | 66.88–96.21 |  |  | 51.71 |
| litellm | chat/stream | 10174/0 | 59 | 167.65 | 187.05 | 216.58 | 213.11–248.18 | 91.74 | 0.00 | 165.83 |
| litellm | responses/nonstream | 30253/0 | 168 | 60.73 | 74.69 | 85.48 | 72.95–97.96 |  |  | 60.46 |
| litellm | responses/stream | 16622/0 | 92 | 108.55 | 145.78 | 175.26 | 170.04–176.26 | 108.06 | 0.00 | 105.64 |
| litellm | messages/nonstream | 26939/0 | 150 | 67.76 | 84.25 | 94.49 | 82.38–107.33 |  |  | 67.53 |
| litellm | messages/stream | 14905/0 | 83 | 122.68 | 172.71 | 202.87 | 198.68–203.97 | 34.43 | 1.30 | 120.32 |
| portkey | chat/nonstream | 60000/0 | 944 | 8.86 | 14.00 | 27.22 | 26.63–27.70 |  |  | 8.62 |
| portkey | chat/stream | 60000/0 | 352 | 27.70 | 30.65 | 40.70 | 40.35–42.15 | 27.68 | 0.00 | 25.88 |
| portkey | responses/nonstream | 60000/0 | 986 | 8.92 | 12.72 | 25.97 | 25.36–26.15 |  |  | 8.65 |
| portkey | responses/stream | 60000/0 | 348 | 27.99 | 31.41 | 42.40 | 42.27–42.50 | 27.95 | 0.00 | 25.08 |
| portkey | messages/nonstream | 0/60000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/60000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 60000/0 | 2035 | 4.08 | 9.49 | 19.42 | 17.99–19.98 |  |  | 3.84 |
| bifrost | chat/stream | 60000/0 | 680 | 13.64 | 22.93 | 33.51 | 33.12–33.67 | 11.91 | 0.00 | 11.82 |
| bifrost | responses/nonstream | 60000/0 | 1883 | 4.48 | 10.23 | 18.95 | 18.78–20.06 |  |  | 4.21 |
| bifrost | responses/stream | 60000/0 | 495 | 19.14 | 30.75 | 43.67 | 43.62–44.18 | 17.79 | 0.00 | 16.23 |
| bifrost | messages/nonstream | 60000/0 | 1867 | 4.54 | 10.22 | 19.68 | 18.87–20.44 |  |  | 4.31 |
| bifrost | messages/stream | 60000/0 | 566 | 16.62 | 27.19 | 39.04 | 39.00–39.32 | 14.94 | 0.00 | 14.26 |
| tensorzero | chat/nonstream | 36004/0 | 200 | 49.99 | 50.15 | 60.07 | 60.06–60.10 |  |  | 49.75 |
| tensorzero | chat/stream | 60000/0 | 456 | 2.90 | 50.03 | 60.00 | 60.00–60.02 | 1.20 | 0.00 | 1.08 |
| tensorzero | responses/nonstream | 0/60000 | 0 | — | — | — | — |  |  | — |
| tensorzero | responses/stream | 0/60000 | 0 | — | — | — | — | — | — | — |
| tensorzero | messages/nonstream | 0/60000 | 0 | — | — | — | — |  |  | — |
| tensorzero | messages/stream | 0/60000 | 0 | — | — | — | — | — | — | — |
| omniroute | chat/nonstream | 15892/0 | 88 | 107.55 | 146.74 | 236.85 | 220.37–247.44 |  |  | 107.31 |
| omniroute | chat/stream | 12248/0 | 68 | 143.10 | 171.53 | 281.70 | 279.24–304.12 | 131.11 | 0.00 | 141.28 |
| omniroute | responses/nonstream | 16683/0 | 92 | 103.55 | 136.96 | 197.55 | 195.92–201.28 |  |  | 103.28 |
| omniroute | responses/stream | 11203/0 | 62 | 157.23 | 175.19 | 321.55 | 319.12–328.85 | 149.29 | 0.00 | 154.32 |
| omniroute | messages/nonstream | 16550/0 | 91 | 103.16 | 142.64 | 203.26 | 196.29–213.85 |  |  | 102.93 |
| omniroute | messages/stream | 11955/0 | 66 | 147.31 | 170.29 | 294.74 | 267.66–306.38 | 139.35 | 0.00 | 144.95 |
| llmgateway | chat/nonstream | 60000/0 | 639 | 13.31 | 22.01 | 50.94 | 50.50–52.32 |  |  | 13.07 |
| llmgateway | chat/stream | 55195/0 | 306 | 29.04 | 43.06 | 98.31 | 96.61–107.92 | 25.01 | 0.00 | 27.22 |
| llmgateway | responses/nonstream | 60000/0 | 541 | 14.45 | 24.82 | 69.76 | 49.22–85.46 |  |  | 14.18 |
| llmgateway | responses/stream | 48279/0 | 268 | 32.51 | 44.14 | 88.96 | 81.54–90.19 | 27.63 | 0.00 | 29.60 |
| llmgateway | messages/nonstream | 60000/0 | 566 | 13.34 | 23.61 | 43.09 | 36.88–50.78 |  |  | 13.11 |
| llmgateway | messages/stream | 60000/0 | 389 | 21.19 | 30.72 | 51.29 | 50.70–53.71 | 16.60 | 0.00 | 18.83 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 15151 | 23339 | 30208 | 31560 | 32808 | 31966 | 31690 | 30538 | 31169 | 32808 | 16 | 8 |
| gomodel | 2283 | 3542 | 4076 | 4454 | 4958 | 5158 | 5171 | 5160 | 4361 | 5171 | 64 | 16 |
| litellm | 142 | 190 | 190 | 189 | 192 | 152 | 190 | 182 | 167 | 192 | 16 | 2 |
| portkey | 729 | 990 | 1008 | 1019 | 1030 | 986 | 949 | 928 | 900 | 1030 | 16 | 2 |
| bifrost | 1351 | 1960 | 2055 | 2090 | 2105 | 2136 | 2091 | 2060 | 2017 | 2136 | 32 | 4 |
| tensorzero | 20 | 40 | 80 | 161 | 321 | 638 | 1270 | 2529 | 4878 | 4878 | 256 | 256 |
| omniroute | 73 | 86 | 90 | 92 | 92 | 83 | 85 | 77 | 81 | 92 | 16 | 4 |
| llmgateway | 125 | 236 | 384 | 601 | 808 | 1124 | 1247 | 1113 | 1119 | 1247 | 64 | 64 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 22.7 | 65.7 | 0.94 | 76.3 | 57.0 | 107.3 | 4663 | 43.5 |
| litellm | 395.6 | 1257.6 | 29.60 | 1784.8 | 1784.8 | 191.4 | 188 | 1.0 |
| portkey | 57.9 | 177.4 | 1.84 | 131.7 | 118.5 | 114.5 | 1013 | 8.8 |
| bifrost | 99.0 | 298.7 | 13.50 | 374.0 | 347.0 | 133.1 | 2045 | 15.4 |
| tensorzero | 88.0 | 246.9 | 1.11 | 108.7 | 92.3 | 6.0 | 199 | 33.2 |
| omniroute | 496.3 | 1659.3 | 7.99 | 793.0 | 776.0 | 95.4 | 88 | 0.9 |
| llmgateway | 740.8 | 2716.4 | 12.71 | 839.9 | 844.3 | 127.2 | 683 | 5.4 |
