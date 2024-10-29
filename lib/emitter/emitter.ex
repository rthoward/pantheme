defmodule Pantheme.Emitter do
  alias Pantheme.IR

  @callback emit(ir :: IR.t(), opts :: keyword()) :: map()
  @callback dump(emitted :: map()) :: String.t()
end
