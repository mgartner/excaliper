defmodule Excaliper.TestBenchmark do
  @moduledoc """
  These benchmarks can be run with `mix run bench/benchmark.exs`.
  """

  @iterations 200

  def run_excaliper(name, file) do
    files = 1..@iterations |> Enum.to_list |> Enum.map(fn _ -> file end)
    t1 = :os.system_time(:micro_seconds)

    files
    |> Enum.map(&Task.async(Excaliper, :measure, [&1]))
    |> Enum.map(&Task.await/1)

    t2 = :os.system_time(:micro_seconds)
    IO.puts "#{name}: #{(t2 - t1) / 1000} ms"
  end

  def run_identify(name, file) do
    files = 1..@iterations |> Enum.to_list |> Enum.map(fn _ -> file end)
    t1 = :os.system_time(:micro_seconds)

    files
    |> Enum.map(&Task.async(System, :cmd, ["identify", [&1]]))
    |> Enum.map(&Task.await/1)

    t2 = :os.system_time(:micro_seconds)
    IO.puts "#{name}: #{(t2 - t1) / 1000} ms"
  end

end

png_path = Path.expand("test/fixtures/png/123x456.png")
jpeg_path = Path.expand("test/fixtures/jpeg/123x456.jpg")

Excaliper.TestBenchmark.run_excaliper("PNG Excaliper", png_path)
Excaliper.TestBenchmark.run_identify("PNG ImageMagick", png_path)
Excaliper.TestBenchmark.run_excaliper("JPEG Excaliper", jpeg_path)
Excaliper.TestBenchmark.run_identify("JPEG ImageMagick", jpeg_path)
