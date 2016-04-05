defmodule XJS do
  @statements [
    :LetStatement,
    :IfStatement,
    :VariableDeclaration
  ]

  def body!({:__block__, _, body}) do
    body! body, true
  end

  def body!(body) do
    body! [body], true
  end

  def body!(body, compile?) do
    Enum.map body, fn node ->
      if compile? do
        node = compile node
      end
      case node[:type] do
        type when type in @statements -> node
        _ -> %{
             type: :ExpressionStatement,
             expression: node
         }
      end
    end
  end

  def block!(body) do
    %{
      type: :BlockStatement,
      body: body!(body)
    }
  end

  defp map_compile(enum) do
    Enum.map enum, &compile/1
  end

  defp call(callee, args) do
    %{
      type: :CallExpression,
      callee: compile(callee),
      arguments: map_compile(args)
    }
  end

  def compile(val) when is_boolean(val) or is_number(val) or is_bitstring(val) do
    %{
      type: :Literal,
      value: val
    }
  end

  def compile(name) when is_atom(name) do
    %{
      type: :Identifier,
      name: name
    }
  end

  def compile({name, _, nil}) do
    %{
      type: :Identifier,
      name: name
    }
  end

  def compile(elements) when is_list elements do
    %{
      type: :ArrayExpression,
      elements: map_compile(elements)
    }
  end

  def compile({:%{}, _, props}) do
    %{
      type: :ObjectExpression,
      properties: Enum.map(props, fn {k, v} ->
        %{
          type: :Property,
          key: compile(k),
          value: compile(v),
          kind: :init
        }
      end)
    }
  end

  def compile({:fn, _, [{:->, _, [params, body]}]}) do
    %{
      type: :FunctionExpression,
      params: map_compile(params),
      body: block!(body)
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

  def compile({{:., _, [obj, prop]} = member, _, args}) when args == [] do
    compile member
  end

  def compile({:new, _, [callee | args]}) do
    %{
      type: :NewExpression,
      callee: compile(callee),
      arguments: map_compile(args)
    }
  end

  def compile({{:., _, _} = callee, _, args}) do
    call callee, args
  end

  def compile({op, _, [left, right]}) when op in [:&&, :||] do
    %{
      type: :LogicalExpression,
      operator: op,
      left: compile(left),
      right: compile(right)
    }
  end


  def compile({:&, _, [{callee, _, args}]}) do
    call callee, (args && map_compile(args) || [])
  end

  def compile({:=, _, [left, right]}) do
    %{
      type: :AssignmentExpression,
      operator: :=,
      left: compile(left),
      right: compile(right)
    }
  end

  @binary_ops [:==, :!=, :===, :!==, :<, :<=, :>, :>=, :+, :-, :*, :/, :%, :&, :|]
  def compile({op, _, [left, right]}) when op in @binary_ops do
    %{
      type: :BinaryExpression,
      operator: op,
      left: compile(left),
      right: compile(right)
    }
  end

  def compile({:|>, _, [left, {head, meta, args} = right]}) do
    compile {head, meta, [left|args]}
  end

  def compile({:if, meta, [test, [do: do_]]}) do
    compile {:if, meta, [test, [do: do_, else: nil]]}
  end

  def compile({:if, _, [test, [do: consequent, else: alternate]]}) do
    %{
      type: :IfStatement,
      test: compile(test),
      consequent: block!(consequent),
      alternate: block!(alternate)
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
    compile {:new, meta, [:RegExp, pattern, to_string(flags)]}
  end

  def compile({callee, _, args}) do
    call callee, args
  end

  def compile(node) do
    raise [error: node]
  end

  defmacro xjs(do: block) do
    case block do
      {:__block__, _, ast} -> ast
      ast -> [ast]
    end
    |> map_compile
    |> Macro.escape
  end
end
