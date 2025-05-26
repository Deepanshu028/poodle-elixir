defmodule Poodle.Response do
  @moduledoc """
  Response struct for the Poodle SDK.

  Represents successful API responses with rate limit information.
  """

  alias Poodle.RateLimit

  @type t :: %__MODULE__{
          success: boolean(),
          message: String.t(),
          rate_limit: RateLimit.t() | nil,
          raw_response: map() | nil
        }

  defstruct [:success, :message, :rate_limit, :raw_response]

  @doc """
  Create a new response from HTTP response data.

  ## Examples

      iex> body = %{"success" => true, "message" => "Email queued for sending"}
      iex> headers = %{"ratelimit-remaining" => "1"}
      iex> Poodle.Response.new(body, headers)
      %Poodle.Response{success: true, message: "Email queued for sending", ...}

  """
  @spec new(map(), map()) :: t()
  def new(response_body, headers \\ %{}) do
    %__MODULE__{
      success: Map.get(response_body, "success", false),
      message: Map.get(response_body, "message", ""),
      rate_limit: RateLimit.from_headers(headers),
      raw_response: response_body
    }
  end

  @doc """
  Check if the response indicates success.

  ## Examples

      iex> response = %Poodle.Response{success: true}
      iex> Poodle.Response.success?(response)
      true

  """
  @spec success?(t()) :: boolean()
  def success?(%__MODULE__{success: success}), do: success

  @doc """
  Get the response message.

  ## Examples

      iex> response = %Poodle.Response{message: "Email queued for sending"}
      iex> Poodle.Response.message(response)
      "Email queued for sending"

  """
  @spec message(t()) :: String.t()
  def message(%__MODULE__{message: message}), do: message

  @doc """
  Get rate limit information from the response.

  ## Examples

      iex> response = %Poodle.Response{rate_limit: %Poodle.RateLimit{remaining: 1}}
      iex> Poodle.Response.rate_limit(response)
      %Poodle.RateLimit{remaining: 1}

  """
  @spec rate_limit(t()) :: RateLimit.t() | nil
  def rate_limit(%__MODULE__{rate_limit: rate_limit}), do: rate_limit
end
