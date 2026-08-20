# Gateway Benchmark Summary

`instance=t2.micro cpus=1 N=300 c=10 trials=1`

_Latency = median across 1 trial(s); p99 shows the min–max across trials. rps in the latency table is completed req/s at the fixed concurrency (latency-coupled); see the capacity table for sustained throughput._

## Latency (ms, median of trials)

| target | variant | ok/fail | rps | p50 | p90 | p99 | p99 min–max | ttft p50 | gap p50 | overhead p50 |
|---|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| baseline | chat/nonstream | 300/0 | 3542 | 2.25 | 4.67 | 12.57 | 12.57–12.57 |  |  | 0.00 |
| baseline | chat/stream | 300/0 | 918 | 10.32 | 18.84 | 25.49 | 25.49–25.49 | 8.76 | — | 0.00 |
| baseline | responses/nonstream | 300/0 | 3946 | 1.87 | 3.61 | 13.33 | 13.33–13.33 |  |  | 0.00 |
| baseline | responses/stream | 300/0 | 765 | 11.39 | 20.33 | 31.05 | 31.05–31.05 | 10.07 | — | 0.00 |
| baseline | messages/nonstream | 300/0 | 4102 | 1.85 | 3.39 | 11.32 | 11.32–11.32 |  |  | 0.00 |
| baseline | messages/stream | 300/0 | 698 | 12.88 | 22.86 | 28.01 | 28.01–28.01 | 11.78 | — | 0.00 |
| gomodel | chat/nonstream | 300/0 | 1100 | 9.20 | 15.34 | 19.10 | 19.10–19.10 |  |  | 6.95 |
| gomodel | chat/stream | 300/0 | 497 | 19.61 | 27.86 | 36.04 | 36.04–36.04 | 18.85 | — | 9.29 |
| gomodel | responses/nonstream | 300/0 | 1041 | 9.37 | 16.16 | 20.79 | 20.79–20.79 |  |  | 7.50 |
| gomodel | responses/stream | 300/0 | 457 | 20.17 | 35.09 | 49.83 | 49.83–49.83 | 18.63 | — | 8.78 |
| gomodel | messages/nonstream | 300/0 | 1121 | 9.11 | 15.67 | 21.38 | 21.38–21.38 |  |  | 7.26 |
| gomodel | messages/stream | 300/0 | 249 | 39.25 | 55.84 | 71.79 | 71.79–71.79 | 37.87 | — | 26.37 |
| litellm | chat/nonstream | 300/0 | 133 | 71.96 | 85.36 | 96.96 | 96.96–96.96 |  |  | 69.71 |
| litellm | chat/stream | 297/3 | 12 | 366.69 | 388.20 | 15179.96 | 15179.96–15179.96 | 366.63 | — | 356.37 |
| litellm | responses/nonstream | 300/0 | 122 | 77.43 | 88.92 | 136.35 | 136.35–136.35 |  |  | 75.56 |
| litellm | responses/stream | 300/0 | 87 | 114.04 | 116.47 | 149.22 | 149.22–149.22 | 113.97 | — | 102.65 |
| litellm | messages/nonstream | 300/0 | 76 | 128.18 | 138.82 | 158.38 | 158.38–158.38 |  |  | 126.33 |
| litellm | messages/stream | 300/0 | 88 | 112.54 | 115.09 | 132.38 | 132.38–132.38 | 112.47 | — | 99.66 |
| portkey | chat/nonstream | 300/0 | 239 | 38.71 | 52.24 | 72.77 | 72.77–72.77 |  |  | 36.46 |
| portkey | chat/stream | 300/0 | 136 | 67.38 | 102.77 | 126.93 | 126.93–126.93 | 67.30 | — | 57.06 |
| portkey | responses/nonstream | 300/0 | 244 | 38.57 | 57.88 | 67.56 | 67.56–67.56 |  |  | 36.70 |
| portkey | responses/stream | 300/0 | 141 | 67.39 | 92.51 | 105.10 | 105.10–105.10 | 67.30 | — | 56.00 |
| portkey | messages/nonstream | 0/300 | 0 | — | — | — | — |  |  | — |
| portkey | messages/stream | 0/300 | 0 | — | — | — | — | — | — | — |
| bifrost | chat/nonstream | 300/0 | 763 | 1.12 | 13.51 | 223.05 | 223.05–223.05 |  |  | -1.13 |
| bifrost | chat/stream | 300/0 | 168 | 50.85 | 101.21 | 132.93 | 132.93–132.93 | 39.08 | — | 40.53 |
| bifrost | responses/nonstream | 300/0 | 726 | 1.19 | 17.67 | 204.99 | 204.99–204.99 |  |  | -0.68 |
| bifrost | responses/stream | 300/0 | 137 | 66.87 | 105.88 | 144.72 | 144.72–144.72 | 57.83 | — | 55.48 |
| bifrost | messages/nonstream | 300/0 | 761 | 1.14 | 22.72 | 181.55 | 181.55–181.55 |  |  | -0.71 |
| bifrost | messages/stream | 300/0 | 7 | 8.93 | 22.13 | 81.50 | 81.50–81.50 | 6.26 | — | -3.95 |

## Resources

| gateway | image MB (compressed) | image MB (on-disk) | startup s | idle MB | peak MB | avg CPU % | load rps | rps/CPU% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| gomodel | — | 47.0 | — | 22.1 | 32.4 | 26.0 | 0 | 0.0 |
| litellm | — | 1158.3 | — | 559.3 | 467.8 | 80.2 | 0 | 0.0 |
| portkey | — | 177.4 | — | 63.7 | 64.9 | 70.4 | 0 | 0.0 |
| bifrost | — | 230.5 | — | 85.5 | 266.6 | 43.7 | 0 | 0.0 |
