defmodule XJS do
  @statements [
    :LetStatement,
    :VariableDeclaration
  ]

  def compile(value) when is_number(value) or is_bitstring(value) do
    %{
      type: :Literal,
      value: value
    }
  end

  def compile(node) when is_list(node) do
    %{
      type: :ArrayExpression,
      elements: Enum.map(node, fn n -> compile(n) end)
    }
  end

  def compile({:%{}, _, tail}) do
    %{
      type: :ObjectExpression,
      properties: []
    }
  end

  def compile({:body, body}) when is_tuple body do
    compile {:body, [body]}
  end

  def compile({:body, body}) do
    Enum.map(body, fn node ->
      node = compile node
      case Map.get node, :type do
        type when type in @statements -> node
        _ -> %{
             type: :ExpressionStatement,
             expression: node
         }
      end
    end)
  end

  def compile({:fun, _, tail}) do
    {params, [[do: body]]} = Enum.split tail, -1
    %{
      type: :FunctionExpression,
      params: Enum.map(params, fn x -> compile x end),
      body: %{
        type: :BlockStatement,
        body: compile({:body, body})
      }
    }
  end

  def compile({:=, _, [left, right]}) do
    %{
      type: :AssignmentExpression,
      operator: :=,
      left: compile(left),
      right: compile(right)
    }
  end

  def compile({operator, _, [left, right]}) when operator in [:*, :/, :+, :-] do
    %{
      type: :BinaryExpression,
      operator: operator,
      left: compile(left),
      right: compile(right)
    }
  end

  def compile({kind, _, [{:=, _, [head, body]}]}) when kind in [:con, :let] do
    %{
      type: :VariableDeclaration,
      declarations: [%{
        type: :VariableDeclarator,
        id: compile(head),
        init: compile(body)
      }],
      kind: kind == :con && :const || :let
    }
  end

  def compile({name, _, nil}) do
    %{
      type: :Identifier,
      name: name
    }
  end

  def compile(node) do
    %{error: node} |> IO.inspect
  end

  defmacro xjs(do: block) do
    case block do
      {:__block__, _, ast} -> ast
      ast -> [ast]
    end
    |> Enum.map(fn x -> compile x end)
    |> Macro.escape
  end
end
