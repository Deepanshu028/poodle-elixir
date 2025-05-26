defmodule Poodle.RateLimit do
  @moduledoc """
  Rate limit information for the Poodle SDK.

  Handles parsing and exposing rate limit data from API responses.
  """

  @type t :: %__MODULE__{
          limit: integer() | nil,
          remaining: integer() | nil,
          reset: integer() | nil,
          retry_after: integer() | nil
        }

  defstruct [:limit, :remaining, :reset, :retry_after]

  @doc """
  Parse rate limit information from HTTP headers.

  ## Examples

      iex> headers = %{"ratelimit-limit" => "2", "ratelimit-remaining" => "1", "ratelimit-reset" => "1640995200"}
      iex> Poodle.RateLimit.from_headers(headers)
      %Poodle.RateLimit{limit: 2, remaining: 1, reset: 1640995200}

  """
  @spec from_headers(map()) :: t()
  def from_headers(headers) do
    %__MODULE__{
      limit: parse_header_int(headers, "ratelimit-limit"),
      remaining: parse_header_int(headers, "ratelimit-remaining"),
      reset: parse_header_int(headers, "ratelimit-reset"),
      retry_after: parse_header_int(headers, "retry-after")
    }
  end

  @doc """
  Check if rate limit is exceeded.

  ## Examples

      iex> rate_limit = %Poodle.RateLimit{remaining: 0}
      iex> Poodle.RateLimit.exceeded?(rate_limit)
      true

      iex> rate_limit = %Poodle.RateLimit{remaining: 1}
      iex> Poodle.RateLimit.exceeded?(rate_limit)
      false

  """
  @spec exceeded?(t()) :: boolean()
  def exceeded?(%__MODULE__{remaining: remaining}) when is_integer(remaining) do
    remaining <= 0
  end

  def exceeded?(_), do: false

  @doc """
  Get the time until rate limit resets.

  ## Examples

      iex> rate_limit = %Poodle.RateLimit{reset: 1640995200}
      iex> Poodle.RateLimit.time_until_reset(rate_limit)
      300  # seconds until reset

  """
  @spec time_until_reset(t()) :: integer() | nil
  def time_until_reset(%__MODULE__{reset: reset}) when is_integer(reset) do
    current_time = System.system_time(:second)
    max(0, reset - current_time)
  end

  def time_until_reset(_), do: nil

  @doc """
  Get the recommended wait time before retrying.

  Returns retry_after if available, otherwise calculates based on reset time.

  ## Examples

      iex> rate_limit = %Poodle.RateLimit{retry_after: 30}
      iex> Poodle.RateLimit.wait_time(rate_limit)
      30

  """
  @spec wait_time(t()) :: integer() | nil
  def wait_time(%__MODULE__{retry_after: retry_after}) when is_integer(retry_after) do
    retry_after
  end

  def wait_time(%__MODULE__{} = rate_limit) do
    time_until_reset(rate_limit)
  end

  # Private functions

  defp parse_header_int(headers, key) do
    case Map.get(headers, key) do
      value when is_binary(value) ->
        case Integer.parse(value) do
          {int, _} -> int
          :error -> nil
        end

      _ ->
        nil
    end
  end
end
