defmodule TwinkleStar do
  @spec from_path(Path.t()) :: {:ok, map} | {:error, term}
  def from_path(path) when is_binary(path) do
    # TODO: figure out if we need to read the entire file
    with {:ok, bytes} <- File.read(path) do
      from_bytes(bytes)
    end
  end

  @spec from_bytes(binary) :: {:ok, map} | {:error, term}
  def from_bytes(bytes), do: {:error, :unknown_format}
end
