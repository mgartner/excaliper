defmodule Excaliper.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excaliper,
      name: 'excaliper',
      source_url: "https://github.com/mgartner/excaliper",
      version: "0.0.1",
      elixir: "~> 1.1",
      description: "Fast image dimension detector inspired by the Node.JS module Calipers.",
      package: [
        maintainers: ["Marcus Gartner"],
        licenses: ["MIT"],
        links: %{ "GitHub" => "https://github.com/mgartner/excaliper" },
      ],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps,
      docs: [main: "Excaliper", extras: ["README.md"]],
      preferred_cli_env: ["coveralls.html": :test]
    ]
  end

  def application do
    [applications: []]
  end

  def deps do
    [
      {:dialyxir, "~> 0.3", only: [:dev, :test]},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.5.2", only: :test},
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, "~> 0.2", only: :dev},
      {:benchfella, "~> 0.2", only: :dev}
    ]
  end

end
