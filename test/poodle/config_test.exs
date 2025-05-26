defmodule Poodle.ConfigTest do
  use ExUnit.Case, async: true

  alias Poodle.Config

  describe "get/1" do
    test "returns valid config with environment variables" do
      assert {:ok, config} = Config.get()
      assert config.api_key == "test_api_key_12345"
      assert config.base_url == "https://api.test.poodle.com"
      assert config.timeout == 5_000
      assert config.debug == true
    end

    test "allows overriding with options" do
      assert {:ok, config} = Config.get(api_key: "custom_key", timeout: 10_000)
      assert config.api_key == "custom_key"
      assert config.timeout == 10_000
    end

    test "returns error for missing API key" do
      assert {:error, reason} = Config.get(api_key: nil)
      assert reason =~ "API key is required"
    end

    test "returns error for invalid base URL" do
      assert {:error, reason} = Config.get(base_url: "invalid-url")
      assert reason =~ "Base URL must be a valid HTTP or HTTPS URL"
    end

    test "returns error for invalid timeout" do
      assert {:error, reason} = Config.get(timeout: -1)
      assert reason =~ "Timeout must be a positive integer"
    end
  end

  describe "validate/1" do
    test "validates valid config" do
      config = %Config{
        api_key: "test_key",
        base_url: "https://api.example.com",
        timeout: 30_000,
        debug: false,
        finch_name: Poodle.Finch
      }

      assert :ok = Config.validate(config)
    end
  end

  describe "max_content_size/0" do
    test "returns the maximum content size" do
      assert Config.max_content_size() == 10 * 1024 * 1024
    end
  end
end
