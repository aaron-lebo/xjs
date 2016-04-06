defmodule XJS.Mixfile do
  use Mix.Project

  def project do
    [app: :xjs,
     version: "0.0.3",
     elixir: "~> 1.2",
     description: "elixir syntax, javascript semantics",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:poison, "~> 2.0"}]
  end

  defp package do
    [
      maintainers: ["Aaron Lebo"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/aaron-lebo/xjs"}]
  end
end
