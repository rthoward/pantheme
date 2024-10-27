defmodule Mix.Tasks.Babel do
  use Mix.Task

  alias PanTheme.Parser
  alias PanTheme.Emitter

  @switches [
    input: :string,
    output: :string,
    name: :string,
    author: :string,
    appearance: :string
  ]

  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches)

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
      normalized
      |> Parser.Vim.to_ast()
      |> Emitter.Zed.emit(opts)
      |> Jason.encode!()
      |> Jason.Formatter.pretty_print()

    File.write!(opts[:output], output)

    Mix.shell().info("Wrote theme \"#{opts[:name]}\" to #{opts[:output]}.")
  end
end
