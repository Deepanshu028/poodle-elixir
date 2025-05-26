defmodule Poodle.Config do
  @moduledoc """
  Configuration management for the Poodle SDK.

  Supports configuration via environment variables and application config.
  """

  @type t :: %__MODULE__{
          api_key: String.t(),
          base_url: String.t(),
          timeout: pos_integer(),
          debug: boolean(),
          finch_name: atom()
        }

  defstruct [
    :api_key,
    :base_url,
    :timeout,
    :debug,
    :finch_name
  ]

  @default_base_url "https://api.usepoodle.com"
  @default_timeout 30_000
  # 10MB
  @max_content_size 10 * 1024 * 1024

  @doc """
  Get the current configuration.

  Configuration is resolved in the following order:
  1. Explicitly passed options
  2. Application configuration
  3. Environment variables
  4. Default values

  ## Examples

      iex> Poodle.Config.get()
      {:ok, %Poodle.Config{...}}

      iex> Poodle.Config.get(api_key: "custom_key")
      {:ok, %Poodle.Config{api_key: "custom_key", ...}}

  """
  @spec get(keyword()) :: {:ok, t()} | {:error, String.t()}
  def get(opts \\ []) do
    config = %__MODULE__{
      api_key: resolve_api_key(opts),
      base_url: resolve_base_url(opts),
      timeout: resolve_timeout(opts),
      debug: resolve_debug(opts),
      finch_name: Keyword.get(opts, :finch_name, Poodle.Finch)
    }

    case validate(config) do
      :ok -> {:ok, config}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get the current configuration, raising on error.

  ## Examples

      iex> Poodle.Config.get!()
      %Poodle.Config{...}

  """
  @spec get!(keyword()) :: t()
  def get!(opts \\ []) do
    case get(opts) do
      {:ok, config} -> config
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Validate configuration.

  ## Examples

      iex> config = %Poodle.Config{api_key: "key", base_url: "https://api.example.com"}
      iex> Poodle.Config.validate(config)
      :ok

  """
  @spec validate(t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{} = config) do
    with :ok <- validate_api_key(config.api_key),
         :ok <- validate_base_url(config.base_url) do
      validate_timeout(config.timeout)
    end
  end

  @doc """
  Get the maximum content size allowed.
  """
  @spec max_content_size() :: pos_integer()
  def max_content_size, do: @max_content_size

  # Private functions

  defp resolve_api_key(opts) do
    if Keyword.has_key?(opts, :api_key) do
      Keyword.get(opts, :api_key)
    else
      Application.get_env(:poodle, :api_key) ||
        System.get_env("POODLE_API_KEY")
    end
  end

  defp resolve_base_url(opts) do
    Keyword.get(opts, :base_url) ||
      Application.get_env(:poodle, :base_url) ||
      System.get_env("POODLE_BASE_URL") ||
      @default_base_url
  end

  defp resolve_timeout(opts) do
    timeout =
      Keyword.get(opts, :timeout) ||
        Application.get_env(:poodle, :timeout) ||
        (System.get_env("POODLE_TIMEOUT") && String.to_integer(System.get_env("POODLE_TIMEOUT"))) ||
        @default_timeout

    if is_binary(timeout), do: String.to_integer(timeout), else: timeout
  end

  defp resolve_debug(opts) do
    Keyword.get(opts, :debug) ||
      Application.get_env(:poodle, :debug) ||
      System.get_env("POODLE_DEBUG") == "true" ||
      false
  end

  defp validate_api_key(nil),
    do:
      {:error,
       "API key is required. Set POODLE_API_KEY environment variable or pass :api_key option."}

  defp validate_api_key(""), do: {:error, "API key cannot be empty."}
  defp validate_api_key(api_key) when is_binary(api_key), do: :ok
  defp validate_api_key(_), do: {:error, "API key must be a string."}

  defp validate_base_url(nil), do: {:error, "Base URL is required."}
  defp validate_base_url(""), do: {:error, "Base URL cannot be empty."}

  defp validate_base_url(base_url) when is_binary(base_url) do
    uri = URI.parse(base_url)

    if uri.scheme in ["http", "https"] and uri.host do
      :ok
    else
      {:error, "Base URL must be a valid HTTP or HTTPS URL."}
    end
  end

  defp validate_base_url(_), do: {:error, "Base URL must be a string."}

  defp validate_timeout(timeout) when is_integer(timeout) and timeout > 0, do: :ok
  defp validate_timeout(_), do: {:error, "Timeout must be a positive integer."}
end
