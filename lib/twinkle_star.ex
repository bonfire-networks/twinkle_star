defmodule TwinkleStar do
  @doc """
  Attempt to read metadata from a file on the local filesystem.

  iex> TwinkleStar.from_filepath("test/fixtures/150.png")
  {:ok, %{media_type: "image/png"}}
  """
  @spec from_filepath(Path.t()) :: {:ok, map} | {:error, term}
  def from_filepath(path) when is_binary(path) do
    with {:ok, media_type} <- TreeMagic.from_filepath(path) do
      {:ok, %{media_type: media_type}}
    end
  end

  @doc """
  Attempt to read metadata from raw bytes.

  iex> bytes = File.read!("test/fixtures/150.png")
  iex> TwinkleStar.from_bytes(bytes)
  {:ok, %{media_type: "image/png"}}
  """
  @spec from_bytes(binary) :: {:ok, map} | {:error, term}
  def from_bytes(bytes) do
    media_type = TreeMagic.from_u8(bytes)

    {:ok, %{media_type: media_type}}
  end

  if Code.ensure_loaded?(:hackney) do
    @request_body_size 2048

    @doc """
    Attempt to fetch metadata from a URI, remote or local.

    iex> TwinkleStar.from_uri("https://upload.wikimedia.org/wikipedia/commons/a/a9/US_Airways_A319-132_LAS_N838AW.jpg")
    {:ok, %{media_type: "image/jpeg"}}
    """
    @spec from_uri(URI.t() | binary) :: {:ok, map} | {:error, term}
    def from_uri(uri) when is_binary(uri) do
      uri
      |> URI.parse()
      |> from_uri()
    end

    def from_uri(%URI{} = uri) do
      with {:ok, status, _headers, client} <- :hackney.get(URI.to_string(uri)),
           :ok <- response_status_ok(status),
           {:ok, data} <- :hackney.body(client, @request_body_size) do
        from_bytes(data)
      end
    end

    defp response_status_ok(status) when is_integer(status) do
      # FIXME: include error information or maybe just return the client
      if status in 200..399,
        do: :ok,
        else: {:error, {:request_failed, status}}
    end
  end
end
