defmodule Mix.Tasks.Xjs do
  use Mix.Task

  @statements [
    :LetStatement,
    :VariableDeclaration
  ]

  def run([path]) do
    [{mod, _}] = Code.load_file path
    %{
      type: :Program,
      body: Enum.map(mod.run, fn node ->
        case Map.get node, :type do
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
