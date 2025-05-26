import Config

# Configuration for the Poodle SDK
# These can be overridden by environment variables

config :poodle,
  # API configuration
  api_key: System.get_env("POODLE_API_KEY"),
  base_url: System.get_env("POODLE_BASE_URL", "https://api.usepoodle.com"),
  timeout: String.to_integer(System.get_env("POODLE_TIMEOUT", "30000")),
  debug: System.get_env("POODLE_DEBUG", "false") == "true"

# Import environment specific config
import_config "#{config_env()}.exs"
