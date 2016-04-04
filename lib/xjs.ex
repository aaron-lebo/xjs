defmodule XJS do
  @statements [
    :LetStatement,
    :VariableDeclaration
  ]

  def block({:__block__, _, body}) do
    block body
  end

  def block(body) when is_tuple body do
    block [body]
  end

  def block(body) do
    %{
      type: :BlockStatement,
      body: Enum.map(body, fn node ->
        node = compile node
        case node[:type] do
          type when type in @statements -> node
          _ -> %{
               type: :ExpressionStatement,
               expression: node
           }
        end
      end)
    }
  end

  def compile(name) when is_atom name do
    %{
      type: :Identifier,
      name: name
    }
  end

  def compile(val) when is_number(val) or is_bitstring(val) do
    %{
      type: :Literal,
      value: val
    }
  end

  def compile(elements) when is_list elements do
    %{
      type: :ArrayExpression,
      elements: Enum.map(elements, &XJS.compile/1)
    }
  end

  def compile({:%{}, _, props}) do
    %{
      type: :ObjectExpression,
      properties: Enum.map(props, fn {key, val} ->
        %{
          type: :Property,
          key: compile(key),
          value: compile(val),
          kind: :init
        }
      end)
    }
  end

  def compile({:fn, _, [{:->, _, [params, body]}]}) do
    %{
      type: :FunctionExpression,
      params: Enum.map(params, &XJS.compile/1),
      body: block(body)
    }
  end

  def compile({:., _, [obj, prop]}) do
    %{
      type: :MemberExpression,
      object: compile(obj),
      property: compile(prop),
      computed: false
    }
  end

  def compile({{:., _, [obj, prop]}, _, args}) when args == [] do
    %{
      type: :MemberExpression,
      object: compile(obj),
      property: compile(prop),
      computed: false
    }
  end

  def compile({{:., _, _} = callee, _, args}) do
    %{
      type: :CallExpression,
      callee: compile(callee),
      arguments: Enum.map(args, &XJS.compile/1)
    }
  end


  def compile({:&, _, [{callee, _, args}]}) do
    %{
      type: :CallExpression,
      callee: compile(callee),
      arguments: args && Enum.map(args, &XJS.compile/1) || []
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

  def compile({op, _, [left, right]}) when op in [:*, :/, :+, :-] do
    %{
      type: :BinaryExpression,
      operator: op,
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

  def compile({:sigil_r, meta, [{:<<>>, _, [pattern]}, flags]}) do
    compile {:RegExp, meta, [pattern, flags]}
  end

  def compile({name, _, nil}) do
    %{
      type: :Identifier,
      name: name
    }
  end

  def compile({callee, _, args}) do
    %{
      type: :CallExpression,
      callee: compile(callee),
      arguments: Enum.map(args, &XJS.compile/1)
    }
  end

  def compile(node) do
    raise [error: node]
  end

  defmacro xjs(do: block) do
    case block do
      {:__block__, _, ast} -> ast
      ast -> [ast]
    end
    |> Enum.map(&XJS.compile/1)
    |> Macro.escape
  end
end
