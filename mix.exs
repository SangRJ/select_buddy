defmodule SelectBuddy.MixProject do
  use Mix.Project

  def project do
    [
      app: :select_buddy,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "SelectBuddy",
      source_url: "https://github.com/SangRJ/select_buddy"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_html, "~> 4.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A Phoenix LiveView multi-select component with type-ahead functionality"
  end

  defp package do
    [
      name: "select_buddy",
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/SangRJ/select_buddy",
        "Changelog" => "https://github.com/SangRJ/select_buddy/blob/main/CHANGELOG.md"
      },
      maintainers: ["SangRJ"],
      exclude_patterns: ["test/"]
    ]
  end

  defp docs do
    [
      main: "SelectBuddy",
      extras: ["README.md"]
    ]
  end
end
