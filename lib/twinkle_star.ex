defmodule TwinkleStar do
  @spec from_filepath(Path.t()) :: {:ok, map} | {:error, term}
  def from_filepath(path) when is_binary(path) do
    with {:ok, media_type} <- TreeMagic.from_filepath(path) do
      {:ok, %{media_type: media_type}}
    end
  end

  @spec from_bytes(binary) :: {:ok, map} | {:error, term}
  def from_bytes(bytes) do
    with {:ok, media_type} <- TreeMagic.from_u8(bytes) do
      {:ok, %{media_type: media_type}}
    end
  end
end
