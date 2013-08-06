defmodule Lambda do
  @moduledoc """
  Syntactic sugar for defining lambda functions with explicit scope.
  See README.md for examples.
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

  defmacro ld(arity, code) do
    def_fun(parse_code(code).arity(arity))
  end

  defmacro ld(code) do
    def_fun(parse_code(code))
  end

  defmacro ldp(arg, code) do
    code = parse_code(code)
    if code.arity != 1, do: raise(CompileError, message: "arity is not 1")
    fun = def_fun(code)
    quote do
      unquote(fun).(unquote(arg))
    end
  end

  defmacro ldl(arg, {_, _, args} = fun_call) do
    quote do
      ldp(unquote(arg), unquote(set_elem(fun_call, 2, args ++ [quote do: _1])))
    end
  end
  
  defp def_fun(parse_result) do
    quote do
      fn(unquote_splicing(args(parse_result.arity))) ->
        unquote(parse_result.code)
      end
    end
  end
  
  defp args(arity) do
    Enum.map(0..arity, fn(arg) -> 
      {:"_#{arg}", [], nil}
    end) |> tl
  end

  defp parse_code({:ld, _, _} = other), do: ParseResponse.new(code: other)
  
  defp parse_code({arg, _, _} = tuple) when is_atom(arg) do
    case to_binary(arg) do
      "_" <> index -> 
        case Regex.match?(%r/\A\d+\z/, index) do
          true -> 
            ParseResponse.new(
              code: {:"_#{index}", [], nil},
              arity: binary_to_integer(index)
            )
          false -> parse_code(tuple_to_list(tuple)).to_tuple
        end
      _ -> parse_code(tuple_to_list(tuple)).to_tuple
    end
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