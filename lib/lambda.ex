defmodule Lambda do
  @moduledoc """
  Syntactic sugar for defining lambda functions with explicit scope.

  Example:
    defmodule MyModule do
      import Lambda

      def test do
        Enum.map(1..2, %f({&1, &1*&1}))
      end
    end

  Anything inside %f(...) is turned into an anonymous function
  """
  
  defrecord ParseResponse, code: nil, arity: 0 do
    def new_list, do: new(code: [])

    def push(response, this) do
      this.
        update_arity(max(response.arity, &1)).
        update_code([response.code | &1])
    end
    
    def to_tuple(this), do: this.update_code(list_to_tuple(&1))
  end
  
  defmacro __f__({:<<>>, line, [string]}, _) do
    case Code.string_to_ast!("{#{string}}", line) do
      {:"{}", _, [code]} -> def_fun(parse_code(code))
      {arity, code} -> def_fun(parse_code(code).arity(arity))
    end
  end
  
  defp def_fun(parse_result) do
    quote do
      fn unquote_splicing(args(parse_result.arity)) ->
        unquote(parse_result.code)
      end
    end
  end
  
  defp args(arity) do
    Enum.map(0..arity, fn(arg) -> 
      {:"_#{arg}", [], nil}
    end) |> tl
  end
  
  defp parse_code({:"&", _, [index]}) do
    ParseResponse.new(
      code: {:"_#{index}", [], nil},
      arity: index
    )
  end
  
  defp parse_code(tuple) when is_tuple(tuple) do
    parse_code(tuple_to_list(tuple)).to_tuple
  end
  
  defp parse_code(list) when is_list(list) do
    List.foldr(list, ParseResponse.new_list, fn(element, parse_response) ->
      parse_response.push(parse_code(element))
    end)
  end
  
  defp parse_code(other), do: ParseResponse.new(code: other)
end