defmodule Mix.Tasks.Xjs do
  use Mix.Task
  
  def run(_) do
    %{
      type: :Program,
      body: Enum.map(XJS.test, fn x ->
        %{
          type: :ExpressionStatement,
          expression: x
        }
      end)
    }
    |> Poison.encode!
    |> IO.puts
  end
end
