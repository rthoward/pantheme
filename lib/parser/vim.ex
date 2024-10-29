defmodule Pantheme.Parser.Vim do
  @behaviour Pantheme.Parser

  import NimbleParsec

  alias Pantheme.IR

  #
  # Load
  #

  @opt_schema [
    neovim_plugin: [type: :string, required: true],
    neovim_colorscheme: [type: :string, required: true],
    appearance: [type: {:in, ["dark", "light"]}, required: true],
    *: [type: :any]
  ]

  def load(opts) do
    opts = NimbleOptions.validate!(opts, @opt_schema)

    System.cmd(
      "nvim",
      ["--headless", "--clean", "-u", init_path()],
      env: [
        {"PLUGIN", opts[:neovim_plugin]},
        {"COLORSCHEME", opts[:neovim_colorscheme]},
        {"APPEARANCE", opts[:appearance]}
      ],
      stderr_to_stdout: true
    )
    |> case do
      {output, 0} -> {:ok, output}
      {output, _} -> {:error, output}
    end
  end

  defp init_path,
    do: Path.join(__DIR__, "../../priv/nvim/init.lua")

  #
  # Parse
  #

  whitespace = repeat(ascii_char([?\s, ?\t]))
  group = ascii_string([?a..?z, ?A..?Z, ?@, ?.], min: 1)
  rest_of_line = ascii_string([not: ?\n], min: 0)
  newline = string("\n")

  ignored_line =
    ignore(rest_of_line)
    |> ignore(newline)

  link =
    ignore(whitespace)
    |> concat(group)
    |> ignore(whitespace)
    |> ignore(string("xxx "))
    |> ignore(string("links to "))
    |> concat(group)
    |> reduce({__MODULE__, :transform, [:link]})

  hex_color =
    string("#")
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], min: 6)
    |> reduce({Enum, :join, [""]})

  color = hex_color

  styles =
    choice([
      string("bold"),
      string("italic"),
      string("underline"),
      string("undercurl"),
      ignore(string(","))
    ])
    |> repeat()
    |> wrap()

  attr =
    choice([
      string("guifg"),
      string("guibg"),
      string("guisp"),
      string("gui"),
      string("cterm")
    ])
    |> ignore(string("="))
    |> choice([
      color,
      styles
    ])
    |> ignore(optional(string(" ")))

  highlight =
    ignore(whitespace)
    |> concat(group)
    |> ignore(whitespace)
    |> ignore(string("xxx "))
    |> repeat(attr |> wrap())
    |> ignore(optional(newline))
    |> reduce({__MODULE__, :transform, [:highlight]})

  clear =
    ignore(whitespace)
    |> concat(group)
    |> ignore(whitespace)
    |> ignore(string("xxx "))
    |> ignore(string("cleared"))
    |> ignore(optional(newline))
    |> reduce({__MODULE__, :transform, [:clear]})

  term_color =
    ignore(whitespace)
    |> ignore(string("terminal_color_"))
    |> integer(min: 1)
    |> ignore(string("="))
    |> concat(hex_color)
    |> reduce({__MODULE__, :transform, [:term_color]})

  line =
    choice([
      clear,
      link,
      highlight,
      term_color,
      ignored_line
    ])

  defparsec(:parse_lines, repeat(line))

  def transform([index, color], :term_color),
    do: {:term_color, %{index: index, color: color}}

  def transform([from, to], :link),
    do: {:link, %{from: from, to: to}}

  def transform([group], :clear),
    do: {:clear, %{name: group}}

  def transform([key, value], :attr),
    do: {:attr, {String.to_atom(key), value}}

  def transform([name | attrs], :highlight) do
    {:highlight,
     Enum.reduce(attrs, %{name: name}, fn [key, value], acc ->
       Map.put(acc, String.to_atom(key), value)
     end)}
  end

  def parse(string) do
    case parse_lines(string) do
      {:ok, parsed, _, _, _, _} -> {:ok, parsed}
      {:error, reason, rest, _, _, _} -> {:error, {reason, rest}}
    end
  end

  #
  # Resolve
  #

  def normalize(parsed) do
    term_colors =
      parsed
      |> Keyword.get_values(:term_color)
      |> Enum.reduce([], fn %{index: index, color: color}, acc ->
        List.insert_at(acc, index, color)
      end)

    highlights =
      parsed
      |> Keyword.get_values(:highlight)
      |> Enum.reduce(%{}, fn h, acc ->
        highlight = highlight(h)
        Map.update(acc, h.name, highlight, &Map.merge(&1, highlight))
      end)

    resolved_links =
      parsed
      |> Keyword.get_values(:link)
      |> Map.new(fn %{from: from, to: to} ->
        resolved = highlights[to] || highlights["Normal"]
        {from, resolved}
      end)

    all_highlights = Map.merge(highlights, resolved_links)

    {:ok, %{term_colors: term_colors, highlights: all_highlights}}
  end

  defp highlight(map) do
    map
    |> map_keys(&normalize_attr/1)
    |> Enum.reject(&nil_key?/1)
    |> map_values(&normalize_style/1)
  end

  defp normalize_attr(:guifg), do: :fg
  defp normalize_attr(:guibg), do: :bg
  defp normalize_attr(:guisp), do: :special
  defp normalize_attr(:gui), do: :style
  defp normalize_attr(:name), do: nil
  defp normalize_attr(:cterm), do: nil

  defp normalize_style("bold"), do: [:bold]
  defp normalize_style("italic"), do: [:italic]
  defp normalize_style("underline"), do: [:underline]
  defp normalize_style("undercurl"), do: [:undercurl]
  defp normalize_style("NONE"), do: nil
  defp normalize_style("#" <> hex), do: "#" <> hex
  defp normalize_style(l) when is_list(l), do: Enum.flat_map(l, &normalize_style/1)

  defp map_keys(m, f), do: Map.new(m, fn {k, v} -> {f.(k), v} end)
  defp map_values(m, f), do: Map.new(m, fn {k, v} -> {k, f.(v)} end)

  defp nil_key?({nil, _}), do: true
  defp nil_key?(_), do: false

  @spec to_ir(map()) :: IR.t()
  def to_ir(%{term_colors: tcs, highlights: hs}) do
    %IR{
      editor: %IR.Editor{
        bg: hi(hs, "Normal", :bg),
        fg: hi(hs, "Normal", :fg),
        highlighted_line_bg: hi(hs, ["CursorLine"], :bg),
        line_number: hi(hs, "LineNumberNC", :fg),
        line_number_active: hi(hs, "LineNumber", :fg),
        active_line_bg: hi(hs, "CursorLine", :bg),
        selection_fg: hi(hs, "Visual", :fg),
        selection_bg: hi(hs, "Visual", :bg),
        subheader_bg: hi(hs, ["Pmenu"], :bg)
      },
      ui: %IR.UI{
        bg: hi(hs, "Normal", :bg),
        fg: hi(hs, "Normal", :fg),
        status_bar_bg: hi(hs, "StatusLine", :bg),
        tab_bar_bg: hi(hs, "StatusLineNC", :bg),
        tab_active_bg: hi(hs, "Normal", :bg),
        tab_inactive_bg: hi(hs, "StatusLineNC", :bg),
        title_bar_bg: hi(hs, ["WinBar", "StatusLine"], :bg),
        title_bar_inactive_bg: hi(hs, ["WinBarNC", "StatusLineNC"], :bg),
        toolbar_bg: hi(hs, "Normal", :bg),
        search_match_bg: hi(hs, "StatusLine", :bg),
        scrollbar_thumb_bg: hi(hs, ["Scrollbar", "StatusLine"], :bg) |> opacity(0.6),
        scrollbar_thumb_hover_bg: hi(hs, ["Scrollbar", "StatusLine"], :bg),
        scrollbar_thumb_border: hi(hs, ["Scrollbar", "StatusLineNC"], :bg),
        scrollbar_track_bg: hi(hs, "Scrollbar", :bg),
        scrollbar_track_border: hi(hs, ["Scrollbar", "StatusLineNC"], :bg),
        border: %IR.Element{
          color: hi(hs, ["WinSeparator", "FloatBorder"], :fg),
          active: hi(hs, ["FloatBorder", "StatusLine"], :fg),
          disabled: hi(hs, ["StatusLineNC"], :fg),
          focused: hi(hs, ["StatusLine", "CursorLine", "Search"], :fg),
          hover: hi(hs, ["PmenuSel", "WildMenu"], :fg),
          selected: hi(hs, ["Visual", "PmenuSel", "TabLineSel"], :fg),
          transparent: hi(hs, ["Conceal", "NormalFloat"], :fg),
          variant: hi(hs, ["Special"], :fg)
        },
        panel_bg: hi(hs, ["StatusLine"], :bg),
        panel_focused_bg: hi(hs, ["Pmenu"], :bg),
        conflict: %IR.Container{
          fg: hi(hs, "DiffText", :fg),
          bg: hi(hs, "DiffChange", :bg),
          border: hi(hs, "FloatBorder", :bg)
        },
        created: %IR.Container{
          fg: hi(hs, "GitSignsAdd", :fg),
          bg: hi(hs, "GitSignsAdd", :fg),
          border: hi(hs, "GitSignsAdd", :fg)
        },
        deleted: %IR.Container{
          fg: hi(hs, "GitSignsDelete", :fg),
          bg: hi(hs, "GitSignsDelete", :fg),
          border: hi(hs, "GitSignsDelete", :fg)
        },
        drop_target_bg: hi(hs, "Normal", :bg),
        element: %IR.Element{
          color: hi(hs, "Normal", :bg),
          active: hi(hs, ["Title", "Special"], :fg),
          disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          focused: hi(hs, ["CursorLine"], :bg),
          hover: hi(hs, ["PmenuSel"], :bg),
          selected: hi(hs, ["Visual", "PmenuSel"], :fg),
          transparent: hi(hs, "Conceal", :fg),
          variant: hi(hs, "Special", :fg)
        },
        error: %IR.Container{
          fg: hi(hs, ["DiagnosticError", "Error"], :fg),
          bg: hi(hs, ["DiagnosticError", "Error"], :bg),
          border: hi(hs, ["DiagnosticError", "Error"], :bg)
        },
        ghost_element: %IR.Element{
          color: hi(hs, "Normal", :bg),
          active: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          focused: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          hover: hi(hs, ["PmenuThumb", "CursorLine"], :bg),
          selected: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          transparent: hi(hs, "Conceal", :fg),
          variant: hi(hs, "Special", :fg)
        },
        hidden: %IR.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        hint: %IR.Container{
          fg: hi(hs, ["LspInlayHint", "Comment"], :fg),
          bg: hi(hs, ["LspInlayHint", "Comment"], :bg),
          border: hi(hs, ["LspInlayHint", "Comment"], :bg)
        },
        icon: %IR.Text{
          fg: hi(hs, "Normal", :fg),
          fg_accent: hi(hs, ["Title", "Special"], :fg),
          fg_disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          fg_muted: hi(hs, ["Comment", "LineNr", "LspInlayHint"], :fg),
          fg_placeholder: hi(hs, ["Conceal", "NonText", "Comment"], :fg)
        },
        ignored: %IR.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        info: %IR.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        link_text_hover: hi(hs, "Normal", :fg),
        modified: %IR.Container{
          fg: hi(hs, "GitSignsChange", :fg),
          bg: hi(hs, "GitSignsChange", :fg),
          border: hi(hs, "GitSignsChange", :fg)
        },
        predictive: %IR.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        renamed: %IR.Container{
          fg: hi(hs, "DiffText", :fg),
          bg: hi(hs, "DiffChange", :bg),
          border: hi(hs, "FloatBorder", :bg)
        },
        success: %IR.Container{
          fg: hi(hs, "DiagnosticOk", :fg),
          bg: hi(hs, "DiagnosticOk", :bg),
          border: hi(hs, "DiagnosticOk", :bg)
        },
        text: %IR.Text{
          fg: hi(hs, "Normal", :fg),
          fg_accent: hi(hs, "Normal", :fg),
          fg_disabled: hi(hs, "Normal", :fg),
          fg_muted: hi(hs, "Normal", :fg),
          fg_placeholder: hi(hs, "Normal", :fg)
        },
        unreachable: %IR.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        warning: %IR.Container{
          fg: hi(hs, "DiagnosticWarn", :fg),
          bg: hi(hs, "DiagnosticWarn", :bg),
          border: hi(hs, "DiagnosticWarn", :bg)
        }
      },
      syntax: %IR.Syntax{
        attribute: %IR.Text{
          fg: hi(hs, ["@variable", "Identifier"], :fg),
          style: hi(hs, ["@variable", "Identifier"], :style) |> style(),
          weight: hi(hs, ["@variable", "Identifier"], :style) |> weight()
        },
        boolean: %IR.Text{
          fg: hi(hs, ["@boolean", "Boolean"], :fg),
          style: hi(hs, ["@boolean", "Boolean"], :style) |> style(),
          weight: hi(hs, ["@boolean", "Boolean"], :style) |> weight()
        },
        comment: %IR.Text{
          fg: hi(hs, ["@comment", "Comment"], :fg),
          style: hi(hs, ["@comment", "Comment"], :style) |> style(),
          weight: hi(hs, ["@comment", "Comment"], :style) |> weight()
        },
        constant: %IR.Text{
          fg: hi(hs, ["@constant", "Constant"], :fg),
          style: hi(hs, ["@constant", "Constant"], :style) |> style(),
          weight: hi(hs, ["@constant", "Constant"], :style) |> weight()
        },
        constructor: %IR.Text{
          fg: hi(hs, ["@constructor", "Constructor"], :fg),
          style: hi(hs, ["@constructor", "Constructor"], :style) |> style(),
          weight: hi(hs, ["@constructor", "Constructor"], :style) |> weight()
        },
        docstring: %IR.Text{
          fg: hi(hs, ["@comment.documentation", "Comment"], :fg),
          style: hi(hs, ["@comment.documentation", "Comment"], :style) |> style(),
          weight: hi(hs, ["@comment.documentation", "Comment"], :style) |> weight()
        },
        embedded: %IR.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        emphasis: %IR.Text{
          fg: hi(hs, "Special", :fg),
          style: hi(hs, "Special", :style) |> style(),
          weight: hi(hs, "Special", :style) |> weight()
        },
        emphasis_strong: %IR.Text{
          fg: hi(hs, "Special", :fg),
          style: hi(hs, "Special", :style) |> style(),
          weight: hi(hs, "Special", :style) |> weight()
        },
        enum: %IR.Text{
          fg: hi(hs, ["@lsp.type.enum", "Type", "Constant"], :fg),
          style: hi(hs, ["@lsp.type.enum", "Type", "Constant"], :style) |> style(),
          weight: hi(hs, ["@lsp.type.enum", "Type", "Constant"], :style) |> weight()
        },
        function: %IR.Text{
          fg: hi(hs, ["@function", "Function"], :fg),
          style: hi(hs, ["@function", "Function"], :style) |> style(),
          weight: hi(hs, ["@function", "Function"], :style) |> weight()
        },
        function_def: %IR.Text{
          fg: hi(hs, ["@function", "Function"], :fg),
          style: hi(hs, ["@function", "Function"], :style) |> style(),
          weight: hi(hs, ["@function", "Function"], :style) |> weight()
        },
        hint: %IR.Text{
          fg: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :fg),
          style: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :style) |> style(),
          weight: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :style) |> weight()
        },
        keyword: %IR.Text{
          fg: hi(hs, ["@keyword", "Keyword"], :fg),
          style: hi(hs, ["@keyword", "Keyword"], :style) |> style(),
          weight: hi(hs, ["@keyword", "Keyword"], :style) |> weight()
        },
        label: %IR.Text{
          fg: hi(hs, ["@label", "Label", "Identifier"], :fg),
          style: hi(hs, ["@label", "Label", "Identifier"], :style) |> style(),
          weight: hi(hs, ["@label", "Label", "Identifier"], :style) |> weight()
        },
        link_text: %IR.Text{
          fg: hi(hs, ["@markup.link", "Tag"], :fg),
          style: hi(hs, ["@markup.link", "Tag"], :style) |> style(),
          weight: hi(hs, ["@markup.link", "Tag"], :style) |> weight()
        },
        link_uri: %IR.Text{
          fg: hi(hs, ["@markup.link.url", "Tag"], :fg),
          style: hi(hs, ["@markup.link.url", "Tag"], :style) |> style(),
          weight: hi(hs, ["@markup.link.url", "Tag"], :style) |> weight()
        },
        method: %IR.Text{
          fg: hi(hs, ["@function.method", "Function"], :fg),
          style: hi(hs, ["@function.method", "Function"], :style) |> style(),
          weight: hi(hs, ["@function.method", "Function"], :style) |> weight()
        },
        number: %IR.Text{
          fg: hi(hs, ["@number", "Number"], :fg),
          style: hi(hs, ["@number", "Number"], :style) |> style(),
          weight: hi(hs, ["@number", "Number"], :style) |> weight()
        },
        operator: %IR.Text{
          fg: hi(hs, ["@operator", "Operator"], :fg),
          style: hi(hs, ["@operator", "Operator"], :style) |> style(),
          weight: hi(hs, ["@operator", "Operator"], :style) |> weight()
        },
        predictive: %IR.Text{
          fg: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :fg),
          style: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :style) |> style(),
          weight: hi(hs, ["@comment.hint", "DiagnosticHint", "Comment"], :style) |> weight()
        },
        preproc: %IR.Text{
          fg: hi(hs, ["@preproc", "PreProc"], :fg),
          style: hi(hs, ["@preproc", "PreProc"], :style) |> style(),
          weight: hi(hs, ["@preproc", "PreProc"], :style) |> weight()
        },
        primary: %IR.Text{
          fg: hi(hs, "Identifier", :fg),
          style: hi(hs, "Identifier", :style) |> style(),
          weight: hi(hs, "Identifier", :style) |> weight()
        },
        property: %IR.Text{
          fg: hi(hs, ["Property", "Identifier"], :fg),
          style: hi(hs, ["Property", "Identifier"], :style) |> style(),
          weight: hi(hs, ["Property", "Identifier"], :style) |> weight()
        },
        punct: %IR.Text{
          fg: hi(hs, ["@punctuation", "Delimiter"], :fg),
          style: hi(hs, ["@punctuation", "Delimiter"], :style) |> style(),
          weight: hi(hs, ["@punctuation", "Delimiter"], :style) |> weight()
        },
        punct_bracket: %IR.Text{
          fg: hi(hs, ["@punctuation.bracket", "Delimiter"], :fg),
          style: hi(hs, ["@punctuation.bracket", "Delimiter"], :style) |> style(),
          weight: hi(hs, ["@punctuation.bracket", "Delimiter"], :style) |> weight()
        },
        punct_delimiter: %IR.Text{
          fg: hi(hs, ["@punctuation.delimiter", "Delimiter"], :fg),
          style: hi(hs, ["@punctuation.delimiter", "Delimiter"], :style) |> style(),
          weight: hi(hs, ["@punctuation.delimiter", "Delimiter"], :style) |> weight()
        },
        punct_list_marker: %IR.Text{
          fg: hi(hs, ["@punctuation.bracket", "Delimiter"], :fg),
          style: hi(hs, ["@punctuation.bracket", "Delimiter"], :style) |> style(),
          weight: hi(hs, ["@punctuation.bracket", "Delimiter"], :style) |> weight()
        },
        punct_special: %IR.Text{
          fg: hi(hs, ["@punctuation.special", "Special"], :fg),
          style: hi(hs, ["@punctuation.special", "Special"], :style) |> style(),
          weight: hi(hs, ["@punctuation.special", "Special"], :style) |> weight()
        },
        string: %IR.Text{
          fg: hi(hs, ["@string", "String"], :fg),
          style: hi(hs, ["@string", "String"], :style) |> style(),
          weight: hi(hs, ["@string", "String"], :style) |> weight()
        },
        string_escape: %IR.Text{
          fg: hi(hs, ["@string.escape", "String"], :fg),
          style: hi(hs, ["@string.escape", "String"], :style) |> style(),
          weight: hi(hs, ["@string.escape", "String"], :style) |> weight()
        },
        string_regex: %IR.Text{
          fg: hi(hs, ["@string.regexp", "String"], :fg),
          style: hi(hs, ["@string.regexp", "String"], :style) |> style(),
          weight: hi(hs, ["@string.regexp", "String"], :style) |> weight()
        },
        string_special: %IR.Text{
          fg: hi(hs, ["@string.special", "Special"], :fg),
          style: hi(hs, ["@string.special", "Special"], :style) |> style(),
          weight: hi(hs, ["@string.special", "Special"], :style) |> weight()
        },
        string_symbol: %IR.Text{
          fg: hi(hs, ["@string.special.symbol", "String"], :fg),
          style: hi(hs, ["@string.special.symbol", "String"], :style) |> style(),
          weight: hi(hs, ["@string.special.symbol", "String"], :style) |> weight()
        },
        tag: %IR.Text{
          fg: hi(hs, "Tag", :fg),
          style: hi(hs, "Tag", :style) |> style(),
          weight: hi(hs, "Tag", :style) |> weight()
        },
        text_literal: %IR.Text{
          fg: hi(hs, ["@text.literal", "String"], :fg),
          style: hi(hs, ["@text.literal", "String"], :style) |> style(),
          weight: hi(hs, ["@text.literal", "String"], :style) |> weight()
        },
        title: %IR.Text{
          fg: hi(hs, "Title", :fg),
          style: hi(hs, "Title", :style) |> style(),
          weight: hi(hs, "Title", :style) |> weight()
        },
        type: %IR.Text{
          fg: hi(hs, ["@type", "Type"], :fg),
          style: hi(hs, ["@type", "Type"], :style) |> style(),
          weight: hi(hs, ["@type", "Type"], :style) |> weight()
        },
        variable: %IR.Text{
          fg: hi(hs, ["@variable", "Identifier"], :fg),
          style: hi(hs, ["@variable", "Identifier"], :style) |> style(),
          weight: hi(hs, ["@variable", "Identifier"], :style) |> weight()
        },
        variable_special: %IR.Text{
          fg: hi(hs, ["@variable.builtin", "Special"], :fg),
          style: hi(hs, ["@variable.builtin", "Special"], :style) |> style(),
          weight: hi(hs, ["@variable.builtin", "Special"], :style) |> weight()
        },
        variant: %IR.Text{
          fg: hi(hs, ["@variable", "Identifier"], :fg),
          style: hi(hs, ["@variable", "Identifier"], :style) |> style(),
          weight: hi(hs, ["@variable", "Identifier"], :style) |> weight()
        }
      },
      term: %IR.TermColors{
        bg: term_color(tcs, :bg),
        fg: %IR.TermColor{
          normal: term_color(tcs, :fg),
          bright: term_color(tcs, :fg_bright),
          dim: term_color(tcs, :fg_dim)
        },
        black: %IR.TermColor{
          normal: term_color(tcs, :black),
          bright: term_color(tcs, :black_bright),
          dim: term_color(tcs, :black_dim)
        },
        red: %IR.TermColor{
          normal: term_color(tcs, :red),
          bright: term_color(tcs, :red_bright),
          dim: term_color(tcs, :red_dim)
        },
        green: %IR.TermColor{
          normal: term_color(tcs, :green),
          bright: term_color(tcs, :green_bright),
          dim: term_color(tcs, :green_dim)
        },
        yellow: %IR.TermColor{
          normal: term_color(tcs, :yellow),
          bright: term_color(tcs, :yellow_bright),
          dim: term_color(tcs, :yellow_dim)
        },
        blue: %IR.TermColor{
          normal: term_color(tcs, :blue),
          bright: term_color(tcs, :blue_bright),
          dim: term_color(tcs, :blue_dim)
        },
        magenta: %IR.TermColor{
          normal: term_color(tcs, :magenta),
          bright: term_color(tcs, :magenta_bright),
          dim: term_color(tcs, :magenta_dim)
        },
        cyan: %IR.TermColor{
          normal: term_color(tcs, :cyan),
          bright: term_color(tcs, :cyan_bright),
          dim: term_color(tcs, :cyan_dim)
        },
        white: %IR.TermColor{
          normal: term_color(tcs, :white),
          bright: term_color(tcs, :white_bright),
          dim: term_color(tcs, :white_dim)
        }
      }
    }
  end

  @spec hi(map(), [String.t()] | String.t(), atom()) :: any()
  def hi(highlights, groups, attr) do
    groups
    |> List.wrap()
    |> Enum.find_value(&highlights[&1][attr])
    |> Kernel.||(highlights["Normal"][attr])
  end

  defp style([style | _]), do: style(style)
  defp style(:italic), do: :italic
  defp style(:oblique), do: :oblique
  defp style(_), do: nil

  defp weight([:bold]), do: 700
  defp weight(_), do: nil

  defp opacity("#" <> hex, pct_f) do
    alpha_hex =
      (pct_f * 256)
      |> round()
      |> min(256)
      |> Integer.to_string(16)

    "#" <> hex <> alpha_hex
  end

  @spec term_color([String.t()], atom()) :: String.t()
  defp term_color(tcs, :bg), do: Enum.at(tcs, 0)

  defp term_color(tcs, :fg), do: Enum.at(tcs, 1)
  defp term_color(tcs, :fg_bright), do: Enum.at(tcs, 15)
  defp term_color(tcs, :fg_dim), do: Enum.at(tcs, 1)

  defp term_color(tcs, :black), do: Enum.at(tcs, 0)
  defp term_color(tcs, :black_bright), do: Enum.at(tcs, 8)
  defp term_color(tcs, :black_dim), do: Enum.at(tcs, 0)

  defp term_color(tcs, :red), do: Enum.at(tcs, 2)
  defp term_color(tcs, :red_bright), do: Enum.at(tcs, 9)
  defp term_color(tcs, :red_dim), do: Enum.at(tcs, 2)

  defp term_color(tcs, :green), do: Enum.at(tcs, 2)
  defp term_color(tcs, :green_bright), do: Enum.at(tcs, 10)
  defp term_color(tcs, :green_dim), do: Enum.at(tcs, 2)

  defp term_color(tcs, :yellow), do: Enum.at(tcs, 3)
  defp term_color(tcs, :yellow_bright), do: Enum.at(tcs, 11)
  defp term_color(tcs, :yellow_dim), do: Enum.at(tcs, 3)

  defp term_color(tcs, :blue), do: Enum.at(tcs, 4)
  defp term_color(tcs, :blue_bright), do: Enum.at(tcs, 12)
  defp term_color(tcs, :blue_dim), do: Enum.at(tcs, 4)

  defp term_color(tcs, :magenta), do: Enum.at(tcs, 5)
  defp term_color(tcs, :magenta_bright), do: Enum.at(tcs, 13)
  defp term_color(tcs, :magenta_dim), do: Enum.at(tcs, 5)

  defp term_color(tcs, :cyan), do: Enum.at(tcs, 6)
  defp term_color(tcs, :cyan_bright), do: Enum.at(tcs, 14)
  defp term_color(tcs, :cyan_dim), do: Enum.at(tcs, 6)

  defp term_color(tcs, :white), do: Enum.at(tcs, 7)
  defp term_color(tcs, :white_bright), do: Enum.at(tcs, 15)
  defp term_color(tcs, :white_dim), do: Enum.at(tcs, 7)
end
