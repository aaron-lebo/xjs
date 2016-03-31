defmodule XJS do
  defmodule Program do
    @derive [Poison.Encoder]

    defstruct [:body]
  end

  def literal(value) do
    [
      type: :Literal,
      value: value
    ]
  end

  def compile(node) when
    is_number(node) do
    literal node
  end

  def compile(node) when
    is_bitstring(node) do
    literal node
  end

  def compile({:fun, _, tail}) do
    {params, [[do: body]]} = Enum.split tail, -1
    [
      type: :ArrowExpression,
      params: Enum.map(
        is_tuple(params) && [params] || params,
        &XJS.compile/1
      ),
      body: compile(body)
    ]
  end

  def compile({:=, _, [left, right]}) do
    [
      type: :AssignmentExpression,
      operator: :=,
      left: compile(left),
      right: compile(right)
    ]
  end

  def compile({operator, _, [left, right]}) when
    operator in [:*, :/, :+, :-] do
    [
      type: :BinaryExpression,
      operator: operator,
      left: compile(left),
      right: compile(right)
    ]
  end

  def compile({kind, _, [{:=, _, [head, body]}]}) when
    kind in [:con, :let] do
    [
      type: :VariableDeclaration,
      declarations: [
        type: :VariableDeclarator,
        id: compile(head),
        init: compile(body)
      ],
      kind: kind == :con && :const || :let
    ]
  end

  def compile({name, _, nil}) do
    [
      type: :Identifier,
      name: name
    ]
  end

  def compile(node) do
    {:error, node}
  end

  defmacro xjs(do: block) do
    case block do
      {:__block__, _, ast} -> Enum.map ast, &XJS.compile/1
      ast -> compile ast
    end
  end

  def test() do
    xjs do
      fun x, y do
        y + x
      end
    end
  end
end
