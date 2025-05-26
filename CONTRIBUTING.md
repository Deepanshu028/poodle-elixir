# Contributing to Poodle Elixir SDK

Thank you for your interest in contributing to the Poodle Elixir SDK! We welcome contributions from the community.

## Development Setup

### Requirements

- Elixir 1.14 or higher
- OTP 25 or higher
- Git

### Setup

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/yourusername/poodle-elixir.git
   cd poodle-elixir
   ```

3. Install dependencies:

   ```bash
   mix deps.get
   ```

4. Compile the project:
   ```bash
   mix compile
   ```

## Development Workflow

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/poodle/client_test.exs

# Run tests with coverage
mix test --cover

# Run tests in watch mode
mix test.watch
```

### Code Quality

```bash
# Check code formatting
mix format --check-formatted

# Format code automatically
mix format

# Run static analysis with Credo
mix credo

# Run strict Credo analysis
mix credo --strict

# Run Dialyzer for type checking
mix dialyzer

# Run security audit
mix deps.audit

# Generate documentation
mix docs

# Start documentation server
mix docs && open doc/index.html
```

### Making Changes

1. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes
3. Write or update tests
4. Ensure all tests pass and code quality checks succeed
5. Commit your changes with a descriptive message
6. Push to your fork
7. Create a pull request

## Code Standards

### Elixir Standards

- Follow the Elixir Style Guide
- Use `mix format` for consistent code formatting (configuration in `.formatter.exs`)
- Maintain Elixir 1.14+ and OTP 25+ compatibility
- Write comprehensive documentation using `@doc` and `@spec`
- Use pattern matching and proper error handling with `{:ok, result}` and `{:error, reason}` tuples
- Follow OTP principles and GenServer patterns where appropriate

### Testing Standards

- Write ExUnit tests for all new functionality
- Maintain or improve test coverage
- Use descriptive test descriptions with `describe` and `test` blocks
- Test both success and failure scenarios
- Use `Mox` for mocking HTTP interactions when appropriate
- Use `Bypass` for integration testing with external services

### Documentation Standards

- Document all public functions with `@doc`
- Include `@spec` type specifications for all public functions
- Update README.md if adding new features
- Include code examples in documentation
- Keep examples in the `examples/` directory up to date
- Ensure documentation can be generated with `mix docs`

## Pull Request Process

1. Ensure your code follows the existing style and conventions
2. Run the full test suite and ensure all tests pass: `mix test`
3. Run code quality checks:
   - `mix format --check-formatted`
   - `mix credo --strict`
   - `mix dialyzer`
   - `mix deps.audit`
4. Update documentation as needed
5. Write a clear PR description explaining your changes
6. Link any relevant issues

## We Use [Github Flow](https://docs.github.com/en/get-started/using-github/github-flow)

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code follows Elixir formatting and Credo guidelines.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker](https://github.com/usepoodle/poodle-elixir/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/usepoodle/poodle-elixir/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can.
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)
- Elixir/OTP versions you're using

## Use a Consistent Coding Style

- Follow the `mix format` configuration in `.formatter.exs`
- Use meaningful names for modules, functions, and variables
- Write descriptive commit messages
- Use snake_case for function and variable names
- Use PascalCase for module names
- Keep lines under 98 characters (default formatter setting)
- Use pattern matching effectively
- Handle errors with `{:ok, result}` and `{:error, reason}` tuples

### Module Organization

```elixir
defmodule Poodle.YourModule do
  @moduledoc """
  Brief description of what this module does.
  """

  # Module attributes
  @default_timeout 5000

  # Types
  @type your_type :: String.t()

  # Public API functions
  @doc """
  Description of the function.
  """
  @spec your_function(String.t()) :: {:ok, any()} | {:error, atom()}
  def your_function(param) do
    # Implementation
  end

  # Private helper functions
  defp helper_function do
    # Implementation
  end
end
```

## Local Development Commands

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run tests with coverage
mix test --cover

# Format code
mix format

# Check code quality
mix credo

# Run type checking
mix dialyzer

# Generate documentation
mix docs

# Run security audit
mix deps.audit

# Start IEx with project loaded
iex -S mix

# Clean build artifacts
mix clean
```

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
