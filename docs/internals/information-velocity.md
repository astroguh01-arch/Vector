# Classification

Vector measures the timing of accesses to a field. It does not compare the old and new field values when classifying a field. Reads and updates to existing fields evaluate velocity before recording a fresh field timestamp.

## Field indices and timestamp layout

`Meta.IDs` maps numeric slots to field names. The bitmap builder allocates 36-byte groups. The first four bytes form a 32-bit occupancy mask, and the next 32 bytes provide one timestamp byte per field. `BitIndex` selects a group using `ceil(fieldId / 32)`.

```text
tick = floor(time / resolution) % 256
```

For the first four fields in a group, the timestamp word begins at byte offset 4. Each field uses a different shift within that word: 0, 8, 16, or 24 bits. `TimeBit` reads the word, clears that slot with a mask, and inserts the new tick. Because the stored tick wraps every 256 steps, a timestamp byte alone does not tell you the absolute time.

## Resolution and timing samples

`CycleTime` uses elapsed `os.clock()` time and the current resolution to update the record's cycle counter. `Resolution` derives a new resolution from the precision of a timing value based on `Meta.LastUpdate`. Velocity calculations use both the resolution and the cycle counter to scale the quantized times.

## Velocity

A scalar's velocity sample describes the timing of its accesses. On a read or an update to an existing field, Vector compares the current quantized time with the field's previous timestamp before recording the new access.

```text
velocity = abs(currentTime - previousFieldTime) / (currentTime + resolution / 10)
```

The denominator scales the difference relative to the current time estimate. The resolution term keeps the denominator positive near zero. This gives each field a timing sample that can be compared with the same entity's reference. For example, repeatedly reading Health can change its classification even if its value stays at 100.

## Acceleration

Acceleration describes changes in the entity's access timing. The sampler computes a velocity-like delta using the entity's last update time as its reference, then stores the sample in `Meta.Snapshots.Velocity`. Every pair of samples produces one acceleration value:

```text
acceleration = abs(newVelocity - previousVelocity)
               / (previousVelocity + resolution / 10)
```

The sampler clears the velocity pair after using it and appends the result to `Meta.Snapshots.Acceleration`. Similar timing samples produce a small acceleration. A larger difference relative to the previous sample produces a larger one.

## Jerk

Once two acceleration samples are available, Vector measures how much acceleration changed and records the direction of that change.

```text
direction = newAcceleration - previousAcceleration
jerk = abs(direction) / (previousAcceleration + resolution / 10)
```

Direction retains the sign. Jerk measures the size of the change relative to the previous acceleration. Vector stores both values on the entity and clears the acceleration samples so the next pair can be collected.

## Alpha

Alpha sets how much weight the current timing reference gets. Until jerk and direction are available, the function returns 0.4. After that it normalizes the two signals, combines them, and bounds the result:

```text
normalizedJerk = jerk / (jerk + resolution / 10)
normalizedDirection = direction / (direction + resolution)
alpha = clamp(abs(normalizedJerk + normalizedDirection), 0.1, 0.9)
```

An alpha of 0.1 gives the current timing term 10% of the weight and the previous reference 90%. An alpha of 0.9 reverses those weights. Vector applies the timing scale after blending and compares the smoothed result with the current entity reference to compute `Meta.DeltaRV`. The current reference is the mean of the entity's quantized last update and the reference timestamp found by scanning its fields.

When Vector calculates alpha from samples, it also invokes the adaptive compression path. That path uses alpha and the slow map to select stored values. See [Compression and replication](compression.md).

## Fast and slow fields

The classifier compares the access delta against `Meta.DeltaRV` with a gate of `0.4 * resolution`. A delta above the upper bound marks the field slow, a delta below the lower bound marks it fast, and a delta between the bounds preserves its previous classification. The maps use numeric field IDs as keys and field names as values.

The polling loop resolves the field name in the current entity's `Meta.IDs` before checking that entity's slow map. Slow entries go through an additional counter check that can skip evaluation. The shared counter and Heartbeat scheduling do not imply a fixed sampling frequency.
