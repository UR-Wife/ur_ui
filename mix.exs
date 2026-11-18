defmodule UrUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :ur_ui,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "UR black/red/white UI components as Phoenix function components",
      package: package(),
      docs: [main: "usage", extras: ["USAGE.md"]]
    ]
  end

  def application do
    case Mix.env() do
      :dev -> [extra_applications: [:logger], mod: {UrUiDev.Application, []}]
      _ -> [extra_applications: [:logger]]
    end
  end

  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/UR-Wife/ur_ui"}
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.2.12"},
      {:phoenix_html, "~> 4.4.0"},
      {:phoenix, "~> 1.7.24 or ~> 1.8.0"},
      {:bandit, "~> 1.14.1", only: :dev},
      {:phoenix_storybook, "~> 1.3", only: :dev},
      {:jason, "~> 1.4", only: [:dev, :test]}
    ]
  end
end