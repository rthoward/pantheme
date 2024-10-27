defmodule PanTheme.Emitter.Zed do
  alias PanTheme.AST

  @spec emit(AST.t(), keyword()) :: map()
  def emit(ast, opts) do
    %{
      "$schema" => "https://zed.dev/schema/themes/v0.1.0.json",
      "name" => opts[:name],
      "author" => opts[:author],
      "themes" => [
        %{
          "name" => opts[:name],
          "appearance" => opts[:appearance],
          "style" => %{
            "border" => ast.ui.border.color,
            "border.variant" => ast.ui.border.variant,
            "border.focused" => ast.ui.border.focused,
            "border.selected" => ast.ui.border.selected,
            "border.transparent" => ast.ui.border.transparent,
            "border.disabled" => ast.ui.border.disabled,
            "elevated_surface.background" => ast.ui.bg,
            "surface.background" => ast.ui.bg,
            "background" => ast.ui.bg,
            "element.background" => ast.ui.element.color,
            "element.hover" => ast.ui.element.hover,
            "element.active" => ast.ui.element.active,
            "element.selected" => ast.ui.element.selected,
            "element.disabled" => ast.ui.element.disabled,
            "drop_target.background" => "#89859180",
            "ghost_element.background" => ast.ui.ghost_element.color,
            "ghost_element.hover" => ast.ui.ghost_element.hover,
            "ghost_element.active" => ast.ui.ghost_element.active,
            "ghost_element.selected" => ast.ui.ghost_element.selected,
            "ghost_element.disabled" => ast.ui.ghost_element.disabled,
            "text" => ast.ui.text.fg,
            "text.accent" => ast.ui.text.fg_accent,
            "text.disabled" => ast.ui.text.fg_disabled,
            "text.muted" => ast.ui.text.fg_muted,
            "text.placeholder" => ast.ui.text.fg_placeholder,
            "icon" => ast.ui.icon.fg,
            "icon.accent" => ast.ui.icon.fg_accent,
            "icon.disabled" => ast.ui.icon.fg_disabled,
            "icon.muted" => ast.ui.icon.fg_muted,
            "icon.placeholder" => ast.ui.icon.fg_placeholder,
            "status_bar.background" => ast.ui.status_bar_bg,
            "title_bar.background" => ast.ui.title_bar_bg,
            "title_bar.inactive_background" => ast.ui.title_bar_inactive_bg,
            "toolbar.background" => ast.ui.toolbar_bg,
            "tab_bar.background" => ast.ui.tab_bar_bg,
            "tab.inactive_background" => ast.ui.tab_inactive_bg,
            "tab.active_background" => ast.ui.tab_active_bg,
            "search.match_background" => ast.ui.search_match_bg,
            "panel.background" => ast.ui.panel_bg,
            "panel.focused_border" => ast.ui.panel_focused_bg,
            "pane.focused_border" => ast.ui.border.focused,
            "scrollbar.thumb.background" => ast.ui.scrollbar_thumb_bg,
            "scrollbar.thumb.hover_background" => ast.ui.scrollbar_thumb_hover_bg,
            "scrollbar.thumb.border" => ast.ui.scrollbar_thumb_border,
            "scrollbar.track.background" => ast.ui.scrollbar_track_bg,
            "scrollbar.track.border" => ast.ui.scrollbar_track_border,
            "editor.foreground" => ast.editor.fg,
            "editor.background" => ast.editor.bg,
            "editor.gutter.background" => ast.editor.bg,
            "editor.subheader.background" => ast.editor.subheader_bg,
            "editor.active_line.background" => ast.editor.active_line_bg,
            "editor.highlighted_line.background" => ast.editor.highlighted_line_bg,
            "editor.line_number" => ast.editor.line_number,
            "editor.active_line_number" => ast.editor.line_number_active,
            "editor.invisible" => "#726c7aff",
            "editor.wrap_guide" => "#efecf40d",
            "editor.active_wrap_guide" => "#efecf41a",
            "editor.document_highlight.read_background" => "#566dda1a",
            "editor.document_highlight.write_background" => "#726c7a66",

            # Terminal colors
            "terminal.background" => ast.term.bg,
            "terminal.foreground" => ast.term.fg.normal,
            "terminal.bright_foreground" => ast.term.fg.bright,
            "terminal.dim_foreground" => ast.term.fg.dim,
            "terminal.ansi.black" => ast.term.black.normal,
            "terminal.ansi.bright_black" => ast.term.black.bright,
            "terminal.ansi.dim_black" => ast.term.black.dim,
            "terminal.ansi.red" => ast.term.red.normal,
            "terminal.ansi.bright_red" => ast.term.red.bright,
            "terminal.ansi.dim_red" => ast.term.red.dim,
            "terminal.ansi.green" => ast.term.green.normal,
            "terminal.ansi.bright_green" => ast.term.green.bright,
            "terminal.ansi.dim_green" => ast.term.green.dim,
            "terminal.ansi.yellow" => ast.term.yellow.normal,
            "terminal.ansi.bright_yellow" => ast.term.yellow.bright,
            "terminal.ansi.dim_yellow" => ast.term.yellow.dim,
            "terminal.ansi.blue" => ast.term.blue.normal,
            "terminal.ansi.bright_blue" => ast.term.blue.bright,
            "terminal.ansi.dim_blue" => ast.term.blue.dim,
            "terminal.ansi.magenta" => ast.term.magenta.normal,
            "terminal.ansi.bright_magenta" => ast.term.magenta.bright,
            "terminal.ansi.dim_magenta" => ast.term.magenta.dim,
            "terminal.ansi.cyan" => ast.term.cyan.normal,
            "terminal.ansi.bright_cyan" => ast.term.cyan.bright,
            "terminal.ansi.dim_cyan" => ast.term.cyan.dim,
            "terminal.ansi.white" => ast.term.white.normal,
            "terminal.ansi.bright_white" => ast.term.white.bright,
            "terminal.ansi.dim_white" => ast.term.white.dim,
            "link_text.hover" => "#566ddaff",

            # Containers
            "conflict" => ast.ui.conflict.fg,
            "conflict.background" => ast.ui.conflict.bg,
            "conflict.border" => ast.ui.conflict.border,
            "created" => ast.ui.created.fg,
            "created.background" => ast.ui.created.bg,
            "created.border" => ast.ui.created.border,
            "deleted" => ast.ui.deleted.fg,
            "deleted.background" => ast.ui.deleted.bg,
            "deleted.border" => ast.ui.deleted.border,
            "error" => ast.ui.error.fg,
            "error.background" => ast.ui.error.bg,
            "error.border" => ast.ui.error.border,
            "hidden" => ast.ui.hidden.fg,
            "hidden.background" => ast.ui.hidden.bg,
            "hidden.border" => ast.ui.hidden.border,
            "hint" => ast.ui.hint.fg,
            "hint.background" => ast.ui.hint.bg,
            "hint.border" => ast.ui.hint.border,
            "ignored" => ast.ui.ignored.fg,
            "ignored.background" => ast.ui.ignored.bg,
            "ignored.border" => ast.ui.ignored.border,
            "info" => ast.ui.info.fg,
            "info.background" => ast.ui.info.bg,
            "info.border" => ast.ui.info.border,
            "modified" => ast.ui.modified.fg,
            "modified.background" => ast.ui.modified.bg,
            "modified.border" => ast.ui.modified.border,
            "predictive" => ast.ui.predictive.fg,
            "predictive.background" => ast.ui.predictive.bg,
            "predictive.border" => ast.ui.predictive.border,
            "renamed" => ast.ui.renamed.fg,
            "renamed.background" => ast.ui.renamed.bg,
            "renamed.border" => ast.ui.renamed.border,
            "success" => ast.ui.success.fg,
            "success.background" => ast.ui.success.bg,
            "success.border" => ast.ui.success.border,
            "unreachable" => ast.ui.unreachable.fg,
            "unreachable.background" => ast.ui.unreachable.bg,
            "unreachable.border" => ast.ui.unreachable.border,
            "warning" => ast.ui.warning.fg,
            "warning.background" => ast.ui.warning.bg,
            "warning.border" => ast.ui.warning.border,

            # Players
            "players" => [
              %{
                # TODO
                "cursor" => ast.term.blue.normal,
                "background" => ast.editor.bg,
                "selection" => ast.editor.selection_bg
              },
              %{
                "cursor" => ast.term.green.normal,
                "background" => ast.term.green.normal,
                "selection" => ast.term.green.bright
              },
              %{
                "cursor" => ast.term.yellow.normal,
                "background" => ast.term.yellow.normal,
                "selection" => ast.term.yellow.bright
              },
              %{
                "cursor" => ast.term.red.normal,
                "background" => ast.term.red.normal,
                "selection" => ast.term.red.bright
              },
              %{
                "cursor" => ast.term.magenta.normal,
                "background" => ast.term.magenta.normal,
                "selection" => ast.term.magenta.bright
              },
              %{
                "cursor" => ast.term.cyan.normal,
                "background" => ast.term.cyan.normal,
                "selection" => ast.term.cyan.bright
              }
            ],
            "syntax" => %{
              "attribute" => %{
                "color" => ast.syntax.attribute.fg,
                "font_style" => ast.syntax.attribute.style,
                "font_weight" => ast.syntax.attribute.weight
              },
              "boolean" => %{
                "color" => ast.syntax.boolean.fg,
                "font_style" => ast.syntax.boolean.style,
                "font_weight" => ast.syntax.boolean.weight
              },
              "comment" => %{
                "color" => ast.syntax.comment.fg,
                "font_style" => ast.syntax.comment.style,
                "font_weight" => ast.syntax.comment.weight
              },
              "comment.doc" => %{
                "color" => ast.syntax.docstring.fg,
                "font_style" => ast.syntax.docstring.style,
                "font_weight" => ast.syntax.docstring.weight
              },
              "constant" => %{
                "color" => ast.syntax.constant.fg,
                "font_style" => ast.syntax.constant.style,
                "font_weight" => ast.syntax.constant.weight
              },
              "constructor" => %{
                "color" => ast.syntax.constructor.fg,
                "font_style" => ast.syntax.constructor.style,
                "font_weight" => ast.syntax.constructor.weight
              },
              "embedded" => %{
                "color" => ast.syntax.embedded.fg,
                "font_style" => ast.syntax.embedded.style,
                "font_weight" => ast.syntax.embedded.weight
              },
              "emphasis" => %{
                "color" => ast.syntax.emphasis.fg,
                "font_style" => ast.syntax.emphasis.style,
                "font_weight" => ast.syntax.emphasis.weight
              },
              "emphasis.strong" => %{
                "color" => ast.syntax.emphasis_strong.fg,
                "font_style" => ast.syntax.emphasis_strong.style,
                "font_weight" => ast.syntax.emphasis_strong.weight
              },
              "enum" => %{
                "color" => ast.syntax.enum.fg,
                "font_style" => ast.syntax.enum.style,
                "font_weight" => ast.syntax.enum.weight
              },
              "function" => %{
                "color" => ast.syntax.function.fg,
                "font_style" => ast.syntax.function.style,
                "font_weight" => ast.syntax.function.weight
              },
              "function.method" => %{
                "color" => ast.syntax.method.fg,
                "font_style" => ast.syntax.method.style,
                "font_weight" => ast.syntax.method.weight
              },
              "function.special.definition" => %{
                "color" => ast.syntax.function_def.fg,
                "font_style" => ast.syntax.function_def.style,
                "font_weight" => ast.syntax.function_def.weight
              },
              "hint" => %{
                "color" => ast.syntax.hint.fg,
                "font_style" => ast.syntax.hint.style,
                "font_weight" => ast.syntax.hint.weight
              },
              "keyword" => %{
                "color" => ast.syntax.keyword.fg,
                "font_style" => ast.syntax.keyword.style,
                "font_weight" => ast.syntax.keyword.weight
              },
              "label" => %{
                "color" => ast.syntax.label.fg,
                "font_style" => ast.syntax.label.style,
                "font_weight" => ast.syntax.label.weight
              },
              "link_text" => %{
                "color" => ast.syntax.link_text.fg,
                "font_style" => ast.syntax.link_text.style,
                "font_weight" => ast.syntax.link_text.weight
              },
              "link_uri" => %{
                "color" => ast.syntax.link_uri.fg,
                "font_style" => ast.syntax.link_uri.style,
                "font_weight" => ast.syntax.link_uri.weight
              },
              "number" => %{
                "color" => ast.syntax.number.fg,
                "font_style" => ast.syntax.number.style,
                "font_weight" => ast.syntax.number.weight
              },
              "operator" => %{
                "color" => ast.syntax.operator.fg,
                "font_style" => ast.syntax.operator.style,
                "font_weight" => ast.syntax.operator.weight
              },
              "predictive" => %{
                "color" => ast.syntax.predictive.fg,
                "font_style" => ast.syntax.predictive.style,
                "font_weight" => ast.syntax.predictive.weight
              },
              "preproc" => %{
                "color" => ast.syntax.preproc.fg,
                "font_style" => ast.syntax.preproc.style,
                "font_weight" => ast.syntax.preproc.weight
              },
              "primary" => %{
                "color" => ast.syntax.primary.fg,
                "font_style" => ast.syntax.primary.style,
                "font_weight" => ast.syntax.primary.weight
              },
              "property" => %{
                "color" => ast.syntax.property.fg,
                "font_style" => ast.syntax.property.style,
                "font_weight" => ast.syntax.property.weight
              },
              "punctuation" => %{
                "color" => ast.syntax.punct.fg,
                "font_style" => ast.syntax.punct.style,
                "font_weight" => ast.syntax.punct.weight
              },
              "punctuation.bracket" => %{
                "color" => ast.syntax.punct_bracket.fg,
                "font_style" => ast.syntax.punct_bracket.style,
                "font_weight" => ast.syntax.punct_bracket.weight
              },
              "punctuation.delimiter" => %{
                "color" => ast.syntax.punct_delimiter.fg,
                "font_style" => ast.syntax.punct_delimiter.style,
                "font_weight" => ast.syntax.punct_delimiter.weight
              },
              "punctuation.list_marker" => %{
                "color" => ast.syntax.punct_list_marker.fg,
                "font_style" => ast.syntax.punct_list_marker.style,
                "font_weight" => ast.syntax.punct_list_marker.weight
              },
              "punctuation.special" => %{
                "color" => ast.syntax.punct_special.fg,
                "font_style" => ast.syntax.punct_special.style,
                "font_weight" => ast.syntax.punct_special.weight
              },
              "string" => %{
                "color" => ast.syntax.string.fg,
                "font_style" => ast.syntax.string.style,
                "font_weight" => ast.syntax.string.weight
              },
              "string.escape" => %{
                "color" => ast.syntax.string_escape.fg,
                "font_style" => ast.syntax.string_escape.style,
                "font_weight" => ast.syntax.string_escape.weight
              },
              "string.regex" => %{
                "color" => ast.syntax.string_regex.fg,
                "font_style" => ast.syntax.string_regex.style,
                "font_weight" => ast.syntax.string_regex.weight
              },
              "string.special" => %{
                "color" => ast.syntax.string_special.fg,
                "font_style" => ast.syntax.string_special.style,
                "font_weight" => ast.syntax.string_special.weight
              },
              "string.special.symbol" => %{
                "color" => ast.syntax.string_symbol.fg,
                "font_style" => ast.syntax.string_symbol.style,
                "font_weight" => ast.syntax.string_symbol.weight
              },
              "tag" => %{
                "color" => ast.syntax.tag.fg,
                "font_style" => ast.syntax.tag.style,
                "font_weight" => ast.syntax.tag.weight
              },
              "text.literal" => %{
                "color" => ast.syntax.text_literal.fg,
                "font_style" => ast.syntax.text_literal.style,
                "font_weight" => ast.syntax.text_literal.weight
              },
              "title" => %{
                "color" => ast.syntax.title.fg,
                "font_style" => ast.syntax.title.style,
                "font_weight" => ast.syntax.title.weight
              },
              "type" => %{
                "color" => ast.syntax.title.fg,
                "font_style" => ast.syntax.title.style,
                "font_weight" => ast.syntax.title.weight
              },
              "variable" => %{
                "color" => ast.syntax.variable.fg,
                "font_style" => ast.syntax.variable.style,
                "font_weight" => ast.syntax.variable.weight
              },
              "variable.special" => %{
                "color" => ast.syntax.variable_special.fg,
                "font_style" => ast.syntax.variable_special.style,
                "font_weight" => ast.syntax.variable_special.weight
              },
              "variant" => %{
                "color" => ast.syntax.variant.fg,
                "font_style" => ast.syntax.variant.style,
                "font_weight" => ast.syntax.variant.weight
              }
            }
          }
        }
      ]
    }
  end
end
