# Tests

## Steady Cadence

Tests classification under consistent variable access patterns.

| Variable     | IV      | LRU  | LFU  |
| ------------ | ------- | ---- | ---- |
| CombatHealth | Fast    | Fast | Fast |
| CombatMana   | Fast    | Fast | Fast |
| Stamina      | Fast    | Fast | Fast |
| PlayerGold   | Slow    | Slow | Slow |
| PlayerLevel  | Neutral | Slow | Slow |

IV correctly distinguishes `PlayerLevel` as **Neutral**, while LRU and LFU classify it as **Slow**.

---

## Scan Pollution

Tests whether scanning or touching data causes inactive variables to be incorrectly classified as active.

* **Total variables scanned:** 20
* **IV false-hot classifications:** 0
* **LRU false-hot classifications:** 20
* **LFU false-hot classifications:** 0

IV produced **0 false-hot classifications**, while LRU classified all 20 scanned variables as hot.

This demonstrates that IV is less susceptible to activity pollution caused by scanning.

---

## Phase Change / Role Swap

Tests whether the metric can adapt when variable activity changes abruptly.

Previously active combat variables become inactive, while previously inactive resource variables become active.

### IV

* `CombatHealth` → died ✓
* `CombatMana` → died ✓
* `Woodcutting` → hot ✓
* `Mining` → hot ✓

### LRU

* `CombatHealth` → died ✓
* `CombatMana` → died ✓
* `Woodcutting` → hot ✗
* `Mining` → hot ✗

### LFU

* `CombatHealth` → died ✗
* `CombatMana` → died ✗
* `Woodcutting` → hot ✓
* `Mining` → hot ✓

IV successfully recognized both sides of the workload transition. LRU failed to recognize the newly active variables, while LFU retained the historical importance of the previously active variables.

---

# Test Descriptions

**Steady Cadence**
Measures classification under stable, repeated access patterns.

**Phase Change / Role Swap**
Measures how quickly the metric responds when variables abruptly change from frequently accessed to rarely accessed, and vice versa.

**Scan Pollution**
Tests whether the metric's activity signal decays appropriately instead of treating temporary scanning/access as sustained activity.

---

# Conclusion

**Information Velocity (IV)**, Vector's data activity metric, successfully passed all three tests.

While LRU and LFU correctly classified some steady-state activity, both exhibited failure modes under changing or polluted workloads:

* **LRU** was susceptible to scan pollution and failed to recognize newly active variables during the phase change.
* **LFU** retained historical frequency and therefore failed to recognize when previously active variables became inactive.
* **IV** correctly adapted to the tested activity changes while producing no false-hot classifications during the scan-pollution test.

These tests demonstrate that IV captures information about **activity dynamics**, rather than relying solely on recency or accumulated frequency.
