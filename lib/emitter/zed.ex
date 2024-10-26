defmodule ChromaBabel.Emitter.Zed do
  defp fg(n, h),
    do: (n.highlights[h] || n.highlights["Normal"]).foreground

  defp tc(n, i),
    do: Enum.at(n.term_colors, i)

  def emit(opts, n) do
    fg(n, "Normal")

    %{
      "$schema" => "https://zed.dev/schema/themes/v0.1.0.json",
      "name" => opts[:name],
      "author" => opts[:author],
      "themes" => [
        %{
          "name" => opts[:name],
          "appearance" => opts[:appearance],
          "style" => %{
            "border" => "#56505eff",
            "border.variant" => "#332f38ff",
            "border.focused" => "#222953ff",
            "border.selected" => "#222953ff",
            "border.transparent" => "#00000000",
            "border.disabled" => "#48434fff",
            "elevated_surface.background" => "#221f26ff",
            "surface.background" => "#221f26ff",
            "background" => "#ff0000",
            "element.background" => "#221f26ff",
            "element.hover" => "#332f38ff",
            "element.active" => "#544f5cff",
            "element.selected" => "#544f5cff",
            "element.disabled" => "#221f26ff",
            "drop_target.background" => "#89859180",
            "ghost_element.background" => "#00000000",
            "ghost_element.hover" => "#332f38ff",
            "ghost_element.active" => "#544f5cff",
            "ghost_element.selected" => "#544f5cff",
            "ghost_element.disabled" => "#221f26ff",
            "text" => "#efecf4ff",
            "text.muted" => "#898591ff",
            "text.placeholder" => "#756f7eff",
            "text.disabled" => "#756f7eff",
            "text.accent" => "#566ddaff",
            "icon" => "#efecf4ff",
            "icon.muted" => "#898591ff",
            "icon.disabled" => "#756f7eff",
            "icon.placeholder" => "#898591ff",
            "icon.accent" => "#566ddaff",
            "status_bar.background" => "#3a353fff",
            "title_bar.background" => "#3a353fff",
            "title_bar.inactive_background" => "#221f26ff",
            "toolbar.background" => "#19171cff",
            "tab_bar.background" => "#221f26ff",
            "tab.inactive_background" => "#221f26ff",
            "tab.active_background" => "#19171cff",
            "search.match_background" => "#576dda66",
            "panel.background" => "#221f26ff",
            "panel.focused_border" => nil,
            "pane.focused_border" => nil,
            "scrollbar.thumb.background" => "#efecf44c",
            "scrollbar.thumb.hover_background" => "#332f38ff",
            "scrollbar.thumb.border" => "#332f38ff",
            "scrollbar.track.background" => "#00000000",
            "scrollbar.track.border" => "#201e24ff",
            "editor.foreground" => "#e2dfe7ff",
            "editor.background" => "#19171cff",
            "editor.gutter.background" => "#19171cff",
            "editor.subheader.background" => "#221f26ff",
            "editor.active_line.background" => "#221f26bf",
            "editor.highlighted_line.background" => "#221f26ff",
            "editor.line_number" => "#efecf459",
            "editor.active_line_number" => "#efecf4ff",
            "editor.invisible" => "#726c7aff",
            "editor.wrap_guide" => "#efecf40d",
            "editor.active_wrap_guide" => "#efecf41a",
            "editor.document_highlight.read_background" => "#566dda1a",
            "editor.document_highlight.write_background" => "#726c7a66",
            "terminal.background" => "#19171cff",
            "terminal.foreground" => "#efecf4ff",
            "terminal.bright_foreground" => "#efecf4ff",
            "terminal.dim_foreground" => "#19171cff",
            "terminal.ansi.black" => "#19171cff",
            "terminal.ansi.bright_black" => "#635d6bff",
            "terminal.ansi.dim_black" => "#efecf4ff",
            "terminal.ansi.red" => "#be4677ff",
            "terminal.ansi.bright_red" => "#5c283cff",
            "terminal.ansi.dim_red" => "#e3a4b9ff",
            "terminal.ansi.green" => "#2b9292ff",
            "terminal.ansi.bright_green" => "#1f4747ff",
            "terminal.ansi.dim_green" => "#9dc8c8ff",
            "terminal.ansi.yellow" => "#a06d3aff",
            "terminal.ansi.bright_yellow" => "#4e3821ff",
            "terminal.ansi.dim_yellow" => "#d4b499ff",
            "terminal.ansi.blue" => "#566ddaff",
            "terminal.ansi.bright_blue" => "#2d376fff",
            "terminal.ansi.dim_blue" => "#b3b3eeff",
            "terminal.ansi.magenta" => "#bf41bfff",
            "terminal.ansi.bright_magenta" => "#60255aff",
            "terminal.ansi.dim_magenta" => "#e3a4dfff",
            "terminal.ansi.cyan" => "#3a8bc6ff",
            "terminal.ansi.bright_cyan" => "#26435eff",
            "terminal.ansi.dim_cyan" => "#a6c4e3ff",
            "terminal.ansi.white" => "#efecf4ff",
            "terminal.ansi.bright_white" => "#efecf4ff",
            "terminal.ansi.dim_white" => "#807b89ff",
            "link_text.hover" => "#566ddaff",
            "conflict" => "#a06d3aff",
            "conflict.background" => "#231a12ff",
            "conflict.border" => "#392a19ff",
            "created" => "#2b9292ff",
            "created.background" => "#132020ff",
            "created.border" => "#1a3333ff",
            "deleted" => "#be4677ff",
            "deleted.background" => "#28151cff",
            "deleted.border" => "#421e2dff",
            "error" => "#be4677ff",
            "error.background" => "#28151cff",
            "error.border" => "#421e2dff",
            "hidden" => "#756f7eff",
            "hidden.background" => "#3a353fff",
            "hidden.border" => "#48434fff",
            "hint" => "#706897ff",
            "hint.background" => "#161a35ff",
            "hint.border" => "#222953ff",
            "ignored" => "#756f7eff",
            "ignored.background" => "#3a353fff",
            "ignored.border" => "#56505eff",
            "info" => "#566ddaff",
            "info.background" => "#161a35ff",
            "info.border" => "#222953ff",
            "modified" => "#a06d3aff",
            "modified.background" => "#231a12ff",
            "modified.border" => "#392a19ff",
            "predictive" => "#615787ff",
            "predictive.background" => "#132020ff",
            "predictive.border" => "#1a3333ff",
            "renamed" => "#566ddaff",
            "renamed.background" => "#161a35ff",
            "renamed.border" => "#222953ff",
            "success" => "#2b9292ff",
            "success.background" => "#132020ff",
            "success.border" => "#1a3333ff",
            "unreachable" => "#898591ff",
            "unreachable.background" => "#3a353fff",
            "unreachable.border" => "#56505eff",
            "warning" => "#a06d3aff",
            "warning.background" => "#231a12ff",
            "warning.border" => "#392a19ff",
            "players" => [
              %{
                "cursor" => "#566ddaff",
                "background" => "#566ddaff",
                "selection" => "#566dda3d"
              },
              %{
                "cursor" => "#bf41bfff",
                "background" => "#bf41bfff",
                "selection" => "#bf41bf3d"
              },
              %{
                "cursor" => "#aa563bff",
                "background" => "#aa563bff",
                "selection" => "#aa563b3d"
              },
              %{
                "cursor" => "#955ae6ff",
                "background" => "#955ae6ff",
                "selection" => "#955ae63d"
              },
              %{
                "cursor" => "#3a8bc6ff",
                "background" => "#3a8bc6ff",
                "selection" => "#3a8bc63d"
              },
              %{
                "cursor" => "#be4677ff",
                "background" => "#be4677ff",
                "selection" => "#be46773d"
              },
              %{
                "cursor" => "#a06d3aff",
                "background" => "#a06d3aff",
                "selection" => "#a06d3a3d"
              },
              %{
                "cursor" => "#2b9292ff",
                "background" => "#2b9292ff",
                "selection" => "#2b92923d"
              }
            ],
            "syntax" => %{
              "attribute" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "boolean" => %{
                "color" => "#2b9292ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "comment" => %{
                "color" => "#655f6dff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "comment.doc" => %{
                "color" => "#8b8792ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "constant" => %{
                "color" => "#2b9292ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "constructor" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "embedded" => %{
                "color" => "#efecf4ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "emphasis" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "emphasis.strong" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => 700
              },
              "enum" => %{
                "color" => "#aa563bff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "function" => %{
                "color" => "#576cdbff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "function.method" => %{
                "color" => "#576cdbff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "function.special.definition" => %{
                "color" => "#a06d3aff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "hint" => %{
                "color" => "#706897ff",
                "font_style" => nil,
                "font_weight" => 700
              },
              "keyword" => %{
                "color" => "#9559e7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "label" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "link_text" => %{
                "color" => "#aa563bff",
                "font_style" => "italic",
                "font_weight" => nil
              },
              "link_uri" => %{
                "color" => "#2b9292ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "number" => %{
                "color" => "#aa563bff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "operator" => %{
                "color" => "#8b8792ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "predictive" => %{
                "color" => "#615787ff",
                "font_style" => "italic",
                "font_weight" => nil
              },
              "preproc" => %{
                "color" => "#efecf4ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "primary" => %{
                "color" => "#e2dfe7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "property" => %{
                "color" => "#be4677ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "punctuation" => %{
                "color" => "#e2dfe7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "punctuation.bracket" => %{
                "color" => "#8b8792ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "punctuation.delimiter" => %{
                "color" => "#8b8792ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "punctuation.list_marker" => %{
                "color" => "#e2dfe7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "punctuation.special" => %{
                "color" => "#bf3fbfff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "string" => %{
                "color" => "#299292ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "string.escape" => %{
                "color" => "#8b8792ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "string.regex" => %{
                "color" => "#388bc6ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "string.special" => %{
                "color" => "#bf3fbfff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "string.special.symbol" => %{
                "color" => "#299292ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "tag" => %{
                "color" => "#566ddaff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "text.literal" => %{
                "color" => "#aa563bff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "title" => %{
                "color" => "#efecf4ff",
                "font_style" => nil,
                "font_weight" => 700
              },
              "type" => %{
                "color" => "#a06d3aff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "variable" => %{
                "color" => "#e2dfe7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "variable.special" => %{
                "color" => "#9559e7ff",
                "font_style" => nil,
                "font_weight" => nil
              },
              "variant" => %{
                "color" => "#a06d3aff",
                "font_style" => nil,
                "font_weight" => nil
              }
            }
          }
        }
      ]
    }
  end
end
