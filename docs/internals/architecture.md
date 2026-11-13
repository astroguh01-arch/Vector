# Records and data flow

The public `API` module resolves Roblox instances to entity IDs. The root `Vector` module uses those IDs to manage records in `VectorField`. The client replicator also uses `VectorField`, but the client has its own copy. `MatrixField` holds a separate set of named records.

| Record member | Contents |
| --- | --- |
| `Data` | Descriptors keyed by field name. Each descriptor stores `Value` and `Type`, and may have flags such as `Critical` or `Encoded`. |
| `Meta` | Record identity, field indices, access timing, listener entries, and flags such as `Valid` and `Compact`. |
| `Prev` | Descriptors saved during registration for fields marked `Critical`. |

## Registration and identity

`API.Init` accepts either a field table or a wrapper with a `Data` member. The root module fills in missing type labels using `typeof`, registers the record, serializes its values, and builds the timestamp bitmap for ordinary entity records. Registration uses the player's `UserId` or the model's first CollectionService tag as the lookup key. For matrices, the key is `Name.Value` and registration uses a different metadata layout.

The registration path also broadcasts `Sync`. This is the snapshot the client needs before it can apply later batches. See [Compression and replication](compression.md) for the wire format and delivery behavior.

## Serial reads and writes

On a read, Vector resolves the descriptor, decompresses the local value if required, and decodes recognized buffer types. It also updates record-level access times, evaluates field timing, and stores the field's latest timestamp.

On a serial write, Vector replaces the existing field's value and type, or creates a descriptor and appends the field name to `Meta.IDs`. An existing field also goes through velocity evaluation and timestamp recording. The write then updates the listener's cached value, calls an inline `OnWrite` callback when present, and queues a replication entry. The call serializes the record if it was marked noncompact and schedules a batch flush if one is pending for the first time.

`Get` freezes a shallow clone of the field table. Its descriptors still reference the original data. Mutating one directly can bypass timestamp updates, listeners, and batch queuing.

## Listener ownership

The serial write path updates the listener entry under the entity's `Meta.Listening[fieldName]`. The shared Heartbeat connection walks `PollT`. Each poll entry supplies its entity ID and field name, and the loop resolves its target, field index, and expiry from that entity. See [Listen](../api/listen.md) for callback arguments and deadline examples.

## Rollback and matrix locks

`Rollback` deserializes a record, copies entries from `Prev` into `Data`, then serializes again. The global form iterates through `VectorField`.

A matrix write takes a separate route through `Matrix.Write`. Its lock records live in `Meta.Dot` and are keyed by field. The matrix uses its own batch and encoder. See [Matrices](../api/matrices.md) for the contention rules, caller-defined ranks, and velocity-rank fallback.
