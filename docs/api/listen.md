# Listen

The public signature is `Vector.Listen(entity, options, target, callback, onExpire)`. Set `options.Var` to a registered field. If `options.Type` is omitted, the API selects `"Poll"`. Only one listener entry is stored for each field, so a second registration replaces the stored entry.

## OnWrite

```luau
Vector.Listen(player, { Var = "Health", Type = "OnWrite" }, nil,
    function(entityId, fieldName, descriptor)
        print(entityId, fieldName, descriptor.Value)
    end
)

Vector.Write(player, {
    Health = { Value = 70, Type = "f32", Serial = true },
})
```

On the serial write path, the callback runs during the write and receives the write descriptor. It can run when the same value is written again. Keep the callback short because it runs inline.

## Poll with a target and deadline

```luau
Vector.Listen(player, {
    Var = "Health",
    Type = "Poll",
    Duration = 5,
}, 0, function(record)
    print("Health reached zero", record.Meta.UID)
end, function(record)
    print("Target was not reached", record.Meta.UID)
end)
```

Polling uses one shared Heartbeat connection. Each entry resolves the target, slow-map index, and expiry from its own entity record. The connection disconnects when the poll queue is empty. Fields classified as slow go through a counter check that can skip evaluation. See [Information velocity](../internals/information-velocity.md) for how fields are classified. A matching target or an expired deadline removes the poll entry. `Duration` is measured from listener registration, so it is a deadline rather than a timer that resets on writes. The callback and expiry callback receive the entity record. For a target match, pass a number or string such as `0` or `"Ready"`.

`"Event"` connects directly to the remote's `OnServerEvent`. `"Parallel"` is experimental and needs the Actor setup. There is no separate `"OnTimeout"` mode or public unsubscribe handle.
