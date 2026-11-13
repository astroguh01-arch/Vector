# Write

`Vector.Write(entity, fields)` accepts a player or model that has been registered with `Vector.Init`. Pass a table keyed by field name, with a descriptor for each field.

```luau
Vector.Write(player, {
    Health = { Value = 85.5, Type = "f32", Serial = true },
    Stamina = { Value = 70, Serial = true },
})
```

| Descriptor key | Effect |
| --- | --- |
| `Value` | The value to store. |
| `Type` | Optional encoding label. When omitted, the write uses `typeof(Value)`, so repeat an explicit label such as `"f32"` on later writes. |
| `Serial` | Set to `true` to skip the parallel write branch for this field. |
| `Critical` | Recorded when a field is added. During initialization, critical descriptors are also placed in the rollback table. |

On the serial path, updating an existing field updates its access timing, invokes its `OnWrite` listener, and queues a replication record. The first queued write schedules a flush after 0.5 seconds. Later writes can join that batch. A write can add a missing field, but declaring fields in `Init` gives them a timestamp slot up front.

Use the keyed form even for a single field. `Target` is a special top-level key used for [matrix writes](matrices.md). Ordinary writes should omit it.
