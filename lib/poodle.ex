defmodule Poodle do
  @moduledoc """
  Elixir SDK for the Poodle email sending API.

  This module provides a simple and idiomatic Elixir interface for sending
  emails through the Poodle platform. It supports both HTML and plain text
  emails, comprehensive error handling, rate limiting, and asynchronous operations.

  ## Quick Start

      # Set your API key
      export POODLE_API_KEY=your_api_key_here

      # Send a simple email
      {:ok, response} = Poodle.send(
        "sender@yourdomain.com",
        "recipient@example.com",
        "Hello from Poodle!",
        html: "<h1>Welcome!</h1><p>This is a test email.</p>",
        text: "Welcome! This is a test email."
      )

  ## Configuration

  The SDK can be configured via environment variables or application config:

      # Environment variables
      export POODLE_API_KEY=your_api_key
      export POODLE_BASE_URL=https://api.usepoodle.com
      export POODLE_TIMEOUT=30000
      export POODLE_DEBUG=false

      # Or in config/config.exs
      config :poodle,
        api_key: "your_api_key",
        base_url: "https://api.usepoodle.com",
        timeout: 30_000,
        debug: false

  ## Error Handling

  All functions return `{:ok, response}` or `{:error, error}` tuples:

      case Poodle.send(from, to, subject, html: html) do
        {:ok, response} ->
          IO.puts("Email sent! Message: " <> response.message)

        {:error, %Poodle.Error{type: :rate_limit_exceeded, retry_after: retry_after}} ->
          IO.puts("Rate limited. Retry after " <> to_string(retry_after) <> " seconds")

        {:error, %Poodle.Error{type: :unauthorized}} ->
          IO.puts("Invalid API key")

        {:error, error} ->
          IO.puts("Error: " <> error.message)
      end

  """

  alias Poodle.{Client, Config, Email, Error, Response}

  @doc """
  Send an email with HTML and/or text content.

  ## Parameters

  - `from` - Sender email address
  - `to` - Recipient email address
  - `subject` - Email subject line
  - `opts` - Options including `:html`, `:text`, `:config`

  ## Examples

      # HTML email
      {:ok, response} = Poodle.send(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>"
      )

      # Text email
      {:ok, response} = Poodle.send(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        text: "Hello World!"
      )

      # Both HTML and text
      {:ok, response} = Poodle.send(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>",
        text: "Hello World!"
      )

      # With custom config
      {:ok, response} = Poodle.send(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>",
        config: [api_key: "custom_key"]
      )

  """
  @spec send(String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  defdelegate send(from, to, subject, opts \\ []), to: Client

  @doc """
  Send an HTML email.

  ## Examples

      {:ok, response} = Poodle.send_html(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        "<h1>Hello World!</h1><p>Welcome to our service!</p>"
      )

  """
  @spec send_html(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  defdelegate send_html(from, to, subject, html, opts \\ []), to: Client

  @doc """
  Send a plain text email.

  ## Examples

      {:ok, response} = Poodle.send_text(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        "Hello World! Welcome to our service!"
      )

  """
  @spec send_text(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  defdelegate send_text(from, to, subject, text, opts \\ []), to: Client

  @doc """
  Send an email using an Email struct.

  ## Examples

      {:ok, email} = Poodle.Email.new(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>"
      )

      {:ok, response} = Poodle.send_email(email)

  """
  @spec send_email(Email.t(), Config.t() | nil, keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  defdelegate send_email(email, config \\ nil, opts \\ []), to: Client

  @doc """
  Send an email asynchronously.

  Returns a Task that can be awaited for the result.

  ## Examples

      task = Poodle.send_async(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>"
      )

      {:ok, response} = Task.await(task)

  """
  @spec send_async(String.t(), String.t(), String.t(), keyword()) :: Task.t()
  defdelegate send_async(from, to, subject, opts \\ []), to: Client

  @doc """
  Send an HTML email asynchronously.

  ## Examples

      task = Poodle.send_html_async(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        "<h1>Hello World!</h1>"
      )

      {:ok, response} = Task.await(task)

  """
  @spec send_html_async(String.t(), String.t(), String.t(), String.t(), keyword()) :: Task.t()
  defdelegate send_html_async(from, to, subject, html, opts \\ []), to: Client

  @doc """
  Send a plain text email asynchronously.

  ## Examples

      task = Poodle.send_text_async(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        "Hello World!"
      )

      {:ok, response} = Task.await(task)

  """
  @spec send_text_async(String.t(), String.t(), String.t(), String.t(), keyword()) :: Task.t()
  defdelegate send_text_async(from, to, subject, text, opts \\ []), to: Client

  @doc """
  Send an email using an Email struct asynchronously.

  ## Examples

      {:ok, email} = Poodle.Email.new(
        "sender@example.com",
        "recipient@example.com",
        "Welcome!",
        html: "<h1>Hello World!</h1>"
      )

      task = Poodle.send_email_async(email)
      {:ok, response} = Task.await(task)

  """
  @spec send_email_async(Email.t(), Config.t() | nil, keyword()) :: Task.t()
  defdelegate send_email_async(email, config \\ nil, opts \\ []), to: Client

  @doc """
  Validate the current configuration.

  ## Examples

      case Poodle.validate_config() do
        {:ok, config} ->
          IO.puts("Configuration is valid")
        {:error, reason} ->
          IO.puts("Configuration error: " <> reason)
      end

  """
  @spec validate_config(keyword()) :: {:ok, Config.t()} | {:error, String.t()}
  defdelegate validate_config(opts \\ []), to: Config, as: :get
end
