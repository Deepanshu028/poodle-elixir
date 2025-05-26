defmodule Poodle.HTTP.Client do
  @moduledoc """
  HTTP client for the Poodle SDK.

  Handles HTTP requests to the Poodle API with proper error handling,
  authentication, and rate limiting.
  """

  require Logger

  alias Poodle.{Config, Error, RateLimit, Response}

  @user_agent "poodle-elixir/1.0.0"

  @doc """
  Send a POST request to the Poodle API.

  ## Examples

      iex> config = %Poodle.Config{api_key: "key", base_url: "https://api.example.com"}
      iex> data = %{from: "from@example.com", to: "to@example.com", subject: "Test"}
      iex> Poodle.HTTP.Client.post(config, "/v1/send-email", data)
      {:ok, %Poodle.Response{...}}

  """
  @spec post(Config.t(), String.t(), map(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def post(%Config{} = config, path, data, opts \\ []) do
    url = build_url(config.base_url, path)
    headers = build_headers(config, opts)
    body = Jason.encode!(data)

    request_opts = [
      method: :post,
      url: url,
      headers: headers,
      body: body,
      receive_timeout: config.timeout
    ]

    if config.debug do
      Logger.debug("Poodle HTTP Request: #{inspect(request_opts)}")
    end

    case Finch.request(Finch.build(:post, url, headers, body), config.finch_name,
           receive_timeout: config.timeout
         ) do
      {:ok, %Finch.Response{status: status, headers: response_headers, body: response_body}} ->
        handle_response(status, response_headers, response_body, config.debug)

      {:error, %Mint.TransportError{reason: :timeout}} ->
        {:error,
         Error.timeout("Request timeout after #{config.timeout}ms", %{timeout: config.timeout})}

      {:error, %Mint.TransportError{reason: :econnrefused}} ->
        {:error, Error.network_error("Connection refused", %{url: url})}

      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        uri = URI.parse(url)
        {:error, Error.dns_error("DNS resolution failed for #{uri.host}", %{host: uri.host})}

      {:error, %Mint.HTTPError{reason: {:tls_alert, _}}} ->
        {:error, Error.ssl_error("SSL/TLS error occurred", %{url: url})}

      {:error, reason} ->
        {:error,
         Error.network_error("Network error: #{inspect(reason)}", %{reason: reason, url: url})}
    end
  end

  # Private functions

  defp build_url(base_url, path) do
    base_url
    |> String.trim_trailing("/")
    |> Kernel.<>("/" <> String.trim_leading(path, "/"))
  end

  defp build_headers(%Config{api_key: api_key}, _opts) do
    [
      {"authorization", "Bearer #{api_key}"},
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"user-agent", @user_agent}
    ]
  end

  defp handle_response(status, headers, body, debug) do
    headers_map = headers_to_map(headers)

    if debug do
      Logger.debug("Poodle HTTP Response: #{status} - #{body}")
    end

    case Jason.decode(body) do
      {:ok, response_body} ->
        case status do
          202 ->
            {:ok, Response.new(response_body, headers_map)}

          status when status in [400, 401, 402, 403, 422] ->
            {:error, Error.from_response(status, response_body)}

          429 ->
            rate_limit = RateLimit.from_headers(headers_map)

            error =
              Error.rate_limit_exceeded(
                Map.get(response_body, "message", "Rate limit exceeded"),
                rate_limit.retry_after,
                %{rate_limit: rate_limit}
              )

            {:error, error}

          status when status >= 500 ->
            {:error,
             Error.server_error(
               Map.get(response_body, "message", "Server error"),
               status,
               response_body
             )}

          _ ->
            {:error, Error.server_error("Unexpected response", status, response_body)}
        end

      {:error, _} ->
        {:error, Error.network_error("Invalid JSON response", %{body: body, status: status})}
    end
  end

  defp headers_to_map(headers) do
    Enum.into(headers, %{}, fn {key, value} -> {String.downcase(key), value} end)
  end
end
