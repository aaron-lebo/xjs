defmodule Mix.Tasks.Xjs do
  use Mix.Task

  def run(_) do
    XJS.test
    |> IO.puts
  end
end
