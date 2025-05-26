# Basic Usage Example for Poodle Elixir SDK

# Make sure to set your API key first:
# export POODLE_API_KEY=your_api_key_here

# Send a simple HTML email
case Poodle.send_html(
       "sender@yourdomain.com",
       "recipient@example.com",
       "Welcome to Poodle!",
       "<h1>Hello World!</h1><p>This is a test email sent using the Poodle Elixir SDK.</p>"
     ) do
  {:ok, response} ->
    IO.puts("✅ Email sent successfully!")
    IO.puts("Message: #{response.message}")

    if response.rate_limit do
      IO.puts("Rate limit remaining: #{response.rate_limit.remaining}")
    end

  {:error, %Poodle.Error{type: :unauthorized}} ->
    IO.puts("❌ Authentication failed. Please check your API key.")

  {:error, %Poodle.Error{type: :rate_limit_exceeded, retry_after: retry_after}} ->
    IO.puts("❌ Rate limit exceeded. Retry after #{retry_after} seconds.")

  {:error, error} ->
    IO.puts("❌ Failed to send email: #{error.message}")
end

# Send a plain text email
case Poodle.send_text(
       "sender@yourdomain.com",
       "recipient@example.com",
       "Welcome to Poodle!",
       "Hello World! This is a test email sent using the Poodle Elixir SDK."
     ) do
  {:ok, response} ->
    IO.puts("✅ Text email sent successfully!")

  {:error, error} ->
    IO.puts("❌ Failed to send text email: #{error.message}")
end

# Send email with both HTML and text content
case Poodle.send(
       "sender@yourdomain.com",
       "recipient@example.com",
       "Welcome to Poodle!",
       html: "<h1>Hello World!</h1><p>This is a test email.</p>",
       text: "Hello World! This is a test email."
     ) do
  {:ok, response} ->
    IO.puts("✅ Multi-format email sent successfully!")

  {:error, error} ->
    IO.puts("❌ Failed to send multi-format email: #{error.message}")
end
