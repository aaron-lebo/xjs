defmodule Mix.Tasks.Xjs do
  use Mix.Task

  def run([path]) do
    [{mod, _}] = Code.load_file path
    %{
      type: :Program,
      body: XJS.body!(mod.run, false)
    }
    |> Poison.encode!
    |> IO.puts
  end
end
