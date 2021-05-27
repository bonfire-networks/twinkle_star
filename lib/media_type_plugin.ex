defmodule TwinkleStar.MediaTypePlugin do
  @callback from_filepath(path :: Path.t()) :: {:ok, binary} | {:error, term}
  @callback from_bytes(bytes :: binary) :: binary

  def __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end
end
