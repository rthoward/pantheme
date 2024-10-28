defmodule Mix.Tasks.Pantheme do
  use Mix.Task

  alias PanTheme.Parser
  alias PanTheme.Emitter

  @switches [
    from: :string,
    to: :string,
    appearance: :string,
    author: :string,
    name: :string,
    output_file: :string,

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

    # Neovim-specific
    neovim_plugin: [type: :string],
    neovim_colorscheme: [type: :string]
  ]

  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches)

    opts =
      opts
      |> NimbleOptions.validate!(@schema)
      |> Keyword.update(:output_file, nil, &Path.expand/1)

    parser = Map.fetch!(@parsers, opts[:from])
    emitter = Map.fetch!(@emitters, opts[:to])

    with {:ok, loaded} <- parser.load(opts),
         {:ok, parsed} <- parser.parse(loaded),
         {:ok, normalized} <- parser.normalize(parsed),
         ast <- parser.to_ast(normalized),
         emitted <- emitter.emit(ast, opts),
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
end
