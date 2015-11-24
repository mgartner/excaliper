defmodule Excaliper.Benchmark do
  @moduledoc """
  These benchmarks can be run with `mix bench`.
  """

  use Benchfella

  bench "PNG Excaliper" do
    run_excaliper "test/fixtures/png/123x456.png"
  end

  bench "PNG ImageMagick" do
    run_identify "test/fixtures/png/123x456.png"
  end

  bench "JPEG Excaliper" do
    run_excaliper "test/fixtures/jpeg/123x456.jpg"
  end

  bench "JPEG ImageMagick" do
    run_identify "test/fixtures/jpeg/123x456.jpg"
  end

  defp run_excaliper(path) do
    Excaliper.measure path
  end

  defp run_identify(path) do
    System.cmd "identify", List.insert_at(["-format", "%w,%h"], -1, path)
  end

end
