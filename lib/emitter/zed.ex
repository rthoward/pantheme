defmodule Pantheme.Emitter.Zed do
  @behaviour Pantheme.Emitter

  alias Pantheme.IR

  @spec emit(IR.t(), keyword()) :: map()
  def emit(ir, opts) do
    %{
      "$schema" => "https://zed.dev/schema/themes/v0.1.0.json",
      "name" => opts[:name],
      "author" => opts[:author],
      "themes" => [
        %{
          "name" => opts[:name],
          "appearance" => opts[:appearance],
          "style" => %{
            "border" => ir.ui.border.color,
            "border.variant" => ir.ui.border.variant,
            "border.focused" => ir.ui.border.focused,
            "border.selected" => ir.ui.border.selected,
            "border.transparent" => ir.ui.border.transparent,
            "border.disabled" => ir.ui.border.disabled,
            "elevated_surface.background" => ir.ui.bg,
            "surface.background" => ir.ui.bg,
            "background" => ir.ui.bg,
            "element.background" => ir.ui.element.color,
            "element.hover" => ir.ui.element.hover,
            "element.active" => ir.ui.element.active,
            "element.selected" => ir.ui.element.selected,
            "element.disabled" => ir.ui.element.disabled,
            "drop_target.background" => "#89859180",
            "ghost_element.background" => ir.ui.ghost_element.color,
            "ghost_element.hover" => ir.ui.ghost_element.hover,
            "ghost_element.active" => ir.ui.ghost_element.active,
            "ghost_element.selected" => ir.ui.ghost_element.selected,
            "ghost_element.disabled" => ir.ui.ghost_element.disabled,
            "text" => ir.ui.text.fg,
            "text.accent" => ir.ui.text.fg_accent,
            "text.disabled" => ir.ui.text.fg_disabled,
            "text.muted" => ir.ui.text.fg_muted,
            "text.placeholder" => ir.ui.text.fg_placeholder,
            "icon" => ir.ui.icon.fg,
            "icon.accent" => ir.ui.icon.fg_accent,
            "icon.disabled" => ir.ui.icon.fg_disabled,
            "icon.muted" => ir.ui.icon.fg_muted,
            "icon.placeholder" => ir.ui.icon.fg_placeholder,
            "status_bar.background" => ir.ui.status_bar_bg,
            "title_bar.background" => ir.ui.title_bar_bg,
            "title_bar.inactive_background" => ir.ui.title_bar_inactive_bg,
            "toolbar.background" => ir.ui.toolbar_bg,
            "tab_bar.background" => ir.ui.tab_bar_bg,
            "tab.inactive_background" => ir.ui.tab_inactive_bg,
            "tab.active_background" => ir.ui.tab_active_bg,
            "search.match_background" => ir.ui.search_match_bg,
            "panel.background" => ir.ui.panel_bg,
            "panel.focused_border" => ir.ui.panel_focused_bg,
            "pane.focused_border" => ir.ui.border.focused,
            "scrollbar.thumb.background" => ir.ui.scrollbar_thumb_bg,
            "scrollbar.thumb.hover_background" => ir.ui.scrollbar_thumb_hover_bg,
            "scrollbar.thumb.border" => ir.ui.scrollbar_thumb_border,
            "scrollbar.track.background" => ir.ui.scrollbar_track_bg,
            "scrollbar.track.border" => ir.ui.scrollbar_track_border,
            "editor.foreground" => ir.editor.fg,
            "editor.background" => ir.editor.bg,
            "editor.gutter.background" => ir.editor.bg,
            "editor.subheader.background" => ir.editor.subheader_bg,
            "editor.active_line.background" => ir.editor.active_line_bg,
            "editor.highlighted_line.background" => ir.editor.highlighted_line_bg,
            "editor.line_number" => ir.editor.line_number,
            "editor.active_line_number" => ir.editor.line_number_active,
            "editor.invisible" => "#726c7aff",
            "editor.wrap_guide" => "#efecf40d",
            "editor.active_wrap_guide" => "#efecf41a",
            "editor.document_highlight.read_background" => "#566dda1a",
            "editor.document_highlight.write_background" => "#726c7a66",

            # Terminal colors
            "terminal.background" => ir.term.bg,
            "terminal.foreground" => ir.term.fg.normal,
            "terminal.bright_foreground" => ir.term.fg.bright,
            "terminal.dim_foreground" => ir.term.fg.dim,
            "terminal.ansi.black" => ir.term.black.normal,
            "terminal.ansi.bright_black" => ir.term.black.bright,
            "terminal.ansi.dim_black" => ir.term.black.dim,
            "terminal.ansi.red" => ir.term.red.normal,
            "terminal.ansi.bright_red" => ir.term.red.bright,
            "terminal.ansi.dim_red" => ir.term.red.dim,
            "terminal.ansi.green" => ir.term.green.normal,
            "terminal.ansi.bright_green" => ir.term.green.bright,
            "terminal.ansi.dim_green" => ir.term.green.dim,
            "terminal.ansi.yellow" => ir.term.yellow.normal,
            "terminal.ansi.bright_yellow" => ir.term.yellow.bright,
            "terminal.ansi.dim_yellow" => ir.term.yellow.dim,
            "terminal.ansi.blue" => ir.term.blue.normal,
            "terminal.ansi.bright_blue" => ir.term.blue.bright,
            "terminal.ansi.dim_blue" => ir.term.blue.dim,
            "terminal.ansi.magenta" => ir.term.magenta.normal,
            "terminal.ansi.bright_magenta" => ir.term.magenta.bright,
            "terminal.ansi.dim_magenta" => ir.term.magenta.dim,
            "terminal.ansi.cyan" => ir.term.cyan.normal,
            "terminal.ansi.bright_cyan" => ir.term.cyan.bright,
            "terminal.ansi.dim_cyan" => ir.term.cyan.dim,
            "terminal.ansi.white" => ir.term.white.normal,
            "terminal.ansi.bright_white" => ir.term.white.bright,
            "terminal.ansi.dim_white" => ir.term.white.dim,
            "link_text.hover" => "#566ddaff",

            # Containers
            "conflict" => ir.ui.conflict.fg,
            "conflict.background" => ir.ui.conflict.bg,
            "conflict.border" => ir.ui.conflict.border,
            "created" => ir.ui.created.fg,
            "created.background" => ir.ui.created.bg,
            "created.border" => ir.ui.created.border,
            "deleted" => ir.ui.deleted.fg,
            "deleted.background" => ir.ui.deleted.bg,
            "deleted.border" => ir.ui.deleted.border,
            "error" => ir.ui.error.fg,
            "error.background" => ir.ui.error.bg,
            "error.border" => ir.ui.error.border,
            "hidden" => ir.ui.hidden.fg,
            "hidden.background" => ir.ui.hidden.bg,
            "hidden.border" => ir.ui.hidden.border,
            "hint" => ir.ui.hint.fg,
            "hint.background" => ir.ui.hint.bg,
            "hint.border" => ir.ui.hint.border,
            "ignored" => ir.ui.ignored.fg,
            "ignored.background" => ir.ui.ignored.bg,
            "ignored.border" => ir.ui.ignored.border,
            "info" => ir.ui.info.fg,
            "info.background" => ir.ui.info.bg,
            "info.border" => ir.ui.info.border,
            "modified" => ir.ui.modified.fg,
            "modified.background" => ir.ui.modified.bg,
            "modified.border" => ir.ui.modified.border,
            "predictive" => ir.ui.predictive.fg,
            "predictive.background" => ir.ui.predictive.bg,
            "predictive.border" => ir.ui.predictive.border,
            "renamed" => ir.ui.renamed.fg,
            "renamed.background" => ir.ui.renamed.bg,
            "renamed.border" => ir.ui.renamed.border,
            "success" => ir.ui.success.fg,
            "success.background" => ir.ui.success.bg,
            "success.border" => ir.ui.success.border,
            "unreachable" => ir.ui.unreachable.fg,
            "unreachable.background" => ir.ui.unreachable.bg,
            "unreachable.border" => ir.ui.unreachable.border,
            "warning" => ir.ui.warning.fg,
            "warning.background" => ir.ui.warning.bg,
            "warning.border" => ir.ui.warning.border,

            # Players
            "players" => [
              %{
                # TODO
                "cursor" => ir.term.blue.normal,
                "background" => ir.editor.bg,
                "selection" => ir.editor.selection_bg
              },
              %{
                "cursor" => ir.term.green.normal,
                "background" => ir.term.green.normal,
                "selection" => ir.term.green.bright
              },
              %{
                "cursor" => ir.term.yellow.normal,
                "background" => ir.term.yellow.normal,
                "selection" => ir.term.yellow.bright
              },
              %{
                "cursor" => ir.term.red.normal,
                "background" => ir.term.red.normal,
                "selection" => ir.term.red.bright
              },
              %{
                "cursor" => ir.term.magenta.normal,
                "background" => ir.term.magenta.normal,
                "selection" => ir.term.magenta.bright
              },
              %{
                "cursor" => ir.term.cyan.normal,
                "background" => ir.term.cyan.normal,
                "selection" => ir.term.cyan.bright
              }
            ],
            "syntax" => %{
              "attribute" => %{
                "color" => ir.syntax.attribute.fg,
                "font_style" => ir.syntax.attribute.style,
                "font_weight" => ir.syntax.attribute.weight
              },
              "boolean" => %{
                "color" => ir.syntax.boolean.fg,
                "font_style" => ir.syntax.boolean.style,
                "font_weight" => ir.syntax.boolean.weight
              },
              "comment" => %{
                "color" => ir.syntax.comment.fg,
                "font_style" => ir.syntax.comment.style,
                "font_weight" => ir.syntax.comment.weight
              },
              "comment.doc" => %{
                "color" => ir.syntax.docstring.fg,
                "font_style" => ir.syntax.docstring.style,
                "font_weight" => ir.syntax.docstring.weight
              },
              "constant" => %{
                "color" => ir.syntax.constant.fg,
                "font_style" => ir.syntax.constant.style,
                "font_weight" => ir.syntax.constant.weight
              },
              "constructor" => %{
                "color" => ir.syntax.constructor.fg,
                "font_style" => ir.syntax.constructor.style,
                "font_weight" => ir.syntax.constructor.weight
              },
              "embedded" => %{
                "color" => ir.syntax.embedded.fg,
                "font_style" => ir.syntax.embedded.style,
                "font_weight" => ir.syntax.embedded.weight
              },
              "emphasis" => %{
                "color" => ir.syntax.emphasis.fg,
                "font_style" => ir.syntax.emphasis.style,
                "font_weight" => ir.syntax.emphasis.weight
              },
              "emphasis.strong" => %{
                "color" => ir.syntax.emphasis_strong.fg,
                "font_style" => ir.syntax.emphasis_strong.style,
                "font_weight" => ir.syntax.emphasis_strong.weight
              },
              "enum" => %{
                "color" => ir.syntax.enum.fg,
                "font_style" => ir.syntax.enum.style,
                "font_weight" => ir.syntax.enum.weight
              },
              "function" => %{
                "color" => ir.syntax.function.fg,
                "font_style" => ir.syntax.function.style,
                "font_weight" => ir.syntax.function.weight
              },
              "function.method" => %{
                "color" => ir.syntax.method.fg,
                "font_style" => ir.syntax.method.style,
                "font_weight" => ir.syntax.method.weight
              },
              "function.special.definition" => %{
                "color" => ir.syntax.function_def.fg,
                "font_style" => ir.syntax.function_def.style,
                "font_weight" => ir.syntax.function_def.weight
              },
              "hint" => %{
                "color" => ir.syntax.hint.fg,
                "font_style" => ir.syntax.hint.style,
                "font_weight" => ir.syntax.hint.weight
              },
              "keyword" => %{
                "color" => ir.syntax.keyword.fg,
                "font_style" => ir.syntax.keyword.style,
                "font_weight" => ir.syntax.keyword.weight
              },
              "label" => %{
                "color" => ir.syntax.label.fg,
                "font_style" => ir.syntax.label.style,
                "font_weight" => ir.syntax.label.weight
              },
              "link_text" => %{
                "color" => ir.syntax.link_text.fg,
                "font_style" => ir.syntax.link_text.style,
                "font_weight" => ir.syntax.link_text.weight
              },
              "link_uri" => %{
                "color" => ir.syntax.link_uri.fg,
                "font_style" => ir.syntax.link_uri.style,
                "font_weight" => ir.syntax.link_uri.weight
              },
              "number" => %{
                "color" => ir.syntax.number.fg,
                "font_style" => ir.syntax.number.style,
                "font_weight" => ir.syntax.number.weight
              },
              "operator" => %{
                "color" => ir.syntax.operator.fg,
                "font_style" => ir.syntax.operator.style,
                "font_weight" => ir.syntax.operator.weight
              },
              "predictive" => %{
                "color" => ir.syntax.predictive.fg,
                "font_style" => ir.syntax.predictive.style,
                "font_weight" => ir.syntax.predictive.weight
              },
              "preproc" => %{
                "color" => ir.syntax.preproc.fg,
                "font_style" => ir.syntax.preproc.style,
                "font_weight" => ir.syntax.preproc.weight
              },
              "primary" => %{
                "color" => ir.syntax.primary.fg,
                "font_style" => ir.syntax.primary.style,
                "font_weight" => ir.syntax.primary.weight
              },
              "property" => %{
                "color" => ir.syntax.property.fg,
                "font_style" => ir.syntax.property.style,
                "font_weight" => ir.syntax.property.weight
              },
              "punctuation" => %{
                "color" => ir.syntax.punct.fg,
                "font_style" => ir.syntax.punct.style,
                "font_weight" => ir.syntax.punct.weight
              },
              "punctuation.bracket" => %{
                "color" => ir.syntax.punct_bracket.fg,
                "font_style" => ir.syntax.punct_bracket.style,
                "font_weight" => ir.syntax.punct_bracket.weight
              },
              "punctuation.delimiter" => %{
                "color" => ir.syntax.punct_delimiter.fg,
                "font_style" => ir.syntax.punct_delimiter.style,
                "font_weight" => ir.syntax.punct_delimiter.weight
              },
              "punctuation.list_marker" => %{
                "color" => ir.syntax.punct_list_marker.fg,
                "font_style" => ir.syntax.punct_list_marker.style,
                "font_weight" => ir.syntax.punct_list_marker.weight
              },
              "punctuation.special" => %{
                "color" => ir.syntax.punct_special.fg,
                "font_style" => ir.syntax.punct_special.style,
                "font_weight" => ir.syntax.punct_special.weight
              },
              "string" => %{
                "color" => ir.syntax.string.fg,
                "font_style" => ir.syntax.string.style,
                "font_weight" => ir.syntax.string.weight
              },
              "string.escape" => %{
                "color" => ir.syntax.string_escape.fg,
                "font_style" => ir.syntax.string_escape.style,
                "font_weight" => ir.syntax.string_escape.weight
              },
              "string.regex" => %{
                "color" => ir.syntax.string_regex.fg,
                "font_style" => ir.syntax.string_regex.style,
                "font_weight" => ir.syntax.string_regex.weight
              },
              "string.special" => %{
                "color" => ir.syntax.string_special.fg,
                "font_style" => ir.syntax.string_special.style,
                "font_weight" => ir.syntax.string_special.weight
              },
              "string.special.symbol" => %{
                "color" => ir.syntax.string_symbol.fg,
                "font_style" => ir.syntax.string_symbol.style,
                "font_weight" => ir.syntax.string_symbol.weight
              },
              "tag" => %{
                "color" => ir.syntax.tag.fg,
                "font_style" => ir.syntax.tag.style,
                "font_weight" => ir.syntax.tag.weight
              },
              "text.literal" => %{
                "color" => ir.syntax.text_literal.fg,
                "font_style" => ir.syntax.text_literal.style,
                "font_weight" => ir.syntax.text_literal.weight
              },
              "title" => %{
                "color" => ir.syntax.title.fg,
                "font_style" => ir.syntax.title.style,
                "font_weight" => ir.syntax.title.weight
              },
              "type" => %{
                "color" => ir.syntax.title.fg,
                "font_style" => ir.syntax.title.style,
                "font_weight" => ir.syntax.title.weight
              },
              "variable" => %{
                "color" => ir.syntax.variable.fg,
                "font_style" => ir.syntax.variable.style,
                "font_weight" => ir.syntax.variable.weight
              },
              "variable.special" => %{
                "color" => ir.syntax.variable_special.fg,
                "font_style" => ir.syntax.variable_special.style,
                "font_weight" => ir.syntax.variable_special.weight
              },
              "variant" => %{
                "color" => ir.syntax.variant.fg,
                "font_style" => ir.syntax.variant.style,
                "font_weight" => ir.syntax.variant.weight
              }
            }
          }
        }
      ]
    }
  end

  def dump(emitted) do
    with {:ok, encoded} <- Jason.encode(emitted) do
      {:ok, Jason.Formatter.pretty_print(encoded)}
    end
  end
end
