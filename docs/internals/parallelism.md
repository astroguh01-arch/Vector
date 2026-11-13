# Parallelism

Vector has a serial write path and an optional Actor dispatch branch. Start with the serial path when integrating the library. Set `Parallel = false` in `Config`, or set `Serial = true` on every descriptor in a write that must stay on the serial path.

## Actor layout

```text
ServerScriptService/
  ParalleVector1/      Actor
    ActorScript        Script
    Unsafe             ModuleScript
  ParalleVector2/      Actor
    ActorScript        Script
    Unsafe             ModuleScript
```

Use `ActorScript.legacy.luau` and `Unsafe.luau` as the sources for each Actor's children. The spelling in the tree matches `UnsafeVector.luau`. On the server, that module waits for both Actors at import time independently of the `Parallel` setting.

## Dispatch and reconciliation

When parallel writes are enabled and a descriptor does not specify `Serial`, `CheckRate` compares the current timing delta with a smoothed threshold. If the threshold is crossed, `UnsafeVector.Distribute` sends a `Write` message to the Actor with the lower tracked work count. The Actor scripts include `Sync` and `res` messages, and the `Unsafe.Serial` path reconciles returned descriptors into the entity's field table and invokes applicable write listeners.

## Write gate and worker counters

The gate in `CheckRate` uses a resolution of 0.1 seconds and compares the quantized current time with `Vector.GlobalUpdate`. Once `Vector.Delay` has been initialized, the gate blends the current delta with the stored delta using weights of 0.4 and 0.6. Dispatch is attempted only when the current delta exceeds that gate. This calculation uses global access timing, whereas the fast and slow maps use each entity's [field timestamps](information-velocity.md).

`Distribute` increments the selected worker's `Work` counter and picks the first worker on a tie. The root module subtracts the counts returned by the reconciliation calls. Those counts describe reconciled descriptors and are not measurements of CPU utilization.

## Message flow

| Message | Role in the current code |
| --- | --- |
| `Write` | Carries the entity ID and a descriptor with its field index. The Actor handler passes it to `UnsafeWrite`. |
| `Sync` | Carries staged writes to the Actor's message handler, which sends them back as `res`. |
| `res` | The serial handler stores the returned writes and calls `Unsafe.Serial` to apply them to the field table. |
| `Listen`, `Sound`, `Call` | Carry experimental listener registrations, match checks, and match results. |

Reconciliation assigns descriptors to the live record, refreshes the listener's cached value, and invokes its inline `OnWrite` callback when present. The send and the serial reconciliation call do not form a blocking request and response. A read immediately after dispatch can still see the previous value.
