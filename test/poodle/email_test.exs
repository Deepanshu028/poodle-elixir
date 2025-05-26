defmodule Poodle.EmailTest do
  use ExUnit.Case, async: true

  alias Poodle.Email

  describe "new/4" do
    test "creates valid email with HTML content" do
      assert {:ok, email} =
               Email.new(
                 "from@example.com",
                 "to@example.com",
                 "Test Subject",
                 html: "<h1>Hello</h1>"
               )

      assert email.from == "from@example.com"
      assert email.to == "to@example.com"
      assert email.subject == "Test Subject"
      assert email.html == "<h1>Hello</h1>"
      assert email.text == nil
    end

    test "creates valid email with text content" do
      assert {:ok, email} =
               Email.new(
                 "from@example.com",
                 "to@example.com",
                 "Test Subject",
                 text: "Hello World"
               )

      assert email.text == "Hello World"
      assert email.html == nil
    end

    test "creates valid email with both HTML and text" do
      assert {:ok, email} =
               Email.new(
                 "from@example.com",
                 "to@example.com",
                 "Test Subject",
                 html: "<h1>Hello</h1>",
                 text: "Hello World"
               )

      assert email.html == "<h1>Hello</h1>"
      assert email.text == "Hello World"
    end

    test "returns error for invalid from email" do
      assert {:error, reason} =
               Email.new(
                 "invalid-email",
                 "to@example.com",
                 "Test Subject",
                 html: "<h1>Hello</h1>"
               )

      assert reason =~ "Invalid from email address"
    end

    test "returns error for invalid to email" do
      assert {:error, reason} =
               Email.new(
                 "from@example.com",
                 "invalid-email",
                 "Test Subject",
                 html: "<h1>Hello</h1>"
               )

      assert reason =~ "Invalid to email address"
    end

    test "returns error for empty subject" do
      assert {:error, reason} =
               Email.new(
                 "from@example.com",
                 "to@example.com",
                 "",
                 html: "<h1>Hello</h1>"
               )

      assert reason =~ "Subject cannot be empty"
    end

    test "returns error for missing content" do
      assert {:error, reason} =
               Email.new(
                 "from@example.com",
                 "to@example.com",
                 "Test Subject"
               )

      assert reason =~ "Either HTML or text content is required"
    end
  end

  describe "to_map/1" do
    test "converts email to map with HTML content" do
      {:ok, email} =
        Email.new(
          "from@example.com",
          "to@example.com",
          "Test Subject",
          html: "<h1>Hello</h1>"
        )

      map = Email.to_map(email)

      assert map == %{
               from: "from@example.com",
               to: "to@example.com",
               subject: "Test Subject",
               html: "<h1>Hello</h1>"
             }
    end

    test "converts email to map with text content" do
      {:ok, email} =
        Email.new(
          "from@example.com",
          "to@example.com",
          "Test Subject",
          text: "Hello World"
        )

      map = Email.to_map(email)

      assert map == %{
               from: "from@example.com",
               to: "to@example.com",
               subject: "Test Subject",
               text: "Hello World"
             }
    end

    test "converts email to map with both HTML and text" do
      {:ok, email} =
        Email.new(
          "from@example.com",
          "to@example.com",
          "Test Subject",
          html: "<h1>Hello</h1>",
          text: "Hello World"
        )

      map = Email.to_map(email)

      assert map == %{
               from: "from@example.com",
               to: "to@example.com",
               subject: "Test Subject",
               html: "<h1>Hello</h1>",
               text: "Hello World"
             }
    end
  end
end
