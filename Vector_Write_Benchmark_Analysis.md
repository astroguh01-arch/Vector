# Vector.Write Benchmark Analysis

**Comparison:** Vector.Write (Native), ARC, TinyLFU\
**Scope:** Five supplied benchmark scenarios\
**Purpose:** Assess the reported classification behavior, adaptation,
and timing results---not to claim that Vector.Write is a
cache-replacement algorithm.

## Executive summary

Vector.Write is the user's own system for stateful data in games and
general applications. The supplied results compare it with ARC and
TinyLFU, but these systems should not automatically be treated as
equivalent: ARC and TinyLFU are cache-management algorithms, while
Vector.Write is being assessed for how it classifies data.

The key semantic clarification is that **Fast does not simply mean
"frequently changing" or "high activity."** In the user's description,
Fast corresponds to a low rate of change / stable data, even where the
variable is updated often (for example, velocity); Slow corresponds to
sudden jumps or a high rate of change and is treated as not active. This
means the benchmark is closer to classifying **data stability or
rate-of-change behavior** than simply counting update frequency. The
terms "Fast" and "Slow" may therefore be confusing to readers unless the
report defines them explicitly.

Across the five scenarios:

-   **Scenario 1:** Vector.Write reports perfect classification metrics,
    while ARC has the lowest reported latency and total time.
-   **Scenario 2:** ARC and TinyLFU report perfect classification
    metrics; Vector.Write has 100% recall but lower accuracy, precision,
    and F1.
-   **Scenario 3:** ARC and TinyLFU again report perfect classification
    metrics; Vector.Write has 100% recall, 75% accuracy, and 80% F1.
-   **Scenario 4:** Vector.Write takes two steps to reactivate a
    variable, versus one step for ARC and TinyLFU.
-   **Scenario 5:** ARC records zero cache hits in the supplied cyclic
    workload, while TinyLFU records a 69.39% hit ratio. Vector.Write
    reports all seven variables as Fast, which is not directly
    comparable to cache hits.

**Overall:** The current results are useful as an initial comparison,
but they do not establish a universal winner. Vector.Write should
primarily be evaluated on how accurately it identifies the intended
stable/change-rate classes, how it responds to transitions, and what
runtime overhead it introduces. Cache hit ratios should remain a
separate metric.

## 1. What the classes mean

Based on the clarification provided:

-   **Fast:** Low rate of change / relatively stable data, potentially
    updated often. Velocity is an example the user gave.
-   **Slow:** Sudden jumps or a high rate of change; treated by the
    system as not active.

This definition is counterintuitive if readers assume "Fast" means
rapidly changing and "Slow" means slowly changing. Every benchmark
report should state this definition prominently.

There is also a distinction between **update frequency** and **rate of
change in the value**. A variable can be written every frame while its
value changes only slightly; another can be updated rarely but jump
sharply when it changes. Those are different properties. If
Vector.Write's classification depends on value-change rate rather than
write frequency, the ground truth should reflect that distinction.

A useful next step is to define the classification rule precisely---for
example, whether "rate of change" means absolute delta per frame,
normalized delta over time, variance over a rolling window, or another
signal. This report does not assume which formula the implementation
uses.

## 2. Results at a glance

  -------------------------------------------------------------------------
  Scenario            Vector.Write      Baseline result   Interpretation
                      result                              
  ------------------- ----------------- ----------------- -----------------
  1\. Zipfian skew +  100% accuracy,    ARC: 92.86%       Vector.Write
  20 one-hit          precision,        accuracy; lowest  leads reported
  polluters           recall, and F1    delay and total   classification
                                        time              metrics; ARC
                                                          leads timing.

  2\. Dynamic phase   50% accuracy, 50% ARC and TinyLFU   Phase changes
  shift               precision, 100%   report 100% on    appear
                      recall, 66.67% F1 all four metrics  challenging for
                                                          Vector.Write
                                                          under the
                                                          supplied labels.

  3\. Multi-rate      75% accuracy,     ARC and TinyLFU   Vector.Write
  periodic updates    66.67% precision, report 100% on    catches all
                      100% recall, 80%  all four metrics  positive cases
                      F1                                  according to the
                                                          supplied labels,
                                                          but makes other
                                                          classification
                                                          errors.

  4\. Reactivation    2 steps           ARC: 1 step;      Vector.Write
  convergence                           TinyLFU: 1 step   takes one
                                                          additional step
                                                          in this test.

  5\.                 7/7 variables     TinyLFU: 170/245  Class counts and
  Capacity-plus-one   reported Fast; 0  hits; ARC: 0/245  cache hit ratios
  cycle               Slow              hits              are different
                                                          kinds of
                                                          measurements.
  -------------------------------------------------------------------------

## 3. Scenario-by-scenario analysis

### Scenario 1 --- Zipfian skew with one-hit scan polluters

**Workload:** 8 core variables plus 20 one-hit polluters.

  ---------------------------------------------------------------------------------
  Algorithm        Accuracy   Precision     Recall   F1-score  Avg delay Total time
                                                                    (μs)       (ms)
  -------------- ---------- ----------- ---------- ---------- ---------- ----------
  Vector.Write      100.00%     100.00%    100.00%    100.00%      26.70      24.56
  (Native)                                                               

  ARC                92.86%      87.50%     87.50%     87.50%       0.32       0.29

  TinyLFU            85.71%      75.00%     75.00%     75.00%      16.76      15.42
  ---------------------------------------------------------------------------------

**Analysis:** Vector.Write has the strongest reported classification
scores in this run. ARC has the lowest average delay and total time.
TinyLFU trails Vector.Write on the reported classification metrics in
this workload.

**Conclusion:** Vector.Write leads on the supplied classification
metrics, while ARC leads on timing. The data supports this conclusion
for this particular test, not as a general rule across workloads.

### Scenario 2 --- Dynamic phase shift: exploration to combat

  ---------------------------------------------------------------------------------
  Algorithm        Accuracy   Precision     Recall   F1-score  Avg delay Total time
                                                                    (μs)       (ms)
  -------------- ---------- ----------- ---------- ---------- ---------- ----------
  ARC               100.00%     100.00%    100.00%    100.00%       0.32       0.02

  TinyLFU           100.00%     100.00%    100.00%    100.00%       3.79       0.28

  Vector.Write       50.00%      50.00%    100.00%     66.67%       9.25       0.69
  (Native)                                                               
  ---------------------------------------------------------------------------------

**Analysis:** ARC and TinyLFU report perfect classification metrics.
Vector.Write reports perfect recall but lower accuracy, precision, and
F1. Given the supplied labels, this means it found all positive cases
but still made classification errors; the exact
false-positive/false-negative breakdown requires the confusion matrix.

**Conclusion:** Test how quickly Vector.Write's classification responds
when the workload changes phase, and whether the class labels are based
on the same ground truth for all algorithms.

### Scenario 3 --- Multi-rate periodic updates

**Workload:** 80 frames; hot variables at 60 Hz and 15 Hz, cold
variables at 2 Hz and 0.2 Hz.

  ---------------------------------------------------------------------------------
  Algorithm        Accuracy   Precision     Recall   F1-score  Avg delay Total time
                                                                    (μs)       (ms)
  -------------- ---------- ----------- ---------- ---------- ---------- ----------
  ARC               100.00%     100.00%    100.00%    100.00%       0.48       0.10

  TinyLFU           100.00%     100.00%    100.00%    100.00%       2.31       0.48

  Vector.Write       75.00%      66.67%    100.00%     80.00%      11.59       2.39
  (Native)                                                               
  ---------------------------------------------------------------------------------

**Analysis:** ARC and TinyLFU report perfect classification scores.
Vector.Write reports 100% recall, but 75% accuracy and 80% F1. Because
Fast/Slow is described in terms of value stability or rate of change,
this workload needs a clearly defined ground truth that separates write
frequency from value-change magnitude.

**Conclusion:** This is a relevant workload for stateful data, but the
test should specify whether labels are assigned from update cadence,
value deltas, or both. Otherwise, it is difficult to determine precisely
what the classification scores mean.

### Scenario 4 --- Reactivation convergence

  Algorithm                 Steps to reactivate
  ----------------------- ---------------------
  ARC                                         1
  TinyLFU                                     1
  Vector.Write (Native)                       2

**Analysis:** Vector.Write takes two steps, compared with one for each
baseline. The result is a small but clear difference for this test.

**Conclusion:** Add repeated trials and measure elapsed time as well as
steps. Also define exactly what "reactivation" means under
Vector.Write's stability/change-rate semantics, since a sudden jump may
be classed as Slow even if the variable becomes relevant to gameplay.

### Scenario 5 --- Capacity-plus-one cyclic workload

**Workload:** 7 variables, 6 cache slots, 245 accesses.

  -----------------------------------------------------------------------
  Algorithm / system      Reported result         Additional details
  ----------------------- ----------------------- -----------------------
  Vector.Write (Native)   100% Fast; 7/7 Fast; 0  Avg delay: 9.12 μs
                          Slow; F1 100%           

  TinyLFU (W-TinyLFU)     69.39% hit ratio        170/245 hits; 75/245
                                                  misses; F1 92.31%; avg
                                                  delay 3.23 μs

  ARC                     0% hit ratio            0/245 hits; 245/245
                                                  misses; F1 92.31%; avg
                                                  delay 0.94 μs
  -----------------------------------------------------------------------

**Analysis:** ARC's zero-hit result is plausible for some cyclic access
patterns when the working set exceeds capacity, but the supplied result
alone does not establish why it occurred. TinyLFU achieves 170 hits out
of 245 accesses. Vector.Write's "7/7 Fast" is a class distribution, not
a cache hit ratio, so it should not be presented as a directly
comparable 100% success rate.

**Important metric question:** ARC and TinyLFU are both reported with an
F1-score of 92.31%, despite ARC recording zero hits and TinyLFU
recording a 69.39% hit ratio. This may be valid if F1 measures a
separate classification task, but if F1 is meant to be derived from
hit/miss outcomes, the calculation or label mapping needs to be checked.

**Conclusion:** Report cache hits/misses separately from Vector.Write's
Fast/Slow classifications. State the ground-truth class for each
variable and show the confusion matrix used to calculate F1.

## 4. What the timing results say---and do not say

The supplied latency figures show ARC with the lowest reported average
delay in Scenarios 1--3 and Scenario 5. Vector.Write has higher reported
average delay than both baselines in the first three scenarios. This is
a result of the supplied benchmark, not proof that Vector.Write is
inherently slower in all uses.

Before comparing timing numbers, document:

-   Whether the delay is per access, per classification decision, per
    frame, or per batch.
-   Whether initialization and warm-up are included.
-   Whether each system performs equivalent work.
-   Hardware, compiler/build configuration, optimization level, and run
    count.
-   Whether the totals cover the same number of operations.
-   Variability across repeated runs, not just a single average.

If Vector.Write provides a different function from a cache policy, a
lower cache-operation latency alone does not show that it is the better
classifier. The useful comparison is classification quality and overhead
for equivalent inputs and required outputs.

## 5. Recommended evaluation plan

### A. Classification quality

For each variable and time window, record the ground-truth class and
Vector.Write's predicted class. Report:

-   Accuracy, precision, recall, and F1.
-   Confusion matrix, including false positives and false negatives.
-   False-positive and false-negative rates.
-   Results per variable type and workload, not just an overall average.

Define whether the target label represents **low value-change rate**,
**high value-change rate**, **write frequency**, or a combined rule.
These should not be conflated.

### B. Adaptation and transition behavior

Measure:

-   Number of frames or milliseconds until a class changes after a real
    transition.
-   Time to settle, and whether labels oscillate near a threshold.
-   Behavior when stable data suddenly jumps.
-   Behavior when frequently written data changes only slightly.
-   Behavior when rarely written data changes sharply.

These tests map directly to the stated distinction between
stable/low-change-rate data and sudden/high-change-rate data.

### C. Runtime overhead

Measure classification time, CPU cost, memory overhead, allocations, and
scaling as variable count rises. Use repeated runs and report median
plus tail latency (such as p95), where practical.

### D. Representative game-state workloads

Include separate categories such as transforms, velocity, health, combat
state, inventory, timers, and metadata. Use traces or deterministic
synthetic workloads with known labels. Be explicit about whether
classification is intended to control update cadence, processing
frequency, replication priority, batching, or something else.

### E. Baselines and fairness

ARC and TinyLFU are useful reference algorithms for adaptive cache
behavior. For a direct activity-classification comparison, also consider
simple baselines such as: - A fixed threshold on measured value-change
rate. - A fixed threshold on write frequency. - A rolling-window
variance or delta threshold. - A simple hysteresis-based classifier.

Keep cache hit ratio as a separate cache-specific result, rather than
treating it as equivalent to classification accuracy.

## 6. Caveats and items to verify

1.  **Class definitions:** Document Fast and Slow in the benchmark
    itself. Based on the user's clarification, Fast means stable/low
    rate of change, while Slow means sudden jumps/high rate of change
    and is treated as not active.
2.  **Update frequency versus value-change rate:** These are distinct. A
    value may be updated every frame without changing much, or updated
    rarely and then jump sharply.
3.  **Scenario 5 F1:** Verify why ARC and TinyLFU both report 92.31% F1
    despite very different hit ratios. This is only a problem if F1 is
    supposed to summarize hit/miss classification.
4.  **Scenario 5 "100% Fast":** Do not equate this with a 100% cache hit
    ratio.
5.  **Cross-algorithm comparability:** Confirm all classification
    metrics use the same ground truth and evaluation procedure.
6.  **Timing:** Confirm equal operation counts and consistent timing
    methodology.
7.  **Statistical confidence:** Repeat trials and report variability
    before drawing broad conclusions.

## Final assessment

The supplied results suggest Vector.Write can produce strong
classification scores in the scan-pollution scenario, but its
classification scores are lower than ARC and TinyLFU in the supplied
phase-shift and multi-rate scenarios. It also takes one additional step
to reactivate a variable in Scenario 4. ARC is the timing leader in the
supplied measurements, while Scenario 5 illustrates why cache hit ratio
and Fast/Slow classification must remain separate.

With the clarified class meanings, the central research question is not
simply "Which cache algorithm wins?" It is: **How accurately and cheaply
can Vector.Write distinguish stable, low-change-rate state from state
exhibiting sudden or high-rate changes, across realistic game
workloads?** A precise class definition, confusion matrices, transition
measurements, and fair baselines would make that conclusion much
stronger.
