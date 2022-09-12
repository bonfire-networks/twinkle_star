defmodule TwinkleStar.Plugin.TreeMagic do
  use TwinkleStar.MediaTypePlugin

  def from_filepath(path) when is_binary(path),
    do: TreeMagic.from_filepath(path)

  def from_bytes(bytes), do: TreeMagic.from_u8(bytes)
end
