defmodule Lambda do
  @moduledoc """
  Syntactic sugar for defining lambda functions with explicit scope.
  See README.md for examples.
  """
  
  defrecordp :parser_state, [ast: nil, arity: 0]

  defp push_ast(
    parser_state(ast: current_ast, arity: current_arity),
    parser_state(ast: new_ast, arity: new_arity)
  ) do
    parser_state(
      ast: [new_ast | current_ast],
      arity: max(current_arity, new_arity)
    )
  end

  defp state_to_tuple(parser_state(ast: current_ast) = state) do
    parser_state(state, ast: list_to_tuple(current_ast))
  end

  defmacro ld(arity, ast) do
    ast
    |> parse_ast
    |> parser_state(arity: arity)
    |> def_fun
  end

  defmacro ld(ast) do
    ast
    |> parse_ast
    |> def_fun
  end

  defmacro ldp(arg, ast) do
    ast = parse_ast(ast)
    if parser_state(ast, :arity) != 1, do: raise(CompileError, message: "arity is not 1")
    fun = def_fun(ast)
    quote do
      unquote(fun).(unquote(arg))
    end
  end

  defmacro ldl(arg, {_, _, args} = fun_call) do
    quote do
      ldp(unquote(arg), unquote(set_elem(fun_call, 2, args ++ [quote do: _1])))
    end
  end
  
  defp def_fun(parser_state(ast: ast, arity: arity)) do
    quote do
      fn(unquote_splicing(args(arity))) ->
        unquote(ast)
      end
    end
  end
  
  defp args(arity) do
    Enum.map(0..arity, fn(arg) -> 
      {:"_#{arg}", [], nil}
    end) |> tl
  end

  defp parse_ast({:ld, _, _} = other), do: parser_state(ast: other)
  
  defp parse_ast({arg, _, _} = tuple) when is_atom(arg) do
    case to_string(arg) do
      "_" <> index -> 
        case Regex.match?(%r/\A\d+\z/, index) do
          true -> 
            parser_state(
              ast: {:"_#{index}", [], nil},
              arity: binary_to_integer(index)
            )
          false -> parse_tuple(tuple)
        end
      _ -> parse_tuple(tuple)
    end
  end
  
  defp parse_ast(tuple) when is_tuple(tuple), do: parse_tuple(tuple)
  
  defp parse_ast(list) when is_list(list) do
    List.foldr(list, parser_state(ast: []), fn(element, parser_state) ->
      push_ast(parser_state, parse_ast(element))
    end)
  end

  defp parse_ast(other), do: parser_state(ast: other)

  defp parse_tuple(tuple) do
    tuple
    |> tuple_to_list
    |> parse_ast
    |> state_to_tuple
  end
end