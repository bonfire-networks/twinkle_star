defmodule TwinkleStar.Plugin.FileInfo do
  use TwinkleStar.MediaTypePlugin
  require Logger

  def from_filepath(path) when is_binary(path) do
    %{^path => info} = FileInfo.get_info(path)
    {:ok, parse_file_info(info)}
  rescue
    e in MimetypeParser.Exception ->
      Logger.error(e)
      {:error, "Cold not check mime type"}
  end

  def from_bytes(bytes) do
    # file_info doesn't support reading directly from bytes, so we write a temp file
    tmp_file =
      Path.join([
        System.tmp_dir!(),
        "twinke_star_bytes-#{System.monotonic_time()}"
      ])

    File.write!(tmp_file, bytes, [:binary, :write])
    %{^tmp_file => info} = FileInfo.get_info(tmp_file)
    File.rm(tmp_file)
    parse_file_info(info)
  end

  defp parse_file_info(%FileInfo.Mime{} = mime),
    do: "#{mime.type}/#{mime.subtype}"
end
