defmodule ChromaBabel.Parser.VimTest do
  use ExUnit.Case

  alias ChromaBabel.Parser

  describe "parse/1" do
    test "parses a vim color theme" do
      assert {:ok, parsed, _, _, _, _} =
               __DIR__
               |> Path.join("../support/files/zenbones.vim")
               |> File.read!()
               |> Parser.Vim.parse()

      assert %{index: 0, color: "#1C1917"} = parsed[:term_color]

      assert [
               %{
                 name: "Normal",
                 guifg: "#B4BDC3",
                 guibg: "#1C1917",
                 guisp: "NONE",
                 gui: "NONE",
                 cterm: "NONE"
               },
               %{
                 name: "Bold",
                 guifg: "NONE",
                 guibg: "NONE",
                 guisp: "NONE",
                 gui: ["bold"],
                 cterm: ["bold"]
               },
               %{
                 name: "Boolean",
                 guifg: "#B4BDC3",
                 guibg: "NONE",
                 guisp: "NONE",
                 gui: ["italic"],
                 cterm: ["italic"]
               }
               | _
             ] = Keyword.get_values(parsed, :highlight)

      assert %{to: "ModeMsg", from: "Normal"} = parsed[:highlight_link]
    end
  end

  describe "normalize/1" do
    setup do
      assert {:ok, parsed, _, _, _, _} =
               __DIR__
               |> Path.join("../support/files/zenbones.vim")
               |> File.read!()
               |> Parser.Vim.parse()

      assert {:ok, normalized} = Parser.Vim.normalize(parsed)

      {:ok, %{normalized: normalized}}
    end

    test "normalizes highlights", %{normalized: normalized} do

      # assert %{
      #          highlights: %{
      #            "Normal" => %{
      #              foreground: "#B4BDC3",
      #              background: "#1C1917",
      #              special: [],
      #              style: []
      #            }
      #          }
      #        } = normalized
    end

    test "I dunno", %{normalized: normalized} do
      assert %{
               highlights: %{
                 "Comment" => %{
                   foreground: "#6E6763",
                   background: nil,
                   special: [],
                   style: [:italic]
                 }
               }
             } = normalized
    end
  end
end
