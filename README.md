# Lambda

Syntactic sugar for defining lambda functions with explicit scope. Supports short lambda definitions which are not possible with Elixir capture syntax.

```elixir
  import Lambda

  ld(_1 + _2 + _3)    # same as &(&1 + &2 + &3)
  ld(1 + 2)           # zero arity function
  ld(_1)              # identity function
  ld(_2 * 2)          # guesses arity from the highest index, not all arguments have to be used
  ld(4, _2 + 3)       # explicitly set arity to 4, not all arguments have to be used 
```

In addition, two macros are included to compensate for pipeline shortcomings.
The macro ldp can pipeline to any argument in the function call:

```elixir
  :gb_trees.empty
  |> ldp(:gb_trees.enter(:a, 1, _1))
  |> ldp(:gb_trees.enter(:b, 2, _1))
```

When pipelining to the last argument, this can be shortened with the ldl macro:

```elixir
  :gb_trees.empty
  |> ldl(:gb_trees.enter(:a, 1))
  |> ldl(:gb_trees.enter(:b, 2))
```

ldl is specifically useful with records pipelining:

```elixir
  defrecord TestRecord, [a: 0, b: 0] do
    import Lambda

    def create do
      # pipelining inside the record module
      new
      |> ldl(a(1))
      |> ldl(b(2))
      |> ldl(update_a(&(&1 + 2)))
    end
  end

  # pipelining outside the record module
  TestRecord.new
  |> ldl(TestRecord.a(1))
  |> ldl(TestRecord.b(2))
  |> ldl(TestRecord.update_a(&(&1 + 2)))
```