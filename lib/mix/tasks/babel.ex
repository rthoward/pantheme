defmodule Mix.Tasks.Babel do
  use Mix.Task

  alias PanTheme.Parser
  alias PanTheme.Emitter

  @switches [
    input: :string,
    output: :string,
    name: :string,
    author: :string,
    appearance: :string,
    nvim_plugin: :string,
    nvim_colorscheme: :string
  ]

  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches)

    opts =
      opts
      |> Keyword.put_new(:appearance, :dark)
      |> Keyword.update(:output, nil, &Path.expand/1)

    plugin = Keyword.fetch!(opts, :nvim_plugin)
    colorscheme = Keyword.fetch!(opts, :nvim_colorscheme)

    init_path = Path.join(__DIR__, "../../../priv/nvim/init.lua")

    {input, 0} =
      System.cmd(
        "nvim",
        ["--headless", "-u", init_path],
        env: [{"PLUGIN", plugin}, {"COLORSCHEME", colorscheme}, {"APPEARANCE", opts[:appearance]}],
        stderr_to_stdout: true
      )

    {:ok, parsed, _, _, _, _} =
      input
      |> Parser.Vim.parse()

    parsed
    |> Keyword.get_values(:highlight)
    |> Enum.find(& &1.name == "Operator")

    {:ok, normalized} = Parser.Vim.normalize(parsed)

    normalized
    |> Map.get(:highlights)
    |> Map.get("Operator")
    |> dbg()

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
