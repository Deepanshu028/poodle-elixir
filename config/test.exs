import Config

config :poodle,
  api_key: "test_api_key_12345",
  base_url: "https://api.test.poodle.com",
  timeout: 5_000,
  debug: true

config :logger, level: :warning
