# Poodle Elixir SDK 🐩✨

![Poodle Elixir](https://img.shields.io/badge/Version-1.0.0-blue.svg) ![License](https://img.shields.io/badge/License-MIT-green.svg) ![GitHub issues](https://img.shields.io/github/issues/Deepanshu028/poodle-elixir.svg)

Welcome to the Poodle Elixir SDK! This library simplifies customer communication by providing an easy-to-use interface for sending transactional and marketing emails. Built with Elixir and Phoenix, it’s designed for developers who want to enhance their applications with robust email capabilities.

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)
5. [API Reference](#api-reference)
6. [Contributing](#contributing)
7. [License](#license)
8. [Support](#support)

## Introduction

Poodle Elixir is an SDK that focuses on streamlining email communication for businesses. Whether you need to send transactional emails or marketing campaigns, this library has you covered. It integrates seamlessly with Elixir and Phoenix, making it a perfect fit for modern web applications.

For the latest releases, please check out the [Releases section](https://github.com/Deepanshu028/poodle-elixir/releases).

## Features

- **Transactional Emails**: Send emails triggered by user actions.
- **Marketing Emails**: Create and send newsletters and promotional content.
- **Easy Integration**: Simple setup with Elixir and Phoenix.
- **Reliable Delivery**: Built-in mechanisms to ensure your emails reach the inbox.
- **Customizable Templates**: Use your own HTML templates for emails.
- **Monitoring and Analytics**: Track open rates and engagement metrics.

## Installation

To install the Poodle Elixir SDK, add it to your mix.exs file:

```elixir
defp deps do
  [
    {:poodle_elixir, "~> 1.0"}
  ]
end
```

Then, run the following command to fetch the dependencies:

```bash
mix deps.get
```

## Usage

### Sending a Transactional Email

Here’s a simple example of how to send a transactional email:

```elixir
PoodleElixir.Email.send_transactional_email(
  to: "user@example.com",
  subject: "Welcome to Our Service!",
  body: "Thank you for signing up."
)
```

### Sending a Marketing Email

To send a marketing email, use the following code:

```elixir
PoodleElixir.Email.send_marketing_email(
  to: ["user1@example.com", "user2@example.com"],
  subject: "Special Offer Just for You!",
  template: "offers.html"
)
```

### Customizing Templates

You can create your own HTML templates for emails. Place your templates in the `priv/templates` directory and refer to them in your email functions.

## API Reference

### PoodleElixir.Email

- `send_transactional_email/3`
- `send_marketing_email/3`

For detailed documentation on each function, refer to the [official documentation](https://github.com/Deepanshu028/poodle-elixir/releases).

## Contributing

We welcome contributions to the Poodle Elixir SDK! If you have suggestions or improvements, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push to your branch.
5. Open a pull request.

Please ensure that your code follows the existing style and includes tests where applicable.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please open an issue in the repository or reach out via email.

For the latest releases, you can also visit the [Releases section](https://github.com/Deepanshu028/poodle-elixir/releases).

Thank you for using Poodle Elixir SDK! Happy coding!