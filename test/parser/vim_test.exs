defmodule Pantheme.Parser.VimTest do
  use ExUnit.Case

  alias Pantheme.Parser

  describe "parse/1" do
    test "parses a vim color theme" do
      assert {:ok, parsed} =
               __DIR__
               |> Path.join("../support/files/nvim/loaded.txt")
               |> File.read!()
               |> Parser.Vim.parse()

      assert %{index: 0, color: "#1C1917"} = parsed[:term_color]

      assert %{
               name: "Normal",
               guifg: "#b4bdc3",
               guibg: "#1c1917"
             } =
               parsed
               |> Keyword.get_values(:highlight)
               |> Enum.find(&(&1.name == "Normal"))

      assert %{
               name: "Bold",
               gui: ["bold"],
               cterm: ["bold"]
             } =
               parsed
               |> Keyword.get_values(:highlight)
               |> Enum.find(&(&1.name == "Bold"))

      assert %{
               name: "Boolean",
               guifg: "#b4bdc3",
               gui: ["italic"],
               cterm: ["italic"]
             } =
               parsed
               |> Keyword.get_values(:highlight)
               |> Enum.find(&(&1.name == "Boolean"))
    end
  end

  describe "normalize/1" do
    setup do
      assert {:ok, parsed} =
               __DIR__
               |> Path.join("../support/files/nvim/loaded.txt")
               |> File.read!()
               |> Parser.Vim.parse()

      assert {:ok, normalized} = Parser.Vim.normalize(parsed)

      {:ok, %{normalized: normalized}}
    end

    test "normalizes highlights", %{normalized: normalized} do
      assert %{
               highlights: %{
                 "Normal" => %{
                   fg: "#b4bdc3",
                   bg: "#1c1917"
                 }
               }
             } = normalized
    end

    test "consolidates overlapping highlights", %{normalized: normalized} do
      assert %{
               highlights: %{
                 "Comment" => %{
                   fg: "#6e6763"
                 }
               }
             } = normalized
    end

    test "can handle multiple styles", %{normalized: normalized} do
      assert %{
               highlights: %{
                 "Todo" => %{
                   style: [:bold, :underline]
                 }
               }
             } = normalized
    end
  end
end
