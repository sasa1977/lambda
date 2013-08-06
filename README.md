# Lambda

Syntactic sugar for defining lambda functions with explicit scope. Supports short lambda definitions which are not possible with Elixir capture syntax.

```elixir
  import Lambda

  ld(1 + 2)       # zero arity function
  ld(_1)          # identity function
  ld(_2 * 2)      # gueses arity from the highest index
  ld(4, _2 + 3)   # explicitly set arity to 4
```

In addition, two macros are included to compensate for pipeline shortcomings.
The macro ldp can be used in pipeline chain. This is especially useful if we need to pipe to an argument which is not the first one:

```elixir
  [1, 2, 3]
  |> ldp(:lists.nth(3, _1))
  |> ldp(_1 + 2)
  |> ldp(_1 * 2)
```

The macro ldl is specifically designed to provide pipelining support for records. It assumes its argument is a function call, and appends the left side of the pipeline as the last argument of the call:

```elixir
  defrecord TestRecord, [a: 0, b: 0] do
    import Lambda

    def create do
      new
      |> ldl(a(1))
      |> ldl(b(2))
      |> ldl(update_a(&(&1 + 2)))
    end
  end

  # ldl can also be used for calls to other modules:
  TestRecord.new
  |> ldl(TestRecord.a(1))
  |> ldl(TestRecord.b(2))
  |> ldl(TestRecord.update_a(&(&1 + 2)))
```