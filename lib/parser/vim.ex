defmodule ChromaBabel.Parser.Vim do
  import NimbleParsec

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

  highlight_link =
    ignore(string("highlight! link"))
    |> ignore(whitespace)
    |> concat(word)
    |> ignore(whitespace)
    |> concat(word)
    |> reduce({__MODULE__, :transform, [:highlight_link]})

  line =
    ignore(repeat(whitespace))
    |> choice([
      term_color,
      highlight_clear,
      highlight,
      highlight_link,
      ignore_line
    ])
    |> ignore(eol)

  defparsec(:parse, repeat(line))

  def transform([index, color], :term_color),
    do: {:term_color, %{index: index, color: color}}

  def transform([to, from], :highlight_link),
    do: {:highlight_link, %{to: to, from: from}}

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

    linked_highlights =
      parsed
      |> Keyword.get_values(:highlight_link)
      |> Map.new(fn %{from: from, to: to} ->
        {from, highlights[to] || highlights["Normal"]}
      end)

    all_highlights = Map.merge(highlights, linked_highlights)

    {:ok, %{term_colors: term_colors, highlights: all_highlights}}
  end

  defp highlight(map) do
    map
    |> Map.take([:guifg, :guibg, :guisp, :gui])
    |> map_keys(&attr/1)
    |> map_values(&style/1)
  end

  defp attr(:guifg), do: :foreground
  defp attr(:guibg), do: :background
  defp attr(:guisp), do: :special
  defp attr(:gui), do: :style

  defp style("bold"), do: [:bold]
  defp style("italic"), do: [:italic]
  defp style("underline"), do: [:underline]
  defp style("undercurl"), do: [:undercurl]
  defp style("NONE"), do: nil
  defp style("#" <> hex), do: "#" <> hex
  defp style(l) when is_list(l), do: Enum.flat_map(l, &style/1)

  defp map_keys(m, f), do: Map.new(m, fn {k, v} -> {f.(k), v} end)
  defp map_values(m, f), do: Map.new(m, fn {k, v} -> {k, f.(v)} end)
end
