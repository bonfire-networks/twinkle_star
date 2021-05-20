defmodule TwinkleStar do
  @doc """
  Attempt to read metadata from a file on the local filesystem.

  iex> TwinkleStar.from_filepath("test/fixtures/150.png")
  {:ok, %{media_type: "image/png"}}
  """
  @spec from_filepath(Path.t()) :: {:ok, map} | {:error, term}
  def from_filepath(path) when is_binary(path) do
    with {:ok, media_type} <- do_from_filepath(path) do
      {:ok, %{media_type: media_type}}
    end
  end

  # TODO: move to behaviours and config
  if Code.ensure_loaded?(TreeMagic) do
    defp do_from_filepath(path), do: TreeMagic.from_filepath(path)
  else
    defp do_from_filepath(path) do
      %{^path => info} = FileInfo.get_info(path)
      {:ok, parse_file_info(info)}
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
    {:ok, %{media_type: do_from_bytes(bytes)}}
  end

  if Code.ensure_loaded?(TreeMagic) do
    defp do_from_bytes(bytes), do: TreeMagic.from_u8(bytes)
  else
    defp do_from_bytes(bytes) do
      # file_info doesn't support reading directly from bytes, so we write a temp file
      tmp_file = Path.join([
        System.tmp_dir!(), "twinke_star_bytes-#{System.monotonic_time()}"
      ])

      File.write!(tmp_file, bytes, [:binary, :write])
      %{^tmp_file => info} = FileInfo.get_info(tmp_file)
      File.rm(tmp_file)
      parse_file_info(info)
    end
  end

  defp parse_file_info(%FileInfo.Mime{} = mime), do: "#{mime.type}/#{mime.subtype}"

  if Code.ensure_loaded?(:hackney) do
    @request_body_size 2048
    @request_headers []
    @request_body ""

    @doc """
    Attempt to fetch metadata from a URI, remote or local.

    iex> TwinkleStar.from_uri("https://upload.wikimedia.org/wikipedia/commons/a/a9/US_Airways_A319-132_LAS_N838AW.jpg")
    {:ok, %{media_type: "image/jpeg"}}
    iex> TwinkleStar.from_uri("http://xkcd.com", follow_redirect: true)
    {:ok, %{media_type: "text/html"}}
    """
    @spec from_uri(URI.t() | binary, request_opts :: Keyword.t()) :: {:ok, map} | {:error, term}
    def from_uri(uri, request_opts \\ [])

    def from_uri(uri, opts) when is_binary(uri) do
      uri
      |> URI.parse()
      |> from_uri(opts)
    end

    def from_uri(%URI{} = uri, opts) do
      with :ok <- validate_uri(uri),
           {:ok, status, _headers, client} <- fetch_remote(uri, opts),
           :ok <- response_status_ok(status),
           {:ok, data} <- :hackney.body(client, @request_body_size) do
        from_bytes(data)
      end
    end

    defp fetch_remote(uri, opts),
      do: :hackney.get(URI.to_string(uri), @request_headers, @request_body, opts)

    defp response_status_ok(status) when is_integer(status) do
      # FIXME: include error information or maybe just return the client
      if status in 200..399,
        do: :ok,
        else: {:error, {:request_failed, status}}
    end

    defp validate_uri(%URI{scheme: scheme, host: host}) do
      if scheme in ["http", "https"] and not is_nil(host) do
        :ok
      else
        {:error, :invalid_uri_format}
      end
    end
  end
end
