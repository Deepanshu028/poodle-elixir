defmodule Poodle.Error do
  @moduledoc """
  Error struct for the Poodle SDK.

  Provides structured error information with context and debugging details.
  """

  @type error_type ::
          :validation_error
          | :unauthorized
          | :forbidden
          | :payment_required
          | :unprocessable_entity
          | :rate_limit_exceeded
          | :server_error
          | :network_error
          | :timeout
          | :dns_error
          | :ssl_error

  @type t :: %__MODULE__{
          type: error_type(),
          message: String.t(),
          status_code: integer() | nil,
          details: map() | nil,
          retry_after: integer() | nil
        }

  defstruct [:type, :message, :status_code, :details, :retry_after]

  @doc """
  Create a new validation error.

  ## Examples

      iex> Poodle.Error.validation_error("Invalid email address", %{field: "from"})
      %Poodle.Error{type: :validation_error, message: "Invalid email address", details: %{field: "from"}}

  """
  @spec validation_error(String.t(), map()) :: t()
  def validation_error(message, details \\ %{}) do
    %__MODULE__{
      type: :validation_error,
      message: message,
      status_code: 400,
      details: details
    }
  end

  @doc """
  Create a new unauthorized error.

  ## Examples

      iex> Poodle.Error.unauthorized("Invalid API key")
      %Poodle.Error{type: :unauthorized, message: "Invalid API key"}

  """
  @spec unauthorized(String.t(), map()) :: t()
  def unauthorized(message, details \\ %{}) do
    %__MODULE__{
      type: :unauthorized,
      message: message,
      status_code: 401,
      details: details
    }
  end

  @doc """
  Create a new forbidden error.

  ## Examples

      iex> Poodle.Error.forbidden("Account suspended")
      %Poodle.Error{type: :forbidden, message: "Account suspended"}

  """
  @spec forbidden(String.t(), map()) :: t()
  def forbidden(message, details \\ %{}) do
    %__MODULE__{
      type: :forbidden,
      message: message,
      status_code: 403,
      details: details
    }
  end

  @doc """
  Create a new payment required error.

  ## Examples

      iex> Poodle.Error.payment_required("Subscription expired")
      %Poodle.Error{type: :payment_required, message: "Subscription expired"}

  """
  @spec payment_required(String.t(), map()) :: t()
  def payment_required(message, details \\ %{}) do
    %__MODULE__{
      type: :payment_required,
      message: message,
      status_code: 402,
      details: details
    }
  end

  @doc """
  Create a new rate limit exceeded error.

  ## Examples

      iex> Poodle.Error.rate_limit_exceeded("Rate limit exceeded", 30)
      %Poodle.Error{type: :rate_limit_exceeded, message: "Rate limit exceeded", retry_after: 30}

  """
  @spec rate_limit_exceeded(String.t(), integer() | nil, map()) :: t()
  def rate_limit_exceeded(message, retry_after \\ nil, details \\ %{}) do
    %__MODULE__{
      type: :rate_limit_exceeded,
      message: message,
      status_code: 429,
      retry_after: retry_after,
      details: details
    }
  end

  @doc """
  Create a new server error.

  ## Examples

      iex> Poodle.Error.server_error("Internal server error", 500)
      %Poodle.Error{type: :server_error, message: "Internal server error", status_code: 500}

  """
  @spec server_error(String.t(), integer(), map()) :: t()
  def server_error(message, status_code, details \\ %{}) do
    %__MODULE__{
      type: :server_error,
      message: message,
      status_code: status_code,
      details: details
    }
  end

  @doc """
  Create a new network error.

  ## Examples

      iex> Poodle.Error.network_error("Connection failed")
      %Poodle.Error{type: :network_error, message: "Connection failed"}

  """
  @spec network_error(String.t(), map()) :: t()
  def network_error(message, details \\ %{}) do
    %__MODULE__{
      type: :network_error,
      message: message,
      details: details
    }
  end

  @doc """
  Create a new timeout error.

  ## Examples

      iex> Poodle.Error.timeout("Request timeout", %{timeout: 30000})
      %Poodle.Error{type: :timeout, message: "Request timeout", details: %{timeout: 30000}}

  """
  @spec timeout(String.t(), map()) :: t()
  def timeout(message, details \\ %{}) do
    %__MODULE__{
      type: :timeout,
      message: message,
      details: details
    }
  end

  @doc """
  Create a new DNS error.

  ## Examples

      iex> Poodle.Error.dns_error("DNS resolution failed", %{host: "api.example.com"})
      %Poodle.Error{type: :dns_error, message: "DNS resolution failed", details: %{host: "api.example.com"}}

  """
  @spec dns_error(String.t(), map()) :: t()
  def dns_error(message, details \\ %{}) do
    %__MODULE__{
      type: :dns_error,
      message: message,
      details: details
    }
  end

  @doc """
  Create a new SSL error.

  ## Examples

      iex> Poodle.Error.ssl_error("SSL certificate verification failed")
      %Poodle.Error{type: :ssl_error, message: "SSL certificate verification failed"}

  """
  @spec ssl_error(String.t(), map()) :: t()
  def ssl_error(message, details \\ %{}) do
    %__MODULE__{
      type: :ssl_error,
      message: message,
      details: details
    }
  end

  @doc """
  Create a new unprocessable entity error.

  ## Examples

      iex> Poodle.Error.unprocessable_entity("Invalid data format")
      %Poodle.Error{type: :unprocessable_entity, message: "Invalid data format", status_code: 422}

  """
  @spec unprocessable_entity(String.t(), map()) :: t()
  def unprocessable_entity(message, details \\ %{}) do
    %__MODULE__{
      type: :unprocessable_entity,
      message: message,
      status_code: 422,
      details: details
    }
  end

  @doc """
  Create an error from HTTP response.

  ## Examples

      iex> Poodle.Error.from_response(401, %{"message" => "Invalid API key"})
      %Poodle.Error{type: :unauthorized, message: "Invalid API key", status_code: 401}

  """
  @spec from_response(integer(), map()) :: t()
  def from_response(status_code, response_body) do
    message = Map.get(response_body, "message", "Unknown error")
    error_details = Map.get(response_body, "error")

    details = if error_details, do: %{error: error_details}, else: %{}

    create_error_from_status(status_code, message, details)
  end

  # Private helper function to handle status code mapping
  @spec create_error_from_status(integer(), String.t(), map()) :: t()
  defp create_error_from_status(status_code, message, details) do
    case status_code do
      400 ->
        validation_error(message, details)

      401 ->
        unauthorized(message, details)

      402 ->
        payment_required(message, details)

      403 ->
        forbidden(message, details)

      422 ->
        unprocessable_entity(message, details)

      429 ->
        rate_limit_exceeded(message, nil, details)

      status when status >= 500 ->
        server_error(message, status, details)

      _ ->
        server_error(message, status_code, details)
    end
  end
end
