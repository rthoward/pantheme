defmodule Mix.Tasks.Pantheme do
  use Mix.Task

  alias Pantheme.Parser
  alias Pantheme.Emitter

  @switches [
    from: :string,
    to: :string,
    appearance: :string,
    author: :string,
    name: :string,
    output_file: :string,
    help: :boolean,

    # Neovim-specific
    neovim_plugin: :string,
    neovim_colorscheme: :string
  ]

  @parsers %{
    "neovim" => Parser.Vim
  }

  @emitters %{
    "zed" => Emitter.Zed
  }

  @schema [
    from: [type: {:in, Map.keys(@parsers)}],
    to: [type: {:in, Map.keys(@emitters)}],
    author: [type: :string, required: true],
    appearance: [type: {:in, ["dark", "light"]}, required: true],
    name: [type: :string, required: true],
    output_file: [type: :string],
    help: [type: :boolean, default: false],

    # Neovim-specific
    neovim_plugin: [type: :string],
    neovim_colorscheme: [type: :string]
  ]

  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches)

    if opts[:help] || "help" in args,
      do: help_and_exit!()

    opts =
      opts
      |> NimbleOptions.validate!(@schema)
      |> Keyword.update(:output_file, nil, &Path.expand/1)

    parser = Map.fetch!(@parsers, opts[:from])
    emitter = Map.fetch!(@emitters, opts[:to])

    with {:ok, loaded} <- parser.load(opts),
         {:ok, parsed} <- parser.parse(loaded),
         {:ok, normalized} <- parser.normalize(parsed),
         ir <- parser.to_ir(normalized),
         emitted <- emitter.emit(ir, opts),
         {:ok, dumped} <- emitter.dump(emitted) do
      output(opts, dumped)
    end
  end

  defp output(opts, dumped) do
    if opts[:output_file] do
      File.write!(opts[:output_file], dumped)
      Mix.shell().info("Wrote theme \"#{opts[:name]}\" to #{opts[:output_file]}.")
    else
      Mix.shell().info(dumped <> "\n")
    end
  end

  defp help_and_exit!() do
    """
    Usage:
      pantheme [options]

    GENERAL OPTIONS
      --help                     shows this guide
      --from                     theme format to convert from (parse)
      --to                       theme format to convert to (emit)
      --author                   author name for emitted themes
      --name                     name of the theme to be emitted
      --output_file              path to write emitted theme. stdout if omitted
      --appearance               dark | light

    PARSER-SPECIFIC OPTIONS
      --neovim_plugin            neovim plugin containing input theme (git repo)
      --neovim_colorscheme       name of input colorscheme (via :colorscheme)
    """
    |> Mix.shell().info()

    System.halt(0)
  end
end
