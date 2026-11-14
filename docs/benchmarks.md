# Benchmarks

Results from a Roblox Studio server run comparing Vector's access classifier with ARC (Adaptive Replacement Cache) and W-TinyLFU with a 4-bit sketch. The first three workloads score how well each method identifies hot fields. The fourth measures how many accesses it takes to promote a dormant field.

<div class="benchmark-grid" aria-label="Vector F1 scores">
<section class="benchmark-card"><h2>Scan pollution</h2>
<div class="benchmark-result"><span>Vector</span><strong>100%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--vector" style="width:100.00000%"></span></div></div>
<div class="benchmark-result"><span>ARC</span><strong>87.5%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--arc" style="width:87.50000%"></span></div></div>
<div class="benchmark-result"><span>W-TinyLFU</span><strong>87.5%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--tinylfu" style="width:87.50000%"></span></div></div>
</section>
<section class="benchmark-card"><h2>Exploration to combat</h2>
<div class="benchmark-result"><span>Vector</span><strong>92.47%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--vector" style="width:92.47312%"></span></div></div>
<div class="benchmark-result"><span>ARC</span><strong>89.6%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--arc" style="width:89.60000%"></span></div></div>
<div class="benchmark-result"><span>W-TinyLFU</span><strong>20%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--tinylfu" style="width:20.00000%"></span></div></div>
</section>
<section class="benchmark-card"><h2>Mixed update rates</h2>
<div class="benchmark-result"><span>Vector</span><strong>100%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--vector" style="width:100.00000%"></span></div></div>
<div class="benchmark-result"><span>ARC</span><strong>94.87%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--arc" style="width:94.87107%"></span></div></div>
<div class="benchmark-result"><span>W-TinyLFU</span><strong>97.5%</strong><div class="benchmark-track" aria-hidden="true"><span class="benchmark-fill benchmark-fill--tinylfu" style="width:97.50009%"></span></div></div>
</section>
</div>

The cards show the reported F1 scores on a 0–100% scale. F1 balances precision and recall. Higher scores indicate better hot-field classification, while lower delay indicates less measured work per access in this run.

## Scan pollution

A Zipfian workload followed by 20 one-off scan accesses. Vector classified all eight hot fields and all 20 cold fields correctly. ARC and W-TinyLFU each reported one false positive and one false negative.

| Method | Accuracy | Precision | Recall | F1 | Final F1 | Mean delay (µs) | Total time (ms) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Vector | 100% | 100% | 100% | 100% | 100% | 16.125 | 17.737 |
| ARC | 92.86% | 87.5% | 87.5% | 87.5% | 87.5% | 0.253 | 0.278 |
| W-TinyLFU | 92.86% | 87.5% | 87.5% | 87.5% | 87.5% | 1.230 | 1.353 |

## Exploration to combat

The working set switches from exploration to combat. Scores summarize 50 post-switch samples. Vector and ARC both reached 100% F1 at the final snapshot, while W-TinyLFU ended at 20%.

| Method | Accuracy | Precision | Recall | F1 | Final F1 | Mean delay (µs) | Total time (ms) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Vector | 93% | 100% | 86% | 92.47% | 100% | 7.170 | 0.358 |
| ARC | 89.6% | 89.6% | 89.6% | 89.6% | 100% | 0.302 | 0.015 |
| W-TinyLFU | 20% | 20% | 20% | 20% | 20% | 3.882 | 0.194 |

## Mixed update rates

Heartbeat schedules four clocks at 60, 15, 2, and 0.2 Hz. The reported score is time-weighted over a 10-second window after a five-second warmup, using 601 samples.

| Method | Accuracy | Precision | Recall | F1 | Final F1 | Mean delay (µs) | Total time (ms) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Vector | 100% | 100% | 100% | 100% | 100% | 14.518 | 32.723 |
| ARC | 94.87% | 94.87% | 94.87% | 94.87% | 0% | 1.212 | 2.731 |
| W-TinyLFU | 97.5% | 97.5% | 97.5% | 97.5% | 75% | 3.800 | 8.566 |

### Observed clock rates

| Target rate | Observed rate | Ticks recorded | Missed ticks |
| ---: | ---: | ---: | ---: |
| 60 Hz | 58.100 Hz | 872 | 28 |
| 15 Hz | 14.792 Hz | 222 | 3 |
| 2 Hz | 1.999 Hz | 30 | 0 |
| 0.2 Hz | 0.200 Hz | 3 | 0 |

The clock run lasted 15.009 seconds. All three methods received the same samples.

## Dormant field reactivation

This workload repeatedly accesses a dormant field against a saturated working set and records the access step where it is promoted to Fast.

| Method | Accesses to promotion |
| --- | ---: |
| Vector | No promotion recorded |
| ARC | 1 |
| W-TinyLFU | 1 |

The run reports `-1` for Vector, shown here as no promotion recorded.

## Reading the results

These results describe one benchmark run. The final snapshot shows where each method ended, while the reported score reflects the scenario's sampling method. For example, the phase-switch score includes the transition period. Timing results describe the measured benchmark operations, not end-to-end network latency.

See [Classification](internals/information-velocity.md) for how Vector computes velocity, acceleration, jerk, and alpha.
