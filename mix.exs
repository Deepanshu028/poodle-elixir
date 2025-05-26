defmodule Poodle.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/usepoodle/poodle-elixir"

  def project do
    [
      app: :poodle,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :ssl],
      mod: {Poodle.Application, []}
    ]
  end

  defp deps do
    [
      # HTTP client
      {:finch, "~> 0.16"},
      # JSON encoding/decoding
      {:jason, "~> 1.4"},
      # Email validation
      {:email_checker, "~> 0.2"},
      # Telemetry
      {:telemetry, "~> 1.0"},

      # Dev/Test dependencies
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp description do
    "Elixir SDK for the Poodle email sending API"
  end

  defp package do
    [
      name: "poodle",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Documentation" => "https://hexdocs.pm/poodle",
        "Poodle" => "https://usepoodle.com"
      },
      maintainers: ["Wilbert Liu"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
