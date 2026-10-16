# Vector ⚡
> **High-Performance, Kinematically-Synchronized State Engine for Roblox**

Vector is an event-driven, hardware-conscious state management and networking engine for Roblox. Built from first principles using numerical PDE discretization and finite-difference kinematics, Vector replaces traditional cache eviction policies (like ARC and W-TinyLFU) with continuous state velocity tracking, sub-10 microsecond latency, and native Actor parallelism.

---

## 🚀 Key Highlights

- **Adaptive Alpha ($\alpha$) Kinematics**: Dynamically computes state momentum ($v \to a \to j$) to adaptively balance noise suppression against instantaneous phase shifting.
- **Sub-10 Microsecond Operations**: Single-digit $\mu\text{s}$ `Read` and `Write` latency ($\sim 5.5\text{–}8.9\,\mu\text{s}$) fully compiled with `@native`.
- **Zero-Allocation Bit Buffers**: 8-bit quantized timestamps compactified into raw 32-bit integer words (`buffer.readu32` / `bit32`), packing 4 variables per word.
- **Actor Parallelism & Serial Reconciliation**: Isolated worker Actor VMs crunch computations off-thread, reconciling atomically on the serial boundary with zero lock contention.
- **Multi-Rate Reactive Listeners**: Event-driven listening (`OnWrite`), throttled polling (`Poll` tied to velocity maps), and non-blocking **Parallel Listeners**.
- **`OnTimeout` Expirations**: Native deadline events that fire when variables go stale or exceed active lifetimes.

---

## 📊 Benchmark Comparison

Evaluated on Luau against IBM’s **Adaptive Replacement Cache (ARC)** and Caffeine’s **W-TinyLFU**:

| Workload Scenario | Vector (Adaptive Alpha) | ARC | W-TinyLFU |
| :--- | :---: | :---: | :---: |
| **Zipfian Skew + 20 One-Hit Scan Polluters** | **100.0% F1** (100% Prec / Rec) | 87.5% F1 | 87.5% F1 |
| **Dynamic Phase Shift (Exploration $\to$ Combat)** | **100.0% F1** (Instant adaptation) | 100.0% F1 | 20.0% F1 *(stale lag)* |
| **Multi-Rate Periodic Clocks (60Hz vs 2Hz)** | **80.0% F1** (**100% Recall**) | 50.0% F1 | 75.0% F1 |
| **Cyclic Loop Thrashing ($c + 1$ Pathology)** | **100.0% Fast** | **0.0% Hit Ratio** *(collapse)* | 69.4% Hit Ratio |
| **Average Latency** | **$5.5\text{–}8.9\,\mu\text{s}$** | $0.3\,\mu\text{s}$ | $1.8\,\mu\text{s}$ |

---

## 🧠 The Mathematics Behind Adaptive Alpha

Rather than maintaining discrete cache queues or probabilistic Bloom/Count-Min sketches, Vector treats state access as a **discrete dynamical system**. 

### 1. Relative Moving Delta & Quantized Timestamps
Time is quantized into an 8-bit modular ring $\mathbb{Z}_{256}$ using a configurable `Resolution`:
$$\text{TimeBit} = \lfloor \frac{t_{\text{clock}}}{\text{Resolution}} \rfloor \pmod{256}$$

The relative finite difference $\Delta$ between the current event $T_{\text{now}}$ and previous event $T_{\text{prev}}$ is regularized to prevent singularity on back-to-back updates:
$$\Delta = \frac{|T_{\text{now}} - T_{\text{prev}}|}{T_{\text{now}} + \frac{\text{Resolution}}{10}}$$

### 2. Recursive Finite Differences
Vector recursively computes higher-order differentials:
$$\text{Velocity} \longrightarrow \text{Acceleration} \longrightarrow \text{Jerk} \longrightarrow \text{Direction}$$

### 3. Adaptive Smoothing Factor
$$\alpha = \text{clamp}\left(|\text{NJerk} - \text{NDir}|,\, 0.1,\, 0.9\right)$$

- **Steady / Burst Scan State**: Jerk is small or aligned $\implies \alpha \to 0.1$. The filter aggressively damps one-hit polluters, preventing cache corruption.
- **Phase Shift**: Workloads transition abruptly $\implies |\text{NJerk} - \text{NDir}|$ surges $\implies \alpha \to 0.9$. Vector adapts in a single cycle.

---

## 📦 Installation

Place the `Vector` folder into `ReplicatedStorage`:
```text
ReplicatedStorage/
└── Vector/
    ├── Vector           (Core engine)
    ├── API              (High-level developer interface)
    ├── Config           (Global flags)
    ├── VectorTypes      (Type definitions)
    └── UnsafeVector     (Parallel Actor interface)
```

---

## 🛠️ Quick Start

### 1. Initializing an Entity
Register a `Model` or `Player` with typed state variables:

```luau
local VectorAPI = require(game.ReplicatedStorage.Vector.API)

local character = workspace.Character

VectorAPI.Init(character, {
    Health = { Value = 100, Type = "f32" },
    Shield = { Value = 50, Type = "f32" },
    Combo = { Value = 0, Type = "number" },
    IsStunned = { Value = false, Type = "boolean" },
})
```

### 2. Writing & Reading State
Write updates with minimal overhead. Vector automatically calculates velocity and updates timebits:

```luau
-- Write state updates
VectorAPI.Write(character, {
    Health = { Value = 85, Type = "f32" },
    Combo = { Value = 1, Type = "number" }
})

-- Read state (automatically unpacked from underlying buffer)
local currentHealth = VectorAPI.Read(character, "Health")
print("Health:", currentHealth) -- 85
```

---

## 🎧 Reactive Listeners & Lifecycle Events

### Reactive Listeners (`OnWrite` vs. `Poll`)
Vector provides flexible listening mechanisms suited for different performance budgets:

```luau
-- 1. OnWrite: Lazy, event-driven (fires immediately when the variable is updated)
VectorAPI.Listen(character, {
    Var = "Health",
    Type = "OnWrite"
}, nil, function(euid, varName, newVal)
    print("Health changed to:", newVal)
end)

-- 2. Poll: Throttled heartbeat polling
-- Automatically samples at 60Hz for 'Fast' variables, throttles to 15Hz for 'Slow' variables
VectorAPI.Listen(character, {
    Var = "Shield",
    Type = "Poll"
}, nil, function(euid, varName, val)
    -- Update HUD smoothly
end)
```

### Parallel Listeners
Subscribe to state mutations directly inside worker **Actors** (`BindToMessageParallel`) without routing through the main thread, perfect for compute-heavy visual systems, AI perception, or math solvers.

### `OnTimeout` Events
Trigger callbacks when an expected update window expires:

```luau
VectorAPI.Listen(character, {
    Var = "CombatState",
    Type = "OnTimeout",
    Duration = 3.0 -- Timeout after 3 seconds of inactivity
}, nil, function(euid, varName)
    print("Player left combat (idle timeout). Resetting stance...")
end)
```

---

## ⚡ Parallel Processing Architecture

Vector leverages Roblox's **Actor Model** using a **Shared-Nothing** design:

```
                      ┌──────────────────────┐
                      │    Vector.Write()    │
                      └──────────┬───────────┘
                                 │
                   ┌─────────────┴─────────────┐
                   ▼                           ▼
          [Parallel Actor 1]          [Parallel Actor 2]
         (BindToMessageParallel)     (BindToMessageParallel)
          - Computes Velocity         - Computes Velocity
          - Packs Buffer Timestamps   - Packs Buffer Timestamps
                   │                           │
                   └─────────────┬─────────────┘
                                 │ Message ("res")
                                 ▼
                     ┌───────────────────────┐
                     │     module.Serial     │
                     │  (Main Thread Barrier)│
                     │ - Atomic VectorField  │
                     └───────────────────────┘
```

1. **Greedy Work Distributor**: `Unsafe.Distribute` dispatches write batches to whichever Actor thread has the lowest current work counter.
2. **Local Worker Memory**: Actors mutate only isolated memory spaces. No `SharedTable` lock contention.
3. **Serial Synchronization**: Results message back (`"res"`) into `module.Serial` to atomically reconcile into the canonical `VectorField`.

---

## ⚙️ Configuration (`Config.luau`)

```luau
return {
    Parallel = true,          -- Enable Actor multi-threading distribution
}
```

---

## 📜 License
MIT License. Created by GreenModt.
