defmodule Pantheme.AST do
  defmodule Container do
    @type t :: %__MODULE__{
            fg: String.t(),
            bg: String.t(),
            border: String.t()
          }

    defstruct [:fg, :bg, :border]
  end

  defmodule Text do
    @type t :: %__MODULE__{
            fg: String.t(),
            fg_accent: String.t(),
            fg_disabled: String.t(),
            fg_muted: String.t(),
            fg_placeholder: String.t(),
            bg: String.t(),
            style: atom() | nil,
            weight: integer() | nil
          }

    defstruct [:fg, :fg_accent, :fg_disabled, :fg_muted, :fg_placeholder, :bg, :style, :weight]
  end

  defmodule Element do
    @type t :: %__MODULE__{
            color: String.t(),
            active: String.t(),
            disabled: String.t(),
            focused: String.t(),
            hover: String.t(),
            selected: String.t(),
            transparent: String.t(),
            variant: String.t()
          }

    defstruct [
      :color,
      :active,
      :disabled,
      :focused,
      :hover,
      :selected,
      :transparent,
      :variant
    ]
  end

  defmodule UI do
    @type t :: %__MODULE__{
            bg: String.t(),
            border: Element.t(),
            conflict: Container.t(),
            created: Container.t(),
            deleted: Container.t(),
            drop_target_bg: String.t(),
            element: Element.t(),
            error: Container.t(),
            fg: String.t(),
            ghost_element: Element.t(),
            hidden: Container.t(),
            hint: Container.t(),
            icon: map(),
            ignored: Container.t(),
            info: Container.t(),
            link_text_hover: String.t(),
            modified: Container.t(),
            predictive: Container.t(),
            renamed: Container.t(),
            status_bar_bg: String.t(),
            success: Container.t(),
            tab_bar_bg: String.t(),
            tab_active_bg: String.t(),
            tab_inactive_bg: String.t(),
            text: Text.t(),
            title_bar_bg: String.t(),
            title_bar_inactive_bg: String.t(),
            search_match_bg: String.t(),
            scrollbar_thumb_bg: String.t(),
            scrollbar_thumb_hover_bg: String.t(),
            scrollbar_thumb_border: String.t(),
            scrollbar_track_bg: String.t(),
            scrollbar_track_border: String.t(),
            toolbar_bg: String.t(),
            unreachable: Container.t(),
            warning: Container.t(),
            panel_bg: String.t(),
            panel_focused_bg: String.t()
          }

    defstruct [
      :bg,
      :border,
      :conflict,
      :created,
      :deleted,
      :drop_target_bg,
      :element,
      :error,
      :fg,
      :ghost_element,
      :hidden,
      :hint,
      :icon,
      :ignored,
      :info,
      :link_text_hover,
      :modified,
      :predictive,
      :renamed,
      :status_bar_bg,
      :success,
      :tab_bar_bg,
      :tab_active_bg,
      :tab_inactive_bg,
      :text,
      :title_bar_bg,
      :title_bar_inactive_bg,
      :toolbar_bg,
      :search_match_bg,
      :scrollbar_thumb_bg,
      :scrollbar_thumb_hover_bg,
      :scrollbar_thumb_border,
      :scrollbar_track_bg,
      :scrollbar_track_border,
      :unreachable,
      :warning,
      :panel_bg,
      :panel_focused_bg
    ]
  end

  defmodule Syntax do
    @type t :: %__MODULE__{
            attribute: Text.t(),
            boolean: Text.t(),
            comment: Text.t(),
            constant: Text.t(),
            constructor: Text.t(),
            docstring: Text.t(),
            embedded: Text.t(),
            emphasis: Text.t(),
            emphasis_strong: Text.t(),
            enum: Text.t(),
            function: Text.t(),
            function_def: Text.t(),
            hint: Text.t(),
            keyword: Text.t(),
            label: Text.t(),
            link_text: Text.t(),
            link_uri: Text.t(),
            method: Text.t(),
            number: Text.t(),
            operator: Text.t(),
            predictive: Text.t(),
            preproc: Text.t(),
            primary: Text.t(),
            property: Text.t(),
            punct: Text.t(),
            punct_bracket: Text.t(),
            punct_delimiter: Text.t(),
            punct_list_marker: Text.t(),
            punct_special: Text.t(),
            string: Text.t(),
            string_escape: Text.t(),
            string_regex: Text.t(),
            string_special: Text.t(),
            string_symbol: Text.t(),
            tag: Text.t(),
            text_literal: Text.t(),
            title: Text.t(),
            type: Text.t(),
            variable: Text.t(),
            variable_special: Text.t(),
            string_special: Text.t(),
            variant: Text.t()
          }

    defstruct [
      :attribute,
      :boolean,
      :comment,
      :constant,
      :constructor,
      :docstring,
      :embedded,
      :emphasis,
      :emphasis_strong,
      :enum,
      :function,
      :function_def,
      :hint,
      :keyword,
      :label,
      :link_text,
      :link_uri,
      :method,
      :number,
      :operator,
      :predictive,
      :preproc,
      :primary,
      :property,
      :punct,
      :punct_bracket,
      :punct_delimiter,
      :punct_list_marker,
      :punct_special,
      :string,
      :string_escape,
      :string_regex,
      :string_special,
      :string_symbol,
      :tag,
      :text_literal,
      :title,
      :type,
      :variable,
      :variable_special,
      :variant
    ]
  end

  defmodule TermColor do
    @type t :: %__MODULE__{
            normal: String.t(),
            bright: String.t(),
            dim: String.t()
          }

    defstruct [:normal, :bright, :dim]
  end

  defmodule TermColors do
    @type t :: %__MODULE__{
            bg: String.t(),
            fg: TermColor.t(),
            black: TermColor.t(),
            red: TermColor.t(),
            green: TermColor.t(),
            yellow: TermColor.t(),
            blue: TermColor.t(),
            magenta: TermColor.t(),
            cyan: TermColor.t(),
            white: TermColor.t()
          }

    defstruct [
      :bg,
      :fg,
      :black,
      :red,
      :green,
      :yellow,
      :blue,
      :magenta,
      :cyan,
      :white
    ]
  end

  defmodule Editor do
    @type t :: %__MODULE__{
            bg: String.t(),
            fg: String.t(),
            line_number: String.t(),
            line_number_active: String.t(),
            active_line_bg: String.t(),
            selection_bg: String.t(),
            selection_fg: String.t(),
            highlighted_line_bg: String.t(),
            subheader_bg: String.t()
          }

    defstruct [
      :fg,
      :bg,
      :line_number,
      :line_number_active,
      :active_line_bg,
      :selection_bg,
      :selection_fg,
      :highlighted_line_bg,
      :subheader_bg
    ]
  end

  @type t :: %__MODULE__{
          editor: Editor.t(),
          syntax: Syntax.t(),
          term: TermColors.t(),
          ui: UI.t()
        }

  defstruct [:editor, :syntax, :term, :ui]
end
