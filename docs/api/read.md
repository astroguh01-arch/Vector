# Read

Call `Vector.Read(entity, fieldName)` with a registered player or model and an existing field name.

```luau
local health = Vector.Read(player, "Health")
print(health)
```

The reader decodes recognized numeric and vector buffers and returns an ordinary value directly if the field is already unpacked. Reads update access timing, so frequent reads can influence the field's [velocity classification](../internals/information-velocity.md).

Initialize the entity and field before reading. Check the schema when you need to know whether a field exists.

## Inspecting multiple fields

```luau
local fields, entityId = Vector.Get(player)
print(entityId, fields.Health.Type)
```

`Get` returns a frozen shallow copy of the field table and the entity ID. The nested descriptors are shared, and their `Value` entries can contain buffers. Use `Read` for decoded values and `Write` for updates.

Use `Type = "Bool"` to read a packed boolean as the numeric value 0 or 1.
