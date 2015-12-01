defmodule Excaliper.TestBenchmark do
  @moduledoc """
  These benchmarks can be run with `mix run bench/benchmark.exs`.
  """

  @iterations 10

  def run_excaliper(name, file) do
    files = 1..@iterations |> Enum.to_list |> Enum.map(fn _ -> file end)
    t1 = :os.system_time(:micro_seconds)

    files
    |> Enum.map(&Task.async(Excaliper, :measure, [&1]))
    |> Enum.map(&Task.await/1)

    t2 = :os.system_time(:micro_seconds)
    IO.puts "#{name}: #{(t2 - t1) / 1000} ms"
  end

  def run_shell(name, cmd, file) do
    files = 1..@iterations |> Enum.to_list |> Enum.map(fn _ -> file end)
    t1 = :os.system_time(:micro_seconds)

    files
    |> Enum.map(&Task.async(System, :cmd, [cmd, [&1]]))
    |> Enum.map(&Task.await/1)

    t2 = :os.system_time(:micro_seconds)
    IO.puts "#{name}: #{(t2 - t1) / 1000} ms"
  end

end

png_path = Path.expand("test/fixtures/png/123x456.png")
jpeg_path = Path.expand("test/fixtures/jpeg/123x456.jpg")
pdf_path = Path.expand("test/fixtures/pdf/540x720.1.pdf")

Excaliper.TestBenchmark.run_excaliper("PNG Excaliper", png_path)
Excaliper.TestBenchmark.run_shell("PNG ImageMagick", "identify", png_path)
Excaliper.TestBenchmark.run_excaliper("JPEG Excaliper", jpeg_path)
Excaliper.TestBenchmark.run_shell("JPEG ImageMagick", "identify", jpeg_path)
Excaliper.TestBenchmark.run_excaliper("PDF Excaliper", pdf_path)


Excaliper.TestBenchmark.run_shell("PDF pdfinfo", "pdfinfo", pdf_path)
