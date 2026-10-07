# Vector

Vector is an experimental Luau runtime for adaptive temporal state activity tracking. It measures relative write activity, filters micro-churn with dynamic resolution, and separates fields into fast and slow activity planes. Designed for bursty game-state data where hot and cold values should be treated differently.
=======

Adaptive temporal state activity tracking for Luau-based game data.

Vector is an experimental runtime data layer designed for stateful systems where not all fields are equally active. Instead of treating every value as equally important, it tracks relative write activity over time and separates data into fast and slow activity planes.

This project is currently a prototype and research-oriented implementation intended for benchmarking, testing, and iteration. It is not yet a finalized public-facing library API.

## What it does

The core idea is to classify state by temporal activity rather than by raw count or recency alone.

- Tracks when values are written
- Measures relative activity rate over time
- Uses adaptive resolution to ignore insignificant micro-churn
- Groups fields into fast and slow activity classes
- Stores metadata in compact, bit-oriented structures
- Optimizes for bursty game-state workloads rather than generic cache behavior

## Why it exists

Most basic data systems treat values as either active or inactive based on recency or frequency. This project instead aims to model activity as a signal over time.

That means:

- noisy, jittery values can be ignored below a meaningful threshold
- important bursty fields can be detected and prioritized
- system load can be split between high-churn and low-churn data
- engine logic can react to temporal state behavior instead of static counts alone

## Current status

This repository is in active development.

-Public API Incomplete

## Project structure

- `Vector/init.luau` — core runtime logic
- `Vector/VectorTypes.luau` — type definitions and metadata contracts
- `Vector/VectorField.luau` — field state container abstraction
- `Vector/UnsafeVector.luau` — experimental write/distribution logic
- `Vector/Replicator.local.luau` — local replication hook example

## Design direction

This project is meant to explore a more adaptive model for runtime data activity.

The main principles are:

- dynamic resolution based on signal characteristics
- relative rate-of-activity measurement
- hot/cold partitioning of state
- low-level optimization for field-heavy simulation data

## Important caveat

This is a prototype and may change substantially as the benchmarking and API design evolve.


## License

MIT License in LICENSE.md

## Notes

This project is currently in testing, It is designed for databases with stateful/active variables such as games.


>>>>>>> 351447b (Vector)
