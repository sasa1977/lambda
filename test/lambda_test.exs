Code.require_file "../test_helper.exs", __FILE__

defmodule LambdaTest do
  use ExUnit.Case
  import Lambda

  test "lambda tests" do
    assert is_function(%f(&1))
    assert %f(1+2).() == 3
    assert %f(&1).(2) == 2
    assert %f(&2).(2,3) == 3
    assert %f[&1.abs(-1)].(Kernel) == 1
    assert %f{&1 * %f[&2].(3,4)}.(2) == 8
    
    assert %f(1, 1+2).(1) == 3
  end
end
