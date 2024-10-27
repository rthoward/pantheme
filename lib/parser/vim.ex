defmodule PanTheme.Parser.Vim do
  import NimbleParsec

  alias PanTheme.AST

  require Logger

  eol =
    choice([
      string("\r\n"),
      string("\n")
    ])

  whitespace =
    ascii_char(~c" ")

  ignore_line =
    ignore(utf8_string([not: ?\n], min: 0))

  word =
    ignore(repeat(whitespace))
    |> ascii_string([?a..?z, ?A..?Z], min: 1)

  hex_code =
    ascii_string([?A..?F, ?0..?9, ?#], min: 1)

  term_color =
    ignore(string("let g:terminal_color_"))
    |> integer(min: 1)
    |> ignore(string(" = '"))
    |> concat(hex_code)
    |> ignore(string("'"))
    |> reduce({__MODULE__, :transform, [:term_color]})

  font_style =
    choice([
      string("bold"),
      string("italic"),
      string("underline"),
      string("undercurl"),
      ignore(string(","))
    ])

  font_styles =
    repeat(font_style)
    |> wrap()

  highlight_color =
    ignore(repeat(whitespace))
    |> choice([
      string("guifg"),
      string("guibg"),
      string("guisp"),
      string("gui"),
      string("cterm")
    ])
    |> ignore(string("="))
    |> choice([
      string("NONE"),
      hex_code,
      font_styles
    ])
    |> wrap()

  highlight_clear =
    ignore(string("highlight clear"))

  highlight =
    ignore(string("highlight"))
    |> concat(word)
    |> repeat(highlight_color)
    |> reduce({__MODULE__, :transform, [:highlight]})

  link =
    ignore(string("highlight! link"))
    |> ignore(whitespace)
    |> concat(word)
    |> ignore(whitespace)
    |> concat(word)
    |> reduce({__MODULE__, :transform, [:link]})

  line =
    ignore(repeat(whitespace))
    |> choice([
      term_color,
      highlight_clear,
      highlight,
      link,
      ignore_line
    ])
    |> ignore(eol)

  defparsec(:parse, repeat(line))

  def transform([index, color], :term_color),
    do: {:term_color, %{index: index, color: color}}

  def transform([to, from], :link),
    do: {:link, %{to: to, from: from}}

  def transform([name | colors], :highlight) do
    {:highlight,
     Enum.reduce(colors, %{name: name}, fn [type, color], acc ->
       Map.put(acc, String.to_atom(type), color)
     end)}
  end

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
        resolved =
          if match = highlights[from] do
            match
          else
            Logger.debug(
              "Couldn't resolve `highlight! link #{to} #{from}.` " <>
                "#{from} not found. Defaulting to Normal."
            )

            highlights["Normal"]
          end

        {to, resolved}
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

  @spec to_ast(map()) :: AST.t()
  def to_ast(%{term_colors: tcs, highlights: hs}) do
    %AST{
      editor: %AST.Editor{
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
      ui: %AST.UI{
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
        border: %AST.Element{
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
        conflict: %AST.Container{
          fg: hi(hs, "DiffText", :fg),
          bg: hi(hs, "DiffChange", :bg),
          border: hi(hs, "FloatBorder", :bg)
        },
        created: %AST.Container{
          fg: hi(hs, "GitSignsAdd", :fg),
          bg: hi(hs, "GitSignsAdd", :fg),
          border: hi(hs, "GitSignsAdd", :fg)
        },
        deleted: %AST.Container{
          fg: hi(hs, "GitSignsDelete", :fg),
          bg: hi(hs, "GitSignsDelete", :fg),
          border: hi(hs, "GitSignsDelete", :fg)
        },
        drop_target_bg: hi(hs, "Normal", :bg),
        element: %AST.Element{
          color: hi(hs, "Normal", :bg),
          active: hi(hs, ["Title", "Special"], :fg),
          disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          focused: hi(hs, ["CursorLine"], :bg),
          hover: hi(hs, ["PmenuSel"], :bg),
          selected: hi(hs, ["Visual", "PmenuSel"], :fg),
          transparent: hi(hs, "Conceal", :fg),
          variant: hi(hs, "Special", :fg)
        },
        error: %AST.Container{
          fg: hi(hs, ["DiagnosticError", "Error"], :fg),
          bg: hi(hs, ["DiagnosticError", "Error"], :bg),
          border: hi(hs, ["DiagnosticError", "Error"], :bg)
        },
        ghost_element: %AST.Element{
          color: hi(hs, "Normal", :bg),
          active: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          focused: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          hover: hi(hs, ["PmenuThumb", "CursorLine"], :bg),
          selected: hi(hs, ["PmenuSel", "CursorLine"], :bg),
          transparent: hi(hs, "Conceal", :fg),
          variant: hi(hs, "Special", :fg)
        },
        hidden: %AST.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        hint: %AST.Container{
          fg: hi(hs, ["LspInlayHint", "Comment"], :fg),
          bg: hi(hs, ["LspInlayHint", "Comment"], :bg),
          border: hi(hs, ["LspInlayHint", "Comment"], :bg)
        },
        icon: %AST.Text{
          fg: hi(hs, "Normal", :fg),
          fg_accent: hi(hs, ["Title", "Special"], :fg),
          fg_disabled: hi(hs, ["NonText", "StatusLineNC"], :fg),
          fg_muted: hi(hs, ["Comment", "LineNr", "LspInlayHint"], :fg),
          fg_placeholder: hi(hs, ["Conceal", "NonText", "Comment"], :fg)
        },
        ignored: %AST.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        info: %AST.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        link_text_hover: hi(hs, "Normal", :fg),
        modified: %AST.Container{
          fg: hi(hs, "GitSignsChange", :fg),
          bg: hi(hs, "GitSignsChange", :fg),
          border: hi(hs, "GitSignsChange", :fg)
        },
        predictive: %AST.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        renamed: %AST.Container{
          fg: hi(hs, "DiffText", :fg),
          bg: hi(hs, "DiffChange", :bg),
          border: hi(hs, "FloatBorder", :bg)
        },
        success: %AST.Container{
          fg: hi(hs, "DiagnosticOk", :fg),
          bg: hi(hs, "DiagnosticOk", :bg),
          border: hi(hs, "DiagnosticOk", :bg)
        },
        text: %AST.Text{
          fg: hi(hs, "Normal", :fg),
          fg_accent: hi(hs, "Normal", :fg),
          fg_disabled: hi(hs, "Normal", :fg),
          fg_muted: hi(hs, "Normal", :fg),
          fg_placeholder: hi(hs, "Normal", :fg)
        },
        unreachable: %AST.Container{
          fg: hi(hs, "Normal", :fg),
          bg: hi(hs, "Normal", :bg),
          border: hi(hs, "Normal", :bg)
        },
        warning: %AST.Container{
          fg: hi(hs, "DiagnosticWarn", :fg),
          bg: hi(hs, "DiagnosticWarn", :bg),
          border: hi(hs, "DiagnosticWarn", :bg)
        }
      },
      syntax: %AST.Syntax{
        attribute: %AST.Text{
          fg: hi(hs, ["Identifier", "Special", "Type"], :fg),
          style: hi(hs, ["Identifier", "Special", "Type"], :style) |> style(),
          weight: hi(hs, ["Identifier", "Special", "Type"], :style) |> weight()
        },
        boolean: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        comment: %AST.Text{
          fg: hi(hs, "Comment", :fg),
          style: hi(hs, "Comment", :style) |> style(),
          weight: hi(hs, "Comment", :style) |> weight()
        },
        constant: %AST.Text{
          fg: hi(hs, "Constant", :fg),
          style: hi(hs, "Constant", :style) |> style(),
          weight: hi(hs, "Constant", :style) |> weight()
        },
        constructor: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        docstring: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        embedded: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        emphasis: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        emphasis_strong: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        enum: %AST.Text{
          fg: hi(hs, ["Type", "Constant"], :fg),
          style: hi(hs, ["Type", "Constant"], :style) |> style(),
          weight: hi(hs, ["Type", "Constant"], :style) |> weight()
        },
        function: %AST.Text{
          fg: hi(hs, "Function", :fg),
          style: hi(hs, "Function", :style) |> style(),
          weight: hi(hs, "Function", :style) |> weight()
        },
        function_def: %AST.Text{
          fg: hi(hs, "Function", :fg),
          style: hi(hs, "Function", :style) |> style(),
          weight: hi(hs, "Function", :style) |> weight()
        },
        hint: %AST.Text{
          fg: hi(hs, ["DiagnosticHint", "LspInlayHint", "Comment"], :fg),
          style: hi(hs, ["DiagnosticHint", "LspInlayHint", "Comment"], :style) |> style(),
          weight: hi(hs, ["DiagnosticHint", "LspInlayHint", "Comment"], :style) |> weight()
        },
        keyword: %AST.Text{
          fg: hi(hs, ["Statement", "Type"], :fg),
          style: hi(hs, ["Statement", "Type"], :style) |> style(),
          weight: hi(hs, ["Statement", "Type"], :style) |> weight()
        },
        label: %AST.Text{
          fg: hi(hs, ["Label", "Identifier"], :fg),
          style: hi(hs, ["Label", "Identifier"], :style) |> style(),
          weight: hi(hs, ["Label", "Identifier"], :style) |> weight()
        },
        link_text: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        link_uri: %AST.Text{
          fg: hi(hs, ["Normal"], :fg),
          style: hi(hs, ["Normal"], :style) |> style(),
          weight: hi(hs, ["Normal"], :style) |> weight()
        },
        method: %AST.Text{
          fg: hi(hs, "Function", :fg),
          style: hi(hs, "Function", :style) |> style(),
          weight: hi(hs, "Function", :style) |> weight()
        },
        number: %AST.Text{
          fg: hi(hs, ["Number", "Constant"], :fg),
          style: hi(hs, ["Number", "Constant"], :style) |> style(),
          weight: hi(hs, ["Number", "Constant"], :style) |> weight()
        },
        operator: %AST.Text{
          fg: hi(hs, "Operator", :fg),
          style: hi(hs, "Operator", :style) |> style(),
          weight: hi(hs, "Operator", :style) |> weight()
        },
        predictive: %AST.Text{
          fg: hi(hs, ["DiagnosticHint", "Comment"], :fg),
          style: hi(hs, ["DiagnosticHint", "Comment"], :style) |> style(),
          weight: hi(hs, ["DiagnosticHint", "Comment"], :style) |> weight()
        },
        preproc: %AST.Text{
          fg: hi(hs, ["PreProc", "Special"], :fg),
          style: hi(hs, ["PreProc", "Special"], :style) |> style(),
          weight: hi(hs, ["PreProc", "Special"], :style) |> weight()
        },
        primary: %AST.Text{
          fg: hi(hs, "Identifier", :fg),
          style: hi(hs, "Identifier", :style) |> style(),
          weight: hi(hs, "Identifier", :style) |> weight()
        },
        property: %AST.Text{
          fg: hi(hs, "Identifier", :fg),
          style: hi(hs, "Identifier", :style) |> style(),
          weight: hi(hs, "Identifier", :style) |> weight()
        },
        punct: %AST.Text{
          fg: hi(hs, "Delimiter", :fg),
          style: hi(hs, "Delimiter", :style) |> style(),
          weight: hi(hs, "Delimiter", :style) |> weight()
        },
        punct_bracket: %AST.Text{
          fg: hi(hs, "Delimiter", :fg),
          style: hi(hs, "Delimiter", :style) |> style(),
          weight: hi(hs, "Delimiter", :style) |> weight()
        },
        punct_delimiter: %AST.Text{
          fg: hi(hs, "Delimiter", :fg),
          style: hi(hs, "Delimiter", :style) |> style(),
          weight: hi(hs, "Delimiter", :style) |> weight()
        },
        punct_list_marker: %AST.Text{
          fg: hi(hs, "Delimiter", :fg),
          style: hi(hs, "Delimiter", :style) |> style(),
          weight: hi(hs, "Delimiter", :style) |> weight()
        },
        punct_special: %AST.Text{
          fg: hi(hs, "Delimiter", :fg),
          style: hi(hs, "Delimiter", :style) |> style(),
          weight: hi(hs, "Delimiter", :style) |> weight()
        },
        string: %AST.Text{
          fg: hi(hs, "String", :fg),
          style: hi(hs, "String", :style) |> style(),
          weight: hi(hs, "String", :style) |> weight()
        },
        string_escape: %AST.Text{
          fg: hi(hs, "String", :fg),
          style: hi(hs, "String", :style) |> style(),
          weight: hi(hs, "String", :style) |> weight()
        },
        string_regex: %AST.Text{
          fg: hi(hs, "String", :fg),
          style: hi(hs, "String", :style) |> style(),
          weight: hi(hs, "String", :style) |> weight()
        },
        string_special: %AST.Text{
          fg: hi(hs, "String", :fg),
          style: hi(hs, "String", :style) |> style(),
          weight: hi(hs, "String", :style) |> weight()
        },
        string_symbol: %AST.Text{
          fg: hi(hs, "Constant", :fg),
          style: hi(hs, "Constant", :style) |> style(),
          weight: hi(hs, "Constant", :style) |> weight()
        },
        tag: %AST.Text{
          fg: hi(hs, "Constant", :fg),
          style: hi(hs, "Constant", :style) |> style(),
          weight: hi(hs, "Constant", :style) |> weight()
        },
        text_literal: %AST.Text{
          fg: hi(hs, "String", :fg),
          style: hi(hs, "String", :style) |> style(),
          weight: hi(hs, "String", :style) |> weight()
        },
        title: %AST.Text{
          fg: hi(hs, "Title", :fg),
          style: hi(hs, "Title", :style) |> style(),
          weight: hi(hs, "Title", :style) |> weight()
        },
        type: %AST.Text{
          fg: hi(hs, "Type", :fg),
          style: hi(hs, "Type", :style) |> style(),
          weight: hi(hs, "Type", :style) |> weight()
        },
        variable: %AST.Text{
          fg: hi(hs, "Identifier", :fg),
          style: hi(hs, "Identifier", :style) |> style(),
          weight: hi(hs, "Identifier", :style) |> weight()
        },
        variable_special: %AST.Text{
          fg: hi(hs, "Identifier", :fg),
          style: hi(hs, "Identifier", :style) |> style(),
          weight: hi(hs, "Identifier", :style) |> weight()
        },
        variant: %AST.Text{
          fg: hi(hs, ["Type", "Identifier"], :fg),
          style: hi(hs, ["Type", "Identifier"], :style) |> style(),
          weight: hi(hs, ["Type", "Identifier"], :style) |> weight()
        }
      },
      term: %AST.TermColors{
        bg: term_color(tcs, :bg),
        fg: %AST.TermColor{
          normal: term_color(tcs, :fg),
          bright: term_color(tcs, :fg_bright),
          dim: term_color(tcs, :fg_dim)
        },
        black: %AST.TermColor{
          normal: term_color(tcs, :black),
          bright: term_color(tcs, :black_bright),
          dim: term_color(tcs, :black_dim)
        },
        red: %AST.TermColor{
          normal: term_color(tcs, :red),
          bright: term_color(tcs, :red_bright),
          dim: term_color(tcs, :red_dim)
        },
        green: %AST.TermColor{
          normal: term_color(tcs, :green),
          bright: term_color(tcs, :green_bright),
          dim: term_color(tcs, :green_dim)
        },
        yellow: %AST.TermColor{
          normal: term_color(tcs, :yellow),
          bright: term_color(tcs, :yellow_bright),
          dim: term_color(tcs, :yellow_dim)
        },
        blue: %AST.TermColor{
          normal: term_color(tcs, :blue),
          bright: term_color(tcs, :blue_bright),
          dim: term_color(tcs, :blue_dim)
        },
        magenta: %AST.TermColor{
          normal: term_color(tcs, :magenta),
          bright: term_color(tcs, :magenta_bright),
          dim: term_color(tcs, :magenta_dim)
        },
        cyan: %AST.TermColor{
          normal: term_color(tcs, :cyan),
          bright: term_color(tcs, :cyan_bright),
          dim: term_color(tcs, :cyan_dim)
        },
        white: %AST.TermColor{
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
