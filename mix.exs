defmodule BOT2.Mixfile do
  use Mix.Project

  def project do
    [app: :bot2,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:redix, ">= 0.0.0"}]
  end
end
