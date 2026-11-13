# Matrices

A Matrix is an unowned entity table. It has its own name and groups shared scalars independently of any Roblox player or model. Writers identify themselves when updating a field, and a per-field lock decides which writer can apply the change.

```luau
Vector.Init(nil, {
    Matrix = true,
    Name = { Value = "Arena" },
    Round = { Value = 1 },
})

-- Use a player or registered model as the writer.
Vector.Write(player, {
    Target = "Arena",
    Round = { Value = 2 },
})
```

`Matrix = true` belongs alongside the fields in this example. `Name.Value` becomes the key in `MatrixField`. Declare the fields at initialization before writing to them. The write wrapper uses `Target` to look up the matrix and the entity ID to identify the writer. Check the spelling of the target. If it does not resolve to a matrix, the wrapper falls through to the ordinary entity write path.

For a server-side lookup, the internal module exposes `Matrix.Read("Arena", "Round")`. The public `API.Read`, `Get`, and `Listen` resolve entity state instead.

## Contended writes and ranking

Locks apply to individual fields. An unowned field grants its lock to the requesting writer. The owner can release the lock by calling the lock operation again. A competing writer initially receives `"Locked"` and increments the lock's attempt counter. Once the counter is greater than two, the next competing attempt can take ownership based on rank.

- **Explicit rank.** Your game decides how to rank writers. The core function `Vector.Rank(matrixId, writerId, rank)` records the rank you supply. When both writers have explicit ranks, the contender must have a strictly higher rank than the current owner.
- **Velocity rank.** If either writer lacks an explicit rank, the lock compares their velocity ranks. The contender must have a strictly lower velocity-rank value than the owner. Both values must be present for this comparison to grant ownership.

A successful takeover returns `"Stolen"` and resets the attempt counter. `Matrix.Write` applies the field update after either `"Granted"` or `"Stolen"`, then releases the lock.

Matrix writes batch updates separately and schedule a flush after 0.5 seconds. Their batch encoder is called with compression disabled.
