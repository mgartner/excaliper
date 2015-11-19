defmodule Excaliper.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excaliper,
      name: 'excaliper',
      source_url: "https://github.com/mgartner/excaliper",
      version: "0.0.1",
      elixir: "~> 1.1",
      description: "Fast image dimension parser inspired by the Node.JS module Calipers.",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: []]
  end

  def deps do
    [
      {:dogma, "~> 0.0.11", only: [:dev, :test]},
      {:excoveralls, "~> 0.4.2", only: :test}
    ]
  end

end
