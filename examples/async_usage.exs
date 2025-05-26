# Async Usage Example for Poodle Elixir SDK

# Send multiple emails asynchronously
tasks = [
  Poodle.send_async(
    "sender@yourdomain.com",
    "user1@example.com",
    "Welcome User 1!",
    html: "<h1>Welcome!</h1><p>Hello User 1</p>"
  ),
  Poodle.send_async(
    "sender@yourdomain.com",
    "user2@example.com",
    "Welcome User 2!",
    html: "<h1>Welcome!</h1><p>Hello User 2</p>"
  ),
  Poodle.send_async(
    "sender@yourdomain.com",
    "user3@example.com",
    "Welcome User 3!",
    html: "<h1>Welcome!</h1><p>Hello User 3</p>"
  )
]

# Wait for all tasks to complete
results = Task.await_many(tasks, 30_000)

# Process results
Enum.with_index(results, 1)
|> Enum.each(fn {result, index} ->
  case result do
    {:ok, response} ->
      IO.puts("✅ Email #{index} sent successfully: #{response.message}")

    {:error, error} ->
      IO.puts("❌ Email #{index} failed: #{error.message}")
  end
end)

# Send emails with custom timeout using Task.async_stream
emails = [
  {"user1@example.com", "Welcome User 1!"},
  {"user2@example.com", "Welcome User 2!"},
  {"user3@example.com", "Welcome User 3!"}
]

emails
|> Task.async_stream(
  fn {to, subject} ->
    Poodle.send_html(
      "sender@yourdomain.com",
      to,
      subject,
      "<h1>Welcome!</h1><p>This is an async email.</p>"
    )
  end,
  max_concurrency: 3,
  timeout: 30_000
)
|> Enum.each(fn
  {:ok, {:ok, response}} ->
    IO.puts("✅ Bulk email sent: #{response.message}")

  {:ok, {:error, error}} ->
    IO.puts("❌ Bulk email failed: #{error.message}")

  {:exit, reason} ->
    IO.puts("❌ Task exited: #{inspect(reason)}")
end)
