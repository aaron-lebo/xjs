defmodule Mix.Tasks.Xjs do
  use Mix.Task

  def run(_) do
    %{
      type: :Program,
      body: Enum.map(XJS.test, fn node ->
        case Map.get node, :type  do
          type when type in [
            :LetStatement,
            :VariableDeclaration
          ] -> node
          type -> %{
               type: :ExpressionStatement,
               expression: node
           }
        end
      end
      )
    }
    |> Poison.encode!
    |> IO.puts
  end
end
