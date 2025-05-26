# Poodle Elixir SDK

[![Hex.pm](https://img.shields.io/hexpm/v/poodle.svg)](https://hex.pm/packages/poodle)
[![Build Status](https://github.com/usepoodle/poodle-elixir/workflows/CI/badge.svg)](https://github.com/usepoodle/poodle-elixir/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

Elixir SDK for the Poodle email sending API.

## Features

- 🚀 Simple and intuitive API
- 📧 HTML and plain text email support
- 🔒 Comprehensive error handling
- ⚡ Asynchronous email sending
- 🛡️ Built-in input validation
- 📊 Rate limiting support
- 🔧 Configurable via environment variables
- 🎯 Pattern-matchable error tuples
- 📖 Complete documentation and examples
- ✅ Elixir 1.14+ support

## Installation

Add `poodle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:poodle, "~> 1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Quick Start

### 1. Set your API key

```bash
export POODLE_API_KEY=your_api_key_here
```

### 2. Send your first email

```elixir
# Send an HTML email
{:ok, response} = Poodle.send_html(
  "sender@yourdomain.com",
  "recipient@example.com",
  "Hello from Poodle!",
  "<h1>Welcome!</h1><p>This is a test email.</p>"
)

IO.puts("Email sent! Message: #{response.message}")
```

## Configuration

The SDK can be configured via environment variables or application config:

### Environment Variables

```bash
export POODLE_API_KEY=your_api_key
export POODLE_BASE_URL=https://api.usepoodle.com
export POODLE_TIMEOUT=30000
export POODLE_DEBUG=false
```

### Application Config

```elixir
# config/config.exs
config :poodle,
  api_key: "your_api_key",
  base_url: "https://api.usepoodle.com",
  timeout: 30_000,
  debug: false
```

## Usage Examples

### Basic Email Sending

```elixir
# HTML email
{:ok, response} = Poodle.send_html(
  "sender@example.com",
  "recipient@example.com",
  "Welcome!",
  "<h1>Hello World!</h1><p>Welcome to our service!</p>"
)

# Plain text email
{:ok, response} = Poodle.send_text(
  "sender@example.com",
  "recipient@example.com",
  "Welcome!",
  "Hello World! Welcome to our service!"
)

# Both HTML and text
{:ok, response} = Poodle.send(
  "sender@example.com",
  "recipient@example.com",
  "Welcome!",
  html: "<h1>Hello World!</h1>",
  text: "Hello World!"
)
```

### Using Email Structs

```elixir
# Create an email struct
{:ok, email} = Poodle.Email.new(
  "sender@example.com",
  "recipient@example.com",
  "Welcome!",
  html: "<h1>Hello World!</h1>",
  text: "Hello World!"
)

# Send the email
{:ok, response} = Poodle.send_email(email)
```

### Asynchronous Sending

```elixir
# Send email asynchronously
task = Poodle.send_async(
  "sender@example.com",
  "recipient@example.com",
  "Welcome!",
  html: "<h1>Hello World!</h1>"
)

# Wait for result
{:ok, response} = Task.await(task)
```

### Error Handling

```elixir
case Poodle.send_html(from, to, subject, html) do
  {:ok, response} ->
    IO.puts("Email sent! Message: #{response.message}")

    # Check rate limit info
    if response.rate_limit do
      IO.puts("Rate limit remaining: #{response.rate_limit.remaining}")
    end

  {:error, %Poodle.Error{type: :unauthorized}} ->
    IO.puts("Invalid API key")

  {:error, %Poodle.Error{type: :rate_limit_exceeded, retry_after: retry_after}} ->
    IO.puts("Rate limited. Retry after #{retry_after} seconds")

  {:error, %Poodle.Error{type: :validation_error, message: message}} ->
    IO.puts("Validation error: #{message}")

  {:error, %Poodle.Error{type: :payment_required}} ->
    IO.puts("Subscription expired or limit reached")

  {:error, error} ->
    IO.puts("Error: #{error.message}")
end
```

## API Reference

### Main Functions

- `Poodle.send/4` - Send email with HTML and/or text content
- `Poodle.send_html/5` - Send HTML email
- `Poodle.send_text/5` - Send plain text email
- `Poodle.send_email/3` - Send email using Email struct
- `Poodle.send_async/4` - Send email asynchronously
- `Poodle.validate_config/1` - Validate configuration

### Data Structures

#### Email Struct

```elixir
%Poodle.Email{
  from: "sender@example.com",
  to: "recipient@example.com",
  subject: "Email Subject",
  html: "<h1>HTML content</h1>",  # optional
  text: "Plain text content"      # optional
}
```

#### Response Struct

```elixir
%Poodle.Response{
  success: true,
  message: "Email queued for sending",
  rate_limit: %Poodle.RateLimit{
    limit: 2,
    remaining: 1,
    reset: 1640995200
  }
}
```

#### Error Struct

```elixir
%Poodle.Error{
  type: :rate_limit_exceeded,
  message: "Rate limit exceeded",
  status_code: 429,
  retry_after: 30,
  details: %{...}
}
```

## Error Types

The SDK provides specific error types for different scenarios:

- `:validation_error` - Invalid input data
- `:unauthorized` - Invalid or missing API key
- `:forbidden` - Account suspended
- `:payment_required` - Subscription issues
- `:rate_limit_exceeded` - Rate limit exceeded
- `:server_error` - Server-side errors
- `:network_error` - Network connectivity issues
- `:timeout` - Request timeout
- `:dns_error` - DNS resolution failed
- `:ssl_error` - SSL/TLS errors

## Phoenix Integration

### In a Phoenix Controller

```elixir
defmodule MyAppWeb.EmailController do
  use MyAppWeb, :controller

  def send_welcome(conn, %{"email" => email, "name" => name}) do
    case Poodle.send_html(
      "welcome@myapp.com",
      email,
      "Welcome, #{name}!",
      render_welcome_email(name)
    ) do
      {:ok, _response} ->
        json(conn, %{success: true, message: "Welcome email sent"})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, error: error.message})
    end
  end

  defp render_welcome_email(name) do
    """
    <h1>Welcome, #{name}!</h1>
    <p>Thank you for joining our service.</p>
    """
  end
end
```

### Background Jobs with Oban

```elixir
defmodule MyApp.Workers.EmailWorker do
  use Oban.Worker, queue: :emails

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "welcome", "email" => email, "name" => name}}) do
    case Poodle.send_html(
      "welcome@myapp.com",
      email,
      "Welcome, #{name}!",
      render_welcome_email(name)
    ) do
      {:ok, _response} -> :ok
      {:error, _error} -> {:error, "Failed to send email"}
    end
  end

  defp render_welcome_email(name) do
    """
    <h1>Welcome, #{name}!</h1>
    <p>Thank you for joining our service.</p>
    """
  end
end
```

## Development

### Running Tests

```bash
# Set test environment variables
export POODLE_API_KEY=test_api_key

# Run tests
mix test

# Run tests with coverage
mix test --cover
```

### Code Quality

```bash
# Format code
mix format

# Run Credo
mix credo

# Run Dialyzer
mix dialyzer
```

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on the process for submitting pull requests and our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
