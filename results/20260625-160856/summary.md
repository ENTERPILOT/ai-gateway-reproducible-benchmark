# Gateway Benchmark Summary

`instance=c7i.large cpus=2 N=8000 c=10 trials=2`

_Latency = median across 2 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 16000/0 | 24745 | 0.30 | 0.60 | 2.79 | 2.42–3.16 |  |  | 0.00 |
| baseline | chat/stream | 16000/0 | 3755 | 2.21 | 4.80 | 8.59 | 8.54–8.65 | 1.83 | 0.00 | 0.00 |
| baseline | responses/nonstream | 16000/0 | 23619 | 0.32 | 0.66 | 2.66 | 2.45–2.86 |  |  | 0.00 |
| baseline | responses/stream | 16000/0 | 2761 | 3.02 | 6.65 | 11.61 | 11.26–11.95 | 2.35 | 0.00 | 0.00 |
| baseline | messages/nonstream | 16000/0 | 23627 | 0.31 | 0.64 | 2.60 | 2.50–2.71 |  |  | 0.00 |
| baseline | messages/stream | 16000/0 | 2497 | 3.31 | 7.54 | 12.66 | 12.40–12.91 | 2.55 | 0.00 | 0.00 |
| gomodel | chat/nonstream | 16000/0 | 3913 | 2.16 | 4.58 | 8.29 | 8.05–8.54 |  |  | 1.86 |
| gomodel | chat/stream | 16000/0 | 1545 | 5.81 | 10.54 | 16.71 | 16.40–17.02 | 5.54 | 0.00 | 3.60 |
| gomodel | responses/nonstream | 16000/0 | 3595 | 2.42 | 4.89 | 8.19 | 8.16–8.22 |  |  | 2.10 |
| gomodel | responses/stream | 16000/0 | 1536 | 5.77 | 10.72 | 17.16 | 16.82–17.49 | 5.29 | 0.00 | 2.74 |
| gomodel | messages/nonstream | 16000/0 | 4029 | 2.13 | 4.31 | 7.79 | 7.64–7.95 |  |  | 1.82 |
| gomodel | messages/stream | 16000/0 | 953 | 9.51 | 17.59 | 26.16 | 26.10–26.22 | 8.44 | 0.00 | 6.20 |
| litellm | chat/nonstream | 4137/0 | 207 | 44.45 | 48.64 | 61.71 | 57.80–65.62 |  |  | 44.16 |
| litellm | chat/stream | 1004/0 | 50 | 197.71 | 205.09 | 226.04 | 225.77–226.30 | 197.70 | 0.00 | 195.50 |
| litellm | responses/nonstream | 4198/0 | 210 | 47.28 | 50.20 | 55.11 | 54.03–56.19 |  |  | 46.97 |
| litellm | responses/stream | 3160/0 | 158 | 62.64 | 69.35 | 78.79 | 77.13–80.46 | 62.61 | 0.00 | 59.62 |
| litellm | messages/nonstream | 2492/0 | 125 | 79.58 | 86.55 | 95.67 | 95.01–96.33 |  |  | 79.27 |
| litellm | messages/stream | 3079/0 | 154 | 64.38 | 71.35 | 80.89 | 80.81–80.97 | 64.34 | 0.00 | 61.07 |
| portkey | chat/nonstream | 14192/0 | 710 | 11.39 | 21.84 | 35.47 | 35.23–35.72 |  |  | 11.09 |
| portkey | chat/stream | 6658/0 | 333 | 28.70 | 34.01 | 50.25 | 50.14–50.37 | 28.68 | 0.00 | 26.48 |
| portkey | responses/nonstream | 16000/0 | 814 | 10.46 | 15.91 | 32.41 | 31.77–33.06 |  |  | 10.15 |
| portkey | responses/stream | 6654/0 | 333 | 28.87 | 33.70 | 49.75 | 48.35–51.16 | 28.84 | 0.00 | 25.84 |
| portkey | messages/nonstream | 0/16000 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/16000 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 16000/0 | 2576 | 2.91 | 7.85 | 21.01 | 20.55–21.46 |  |  | 2.61 |
| bifrost | chat/stream | 13715/0 | 686 | 13.69 | 22.64 | 33.20 | 33.12–33.28 | 10.34 | 0.02 | 11.48 |
| bifrost | responses/nonstream | 16000/0 | 2559 | 3.12 | 7.26 | 19.11 | 16.11–22.11 |  |  | 2.81 |
| bifrost | responses/stream | 9940/0 | 497 | 17.45 | 28.79 | 52.16 | 48.62–55.69 | 14.78 | 0.01 | 14.42 |
| bifrost | messages/nonstream | 16000/0 | 2527 | 2.91 | 7.26 | 25.09 | 19.99–30.18 |  |  | 2.60 |
| bifrost | messages/stream | 0/0 | 0 | — | — | — | — | — | — | — |

## Capacity (chat non-stream, sustained req/s by concurrency)

| target | c=1 | c=16 | c=128 | peak rps | @c | knee c |
|---|--:|--:|--:|--:|--:|--:|
| baseline | 12929 | 25252 | 25254 | 25254 | 128 | 16 |
| gomodel | 2440 | 4202 | 3770 | 4202 | 16 | 16 |
| litellm | 195 | 223 | 167 | 223 | 16 | 16 |
| portkey | 501 | 758 | 731 | 758 | 16 | 16 |
| bifrost | 1709 | 2664 | 2497 | 2664 | 16 | 16 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | — | 47.2 | 0.66 | 51.3 | 34.1 | 92.0 | 4138 | 45.0 |
| litellm | — | 1159.9 | 14.82 | 1009.0 | 1009.0 | 99.8 | 215 | 2.2 |
| portkey | — | 177.4 | 1.07 | 113.9 | 114.2 | 116.7 | 848 | 7.3 |
| bifrost | — | 230.7 | 6.74 | 159.0 | 135.1 | 117.0 | 2559 | 21.9 |
