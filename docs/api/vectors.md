# Vectors

A Vector is an entity table that groups named [scalars](scalars.md) for a Roblox player or model. The entity gives the table its identity. Player Vectors use the player's `UserId`, and model Vectors use an entity tag.

```luau
Vector.Init(player, {
    Health = { Value = 100, Type = "f32" },
    Stamina = { Value = 80, Type = "f32" },
})
```

Here, the player owns the Vector and Health and Stamina are two scalars in that Vector. Pass the player to [Write](write.md), [Read](read.md), or [Listen](listen.md) to work with those fields. For state shared independently of a player or model, use a [Matrix](matrices.md).

Internally, the Vector record holds field descriptors, entity metadata, and access timing. See [Records and data flow](../internals/architecture.md).
