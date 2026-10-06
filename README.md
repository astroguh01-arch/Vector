# Vector
<<<<<<< HEAD
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

- The internal model is the focus
- The public-facing API is intentionally minimal or incomplete
- Debug instrumentation is expected to be removed before public release
- Benchmarking and external testing are part of the next phase

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

This is a prototype and may change substantially as the benchmarking and API design evolve. The codebase is expected to evolve quickly as the model is validated against real-world workloads.

## Testing and benchmarking plan

Before release, the project should be evaluated under several conditions:

- static vs dynamic resolution behavior
- bursty writes vs stable fields
- noisy update patterns
- fast/slow plane balance
- replication and state update overhead
- memory overhead and metadata cost

## License

This project does not currently declare a license. If you plan to publish it publicly, add a license file before distributing it to others.

## Notes

This project is best viewed as an experimental temporal state system rather than a generic math utility library. It is primarily designed for state-heavy, burst-driven applications.

---

## Short description for GitHub

Vector is an experimental Luau runtime for adaptive temporal state activity tracking. It measures relative write activity, filters micro-churn with dynamic resolution, and separates fields into fast and slow activity planes. Designed for bursty game-state data where hot and cold values should be treated differently. Early-stage, benchmark-oriented, and intended for experimentation.
>>>>>>> 351447b (Vector)
