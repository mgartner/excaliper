defmodule Excaliper.Mixfile do
  use Mix.Project

  def project do
    [app: :excaliper,
     name: 'excaliper',
     source_url: "https://github.com/mgartner/excaliper",
     version: "0.0.1",
     elixir: "~> 1.1",
     description: "Fast image dimension parser inspired by the Node.JS module Calipers.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     preferred_cli_env: [espec: :test]]
  end

  def application do
    [applications: []]
  end

  defp deps do
    []
  end
end
