Code.require_file "../test_helper.exs", __FILE__

defmodule LambdaTest do
  use ExUnit.Case
  import Lambda

  test "lambda tests" do
    assert is_function(ld _1)
    assert ld(1 + 2).() == 3
    assert ld(_1).(2) == 2
    assert ld(_2).(2, 3) == 3
    assert ld(_1.abs(-1)).(Kernel) == 1
    assert ld(_1 * ld(_2).(3, 4)).(2) == 8
    assert ld(4, _2 + 3).(:a, 2, :c, :d) == 5
  end

  defrecord TestRecord, [a: 0, b: 0] do
    import Lambda

    def create do
      new
      |> ldl(a(1))
      |> ldl(b(2))
      |> ldl(update_a(&(&1 + 2)))
    end
  end

  test "pipe tests" do
    assert (
      1
      |> ldp(_1 + 2)
      |> ldp(_1 * 2)
    ) == 6
  end

  test "record tests" do
    assert (
      TestRecord.new
      |> ldl(TestRecord.a(1))
      |> ldl(TestRecord.b(2))
      |> ldl(TestRecord.update_a(&(&1 + 2)))
    ) == TestRecord.new(a: 3, b: 2)

    assert TestRecord.create == TestRecord.new(a: 3, b: 2)
  end
end
