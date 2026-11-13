# Scalars

A scalar is one named value inside a Vector or Matrix. For example, Health is a scalar with the value 100. Its descriptor holds the value and its storage type.

```luau
Health = { Value = 100, Type = "f32" }
```

The name is the key in the parent table. If you omit `Type`, Vector infers it from `Value`. The term scalar describes one field in the state model. That field can also hold a Roblox value such as a `Vector3`.

Use [Write](write.md) to update a scalar, [Read](read.md) to retrieve it, and [Listen](listen.md) to observe writes or poll for a target. See [Classification](../internals/information-velocity.md) for how access timing is tracked.
