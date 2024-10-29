defmodule Pantheme.Parser do
  alias Pantheme.IR

  @callback load(opts :: keyword()) :: {:ok, String.t()} | {:error, String.t()}
  @callback parse(loaded :: String.t()) :: {:ok, keyword()} | {:error, any()}
  @callback normalize(parsed :: keyword()) :: {:ok, map()} | {:error, any()}
  @callback to_ir(normalized :: map()) :: IR.t()
end
