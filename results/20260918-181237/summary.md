# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=20000 c=10 trials=5`

_Latency = median across 5 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 100000/0 | 26234 | 0.26 | 0.59 | 2.96 | 2.58–3.76 |  |  | 0.00 |
| baseline | chat/stream | 100000/0 | 4418 | 1.98 | 3.80 | 6.48 | 6.19–9.08 | 1.77 | 0.00 | 0.00 |
| baseline | responses/nonstream | 100000/0 | 26246 | 0.26 | 0.59 | 2.86 | 2.71–3.30 |  |  | 0.00 |
| baseline | responses/stream | 100000/0 | 3520 | 2.47 | 4.70 | 8.16 | 7.49–9.38 | 2.19 | 0.00 | 0.00 |
| baseline | messages/nonstream | 100000/0 | 26035 | 0.25 | 0.59 | 2.92 | 2.35–3.76 |  |  | 0.00 |
| baseline | messages/stream | 100000/0 | 3295 | 2.68 | 5.00 | 8.32 | 7.81–11.30 | 2.36 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 100000/0 | 3966 | 2.21 | 4.29 | 7.01 | 6.88–7.06 |  |  | 1.95 |
| gomodel | chat/stream | 100000/0 | 1661 | 5.53 | 9.55 | 14.05 | 13.35–14.27 | 4.95 | 0.00 | 3.55 |
| gomodel | responses/nonstream | 100000/0 | 2839 | 3.05 | 6.14 | 10.27 | 9.99–10.69 |  |  | 2.79 |
| gomodel | responses/stream | 100000/0 | 1534 | 5.97 | 10.32 | 15.12 | 14.65–15.21 | 5.42 | 0.00 | 3.50 |
| gomodel | messages/nonstream | 100000/0 | 4032 | 2.19 | 4.15 | 6.80 | 6.73–6.92 |  |  | 1.94 |
| gomodel | messages/stream | 100000/0 | 1146 | 8.18 | 13.77 | 19.30 | 19.11–20.33 | 7.10 | 0.00 | 5.50 |
| litellm | chat/nonstream | 70276/0 | 241 | 48.96 | 60.76 | 68.55 | 56.84–89.08 |  |  | 48.70 |
| litellm | chat/stream | 17403/0 | 59 | 165.62 | 187.41 | 229.04 | 222.75–682.02 | 165.60 | 0.00 | 163.64 |
| litellm | responses/nonstream | 68732/0 | 237 | 42.48 | 62.72 | 70.88 | 55.42–91.10 |  |  | 42.22 |
| litellm | responses/stream | 42575/0 | 149 | 76.95 | 84.85 | 95.45 | 94.24–127.44 | 76.92 | 0.00 | 74.48 |
| litellm | messages/nonstream | 61549/0 | 205 | 49.25 | 72.68 | 81.98 | 64.59–94.55 |  |  | 49.00 |
| litellm | messages/stream | 36525/0 | 121 | 77.37 | 88.15 | 99.81 | 94.58–147.18 | 39.45 | 0.93 | 74.69 |
| portkey | chat/nonstream | 100000/0 | 899 | 9.14 | 14.97 | 29.37 | 28.14–29.43 |  |  | 8.88 |
| portkey | chat/stream | 100000/0 | 347 | 27.95 | 31.66 | 44.25 | 42.87–44.45 | 27.93 | 0.00 | 25.97 |
| portkey | responses/nonstream | 100000/0 | 946 | 9.13 | 13.63 | 27.76 | 27.06–28.51 |  |  | 8.87 |
| portkey | responses/stream | 100000/0 | 347 | 27.98 | 31.59 | 44.02 | 42.94–44.07 | 27.96 | 0.00 | 25.51 |
| portkey | messages/nonstream | 0/100000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/100000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 100000/0 | 1999 | 4.09 | 9.87 | 19.33 | 18.92–20.19 |  |  | 3.83 |
| bifrost | chat/stream | 100000/0 | 637 | 14.62 | 24.37 | 35.40 | 34.37–35.50 | 11.91 | 0.00 | 12.64 |
| bifrost | responses/nonstream | 100000/0 | 1977 | 4.20 | 9.88 | 19.40 | 19.22–19.77 |  |  | 3.94 |
| bifrost | responses/stream | 100000/0 | 587 | 15.93 | 26.38 | 37.73 | 37.29–38.05 | 13.19 | 0.00 | 13.46 |
| bifrost | messages/nonstream | 100000/0 | 1934 | 4.30 | 10.01 | 19.19 | 18.62–20.38 |  |  | 4.05 |
| bifrost | messages/stream | 100000/0 | 696 | 12.95 | 23.15 | 35.70 | 35.28–36.15 | 11.12 | 0.00 | 10.27 |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=2 | c=4 | c=8 | c=16 | c=32 | c=64 | c=128 | c=256 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | 13480 | 20250 | 26736 | 28108 | 29203 | 29214 | 27707 | 27484 | 27236 | 29214 | 32 | 8 |
| gomodel | 2175 | 3313 | 3721 | 4033 | 4285 | 4416 | 4267 | 3931 | 3435 | 4416 | 32 | 16 |
| litellm | 183 | 188 | 248 | 202 | 250 | 202 | 239 | 245 | 220 | 250 | 16 | 4 |
| portkey | 686 | 952 | 955 | 982 | 970 | 946 | 950 | 884 | 887 | 982 | 8 | 2 |
| bifrost | 1364 | 1935 | 2014 | 2065 | 2085 | 2086 | 2040 | 1969 | 1933 | 2086 | 32 | 4 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | 20.6 | 60.2 | 0.55 | 66.7 | 24.2 | 107.6 | 4145 | 38.5 |
| litellm | 357.9 | 1119.2 | 21.49 | 1357.8 | 1356.8 | 99.4 | 192 | 1.9 |
| portkey | 57.9 | 177.4 | 0.99 | 120.1 | 110.0 | 114.4 | 962 | 8.4 |
| bifrost | 84.5 | 255.1 | 8.79 | 287.2 | 203.8 | 135.1 | 2013 | 14.9 |
