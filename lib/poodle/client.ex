defmodule Poodle.Client do
  @moduledoc """
  Main client for the Poodle SDK.

  Provides high-level functions for sending emails through the Poodle API.
  """

  alias Poodle.{Config, Email, Error, HTTP, Response}

  @doc """
  Send an email with both HTML and text content.

  ## Examples

      iex> Poodle.Client.send("from@example.com", "to@example.com", "Subject", html: "<h1>Hello</h1>", text: "Hello")
      {:ok, %Poodle.Response{...}}

  """
  @spec send(String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def send(from, to, subject, opts \\ []) do
    html = Keyword.get(opts, :html)
    text = Keyword.get(opts, :text)
    config_opts = Keyword.get(opts, :config, [])

    with {:ok, config} <- Config.get(config_opts),
         {:ok, email} <- Email.new(from, to, subject, html: html, text: text) do
      send_email(email, config, opts)
    end
  end

  @doc """
  Send an HTML email.

  ## Examples

      iex> Poodle.Client.send_html("from@example.com", "to@example.com", "Subject", "<h1>Hello</h1>")
      {:ok, %Poodle.Response{...}}

  """
  @spec send_html(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def send_html(from, to, subject, html, opts \\ []) do
    send(from, to, subject, Keyword.put(opts, :html, html))
  end

  @doc """
  Send a plain text email.

  ## Examples

      iex> Poodle.Client.send_text("from@example.com", "to@example.com", "Subject", "Hello")
      {:ok, %Poodle.Response{...}}

  """
  @spec send_text(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def send_text(from, to, subject, text, opts \\ []) do
    send(from, to, subject, Keyword.put(opts, :text, text))
  end

  @doc """
  Send an email using an Email struct.

  ## Examples

      iex> email = %Poodle.Email{from: "from@example.com", to: "to@example.com", subject: "Subject", html: "<h1>Hello</h1>"}
      iex> Poodle.Client.send_email(email)
      {:ok, %Poodle.Response{...}}

  """
  @spec send_email(Email.t(), Config.t() | nil, keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def send_email(%Email{} = email, config \\ nil, opts \\ []) do
    config = config || Config.get!(Keyword.get(opts, :config, []))

    case Email.validate(email) do
      :ok ->
        data = Email.to_map(email)
        HTTP.Client.post(config, "/v1/send-email", data, opts)

      {:error, reason} ->
        {:error, Error.validation_error(reason)}
    end
  end

  @doc """
  Send an email asynchronously.

  Returns a Task that can be awaited for the result.

  ## Examples

      iex> task = Poodle.Client.send_async("from@example.com", "to@example.com", "Subject", html: "<h1>Hello</h1>")
      iex> Task.await(task)
      {:ok, %Poodle.Response{...}}

  """
  @spec send_async(String.t(), String.t(), String.t(), keyword()) :: Task.t()
  def send_async(from, to, subject, opts \\ []) do
    Task.async(fn ->
      send(from, to, subject, opts)
    end)
  end

  @doc """
  Send an HTML email asynchronously.

  ## Examples

      iex> task = Poodle.Client.send_html_async("from@example.com", "to@example.com", "Subject", "<h1>Hello</h1>")
      iex> Task.await(task)
      {:ok, %Poodle.Response{...}}

  """
  @spec send_html_async(String.t(), String.t(), String.t(), String.t(), keyword()) :: Task.t()
  def send_html_async(from, to, subject, html, opts \\ []) do
    Task.async(fn ->
      send_html(from, to, subject, html, opts)
    end)
  end

  @doc """
  Send a plain text email asynchronously.

  ## Examples

      iex> task = Poodle.Client.send_text_async("from@example.com", "to@example.com", "Subject", "Hello")
      iex> Task.await(task)
      {:ok, %Poodle.Response{...}}

  """
  @spec send_text_async(String.t(), String.t(), String.t(), String.t(), keyword()) :: Task.t()
  def send_text_async(from, to, subject, text, opts \\ []) do
    Task.async(fn ->
      send_text(from, to, subject, text, opts)
    end)
  end

  @doc """
  Send an email using an Email struct asynchronously.

  ## Examples

      iex> email = %Poodle.Email{from: "from@example.com", to: "to@example.com", subject: "Subject", html: "<h1>Hello</h1>"}
      iex> task = Poodle.Client.send_email_async(email)
      iex> Task.await(task)
      {:ok, %Poodle.Response{...}}

  """
  @spec send_email_async(Email.t(), Config.t() | nil, keyword()) :: Task.t()
  def send_email_async(%Email{} = email, config \\ nil, opts \\ []) do
    Task.async(fn ->
      send_email(email, config, opts)
    end)
  end
end
