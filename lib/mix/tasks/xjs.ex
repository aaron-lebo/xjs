defmodule Mix.Tasks.Xjs do
  use Mix.Task

  @statements [
    :LetStatement,
    :VariableDeclaration
  ]

  def run(_) do
    %{
      type: :Program,
      body: Enum.map(XJS.test, fn node ->
        case Map.get node, :type  do
          type when type in @statements -> node
          _ -> %{
               type: :ExpressionStatement,
               expression: node
           }
        end
      end)
    }
    |> Poison.encode!
    |> IO.puts
  end
end
