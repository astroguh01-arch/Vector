# Compression and replication

Vector uses buffers for field values and separately packs [access timestamps](information-velocity.md). The value format depends on the descriptor's type label.

| Value | Buffer format |
| --- | --- |
| Number labeled `f32` | Rounded to two decimal places, then written as a four-byte float. |
| Other numbers | Eight-byte float. The decoder recognizes `number` and `f64`. |
| `Vector3` | Three four-byte floats at offsets 0, 4, and 8. |
| Boolean | One byte with 0 or 1. The byte decoder checks for the label `Bool`. |

## Storage encoding

`Serialize` walks `record.Data`, converts supported values into buffers, and marks the record compact. It skips tables and existing buffers. For `Vector3` fields it reads components from `descriptor.Value`. `Deserialize` reverses recognized encodings in place and clears the record's compact flag. `Read` instead decodes a local value for one field.

When `Alpha > 0.4`, `Compress` attempts Zstd compression for fields in the slow map and sets each compressed descriptor's `Encoded` flag. The current compression pass skips descriptors already flagged as encoded. `Read` decompresses its local buffer before decoding, so the stored bytes and flag stay together during that operation.

## Replication messages

| Operation | Payload and client behavior |
| --- | --- |
| `Sync` | Registration broadcasts a record through `Shallow`. The client stores it by entity ID and deserializes its fields. |
| `Batch` | The server sends a list of updates. Each entry carries `UID`, `Index` (the field name), `Data`, and `Type`, plus `Compressed` when set by the batch encoder. The client applies updates only to records already present in its field table. |
| `Correction` | The handler receives a field name and descriptor and assigns that descriptor to the client record. |

A serial write queues the input value for replication separately from the stored descriptor. The first write schedules a flush after 0.5 seconds. Subsequent writes join that batch until it is sent and the queue is reset. The normal Vector flush calls `Serde(batch, true)` before broadcasting; matrix writes use a separate queue and call their encoder with compression disabled.

The wire flag `Compressed` belongs to a batch entry, whereas `Encoded` belongs to a stored descriptor. The batch decoder decompresses when `Compressed` is set, then decodes recognized buffer types.

The client uses the initial snapshot to identify the entity and its fields when applying later updates.
