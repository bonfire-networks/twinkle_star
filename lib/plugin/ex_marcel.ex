defmodule TwinkleStar.Plugin.ExMarcel do
  use TwinkleStar.MediaTypePlugin

  def from_filepath(path) when is_binary(path),
    do: {:ok, ExMarcel.MimeType.for {:path, path}}

  def from_bytes(bytes), do: ExMarcel.MimeType.for {:string, bytes}
end
