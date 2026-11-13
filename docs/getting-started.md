# Getting started

Set up the library as a ModuleScript named `Vector` in `ReplicatedStorage`. Use `Vector/init.luau` as the root module, with `API`, `Config`, `VectorField`, `VectorTypes`, `Matrix`, `MatrixField`, and `UnsafeVector` as child modules. Add a RemoteEvent named `Shallow` under the root module. To receive updates on clients, put `Replicator.local.luau` in `StarterPlayerScripts` as a LocalScript.

The server-side import waits for two Actors named exactly `ParalleVector1` and `ParalleVector2` under `ServerScriptService`, even when parallel writes are disabled. Create those Actors before requiring the API. For the serial example below, set `Parallel = false` and leave `Experimental = false` in `Config`. See [Parallelism](internals/parallelism.md) for the worker scripts.

Run this from a server Script after the player joins:

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vector = require(ReplicatedStorage.Vector.API)

Players.PlayerAdded:Connect(function(player)
    Vector.Init(player, {
        Health = { Value = 100, Type = "f32" },
        Stamina = { Value = 100 },
    })

    Vector.Write(player, {
        Health = { Value = 85, Type = "f32", Serial = true },
    })

    print(Vector.Read(player, "Health")) -- 85
end)
```

Pass the player or model instance to the public API. Player records are keyed by `UserId`. Model records use a CollectionService tag. The implementation takes the model's first returned tag as its key, so use a player for the first test and avoid relying on tag order for models with other tags.

For replication, the client listener needs the entity's initial `Sync` before it can apply a `Batch` for that entity.
