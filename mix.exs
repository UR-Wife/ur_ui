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
      description: "shadcn/ui new-york-v4 components as Phoenix function components",
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
      # assets/ holds the stylesheet and the LiveView hooks JS module, which
      # host apps import through package.json ("ur_ui").
      files:
        ~w(lib priv assets package.json mix.exs README.md USAGE.md LICENSE LICENSES),
      links: %{"GitHub" => "https://github.com/UR-Wife/ur_ui"}
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.2.14"},
      {:phoenix_html, "~> 4.4.0"},
      {:phoenix, "~> 1.7.25 or ~> 1.8"},
      {:bandit, "~> 1.14.1", only: :dev},
      {:phoenix_storybook, "~> 1.3", only: :dev},
      {:esbuild, "~> 0.10", only: :dev},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:phoenix_ecto, "~> 4.6", only: [:dev, :test]},
      {:floki, "~> 0.38", only: [:dev, :test]}
    ]
  end
end
