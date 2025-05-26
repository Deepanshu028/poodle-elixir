defmodule Poodle.Email do
  @moduledoc """
  Email struct and validation for the Poodle SDK.
  """

  @type t :: %__MODULE__{
          from: String.t(),
          to: String.t(),
          subject: String.t(),
          html: String.t() | nil,
          text: String.t() | nil
        }

  defstruct [:from, :to, :subject, :html, :text]

  @doc """
  Create a new email struct.

  ## Examples

      iex> Poodle.Email.new("from@example.com", "to@example.com", "Subject", html: "<h1>Hello</h1>")
      {:ok, %Poodle.Email{...}}

      iex> Poodle.Email.new("invalid-email", "to@example.com", "Subject")
      {:error, "Invalid from email address"}

  """
  @spec new(String.t(), String.t(), String.t(), keyword()) :: {:ok, t()} | {:error, String.t()}
  def new(from, to, subject, opts \\ []) do
    email = %__MODULE__{
      from: from,
      to: to,
      subject: subject,
      html: Keyword.get(opts, :html),
      text: Keyword.get(opts, :text)
    }

    case validate(email) do
      :ok -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Create a new email struct, raising on error.

  ## Examples

      iex> Poodle.Email.new!("from@example.com", "to@example.com", "Subject", html: "<h1>Hello</h1>")
      %Poodle.Email{...}

  """
  @spec new!(String.t(), String.t(), String.t(), keyword()) :: t()
  def new!(from, to, subject, opts \\ []) do
    case new(from, to, subject, opts) do
      {:ok, email} -> email
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Validate an email struct.

  ## Examples

      iex> email = %Poodle.Email{from: "from@example.com", to: "to@example.com", subject: "Test", html: "<h1>Hello</h1>"}
      iex> Poodle.Email.validate(email)
      :ok

  """
  @spec validate(t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{} = email) do
    with :ok <- validate_from(email.from),
         :ok <- validate_to(email.to),
         :ok <- validate_subject(email.subject),
         :ok <- validate_content(email.html, email.text) do
      validate_content_size(email.html, email.text)
    end
  end

  @doc """
  Convert email struct to a map for API requests.

  ## Examples

      iex> email = %Poodle.Email{from: "from@example.com", to: "to@example.com", subject: "Test", html: "<h1>Hello</h1>"}
      iex> Poodle.Email.to_map(email)
      %{from: "from@example.com", to: "to@example.com", subject: "Test", html: "<h1>Hello</h1>"}

  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = email) do
    %{
      from: email.from,
      to: email.to,
      subject: email.subject
    }
    |> maybe_put(:html, email.html)
    |> maybe_put(:text, email.text)
  end

  # Private validation functions

  defp validate_from(nil), do: {:error, "From email address is required"}
  defp validate_from(""), do: {:error, "From email address cannot be empty"}

  defp validate_from(from) when is_binary(from) do
    if valid_email?(from) do
      :ok
    else
      {:error, "Invalid from email address: #{from}"}
    end
  end

  defp validate_from(_), do: {:error, "From email address must be a string"}

  defp validate_to(nil), do: {:error, "To email address is required"}
  defp validate_to(""), do: {:error, "To email address cannot be empty"}

  defp validate_to(to) when is_binary(to) do
    if valid_email?(to) do
      :ok
    else
      {:error, "Invalid to email address: #{to}"}
    end
  end

  defp validate_to(_), do: {:error, "To email address must be a string"}

  defp validate_subject(nil), do: {:error, "Subject is required"}
  defp validate_subject(""), do: {:error, "Subject cannot be empty"}
  defp validate_subject(subject) when is_binary(subject), do: :ok
  defp validate_subject(_), do: {:error, "Subject must be a string"}

  defp validate_content(nil, nil), do: {:error, "Either HTML or text content is required"}
  defp validate_content(html, text) when is_binary(html) or is_binary(text), do: :ok
  defp validate_content(_, _), do: {:error, "HTML and text content must be strings"}

  defp validate_content_size(html, text) do
    max_size = Poodle.Config.max_content_size()

    html_size = if html, do: byte_size(html), else: 0
    text_size = if text, do: byte_size(text), else: 0

    cond do
      html_size > max_size ->
        {:error,
         "HTML content size (#{html_size} bytes) exceeds maximum allowed size (#{max_size} bytes)"}

      text_size > max_size ->
        {:error,
         "Text content size (#{text_size} bytes) exceeds maximum allowed size (#{max_size} bytes)"}

      true ->
        :ok
    end
  end

  defp valid_email?(email) do
    # Basic email validation using regex
    # For production, you might want to use a more sophisticated library
    email_regex = ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    Regex.match?(email_regex, email)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
