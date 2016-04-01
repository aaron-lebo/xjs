defmodule XJS do
  def compile(value) when
    is_number(value) or is_bitstring(value) do
    %{
      type: :Literal,
      value: value
    }
  end

  def compile({:fun, _, tail}) do
    {params, [[do: body]]} = Enum.split tail, -1
    %{
      type: "ArrowExpression",
      params: Enum.map(params, fn x -> compile x  end),
      body: compile(body)
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

  def compile({operator, _, [left, right]}) when
    operator in [:*, :/, :+, :-] do
    %{
      type: :BinaryExpression,
      operator: operator,
      left: compile(left),
      right: compile(right)
    }
  end

  def compile({kind, _, [{:=, _, [head, body]}]}) when
    kind in [:con, :let] do
    %{
      type: :VariableDeclaration,
      declarations: %{
        type: :VariableDeclarator,
        id: compile(head),
        init: compile(body)
      },
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
    %{error: node}
  end

  defmacro xjs(do: block) do
    case block do
      {:__block__, _, ast} -> Enum.map ast, &XJS.compile/1
      ast -> compile ast
    end
    |> Poison.encode!
  end

  def test() do
    xjs do
      0 + 1
    end
  end
end
