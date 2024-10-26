defmodule Mix.Tasks.Babel do
  use Mix.Task

  alias ChromaBabel.Parser
  alias ChromaBabel.Emitter

  @aliases [
    i: :input,
    o: :output
  ]

  @switches [
    input: :string,
    output: :string,
    name: :string,
    author: :string,
    appearance: :string
  ]

  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    opts =
      opts
      |> Keyword.put_new(:appearance, :dark)
      |> Keyword.update!(:output, &Path.expand/1)

    {:ok, parsed, _, _, _, _} =
      opts[:input]
      |> File.read!()
      |> Parser.Vim.parse()

    {:ok, normalized} = Parser.Vim.normalize(parsed)

    output =
      opts
      |> Emitter.Zed.emit(normalized)
      |> Jason.encode!()
      |> Jason.Formatter.pretty_print()

    File.write!(opts[:output], output)
  end
end
