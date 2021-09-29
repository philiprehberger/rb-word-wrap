# philiprehberger-word_wrap

[![Tests](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-word_wrap.svg)](https://rubygems.org/gems/philiprehberger-word_wrap)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-word-wrap)](https://github.com/philiprehberger/rb-word-wrap/commits/main)

Text wrapping with word-boundary awareness, indentation, and ANSI escape code support

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-word_wrap"
```

Or install directly:

```bash
gem install philiprehberger-word_wrap
```

## Usage

```ruby
require "philiprehberger/word_wrap"

# Basic wrapping at a given width
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over the lazy dog', width: 20)
# => "the quick brown fox\njumps over the lazy\ndog"
```

### Indentation

Use `indent` to add a prefix to every line, or combine `first_indent` and `indent` for hanging-indent lists.

```ruby
# Uniform indent
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over', width: 25, indent: '  ')
# => "  the quick brown fox\n  jumps over"

# Hanging indent (first line different from subsequent lines)
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over', width: 25, first_indent: '- ', indent: '  ')
# => "- the quick brown fox\n  jumps over"
```

### ANSI Support

ANSI escape codes are preserved in the output but excluded from width calculations, so colored or styled text wraps correctly.

```ruby
text = "\e[31mhello\e[0m \e[32mworld\e[0m"
Philiprehberger::WordWrap.wrap(text, width: 8)
# => "\e[31mhello\e[0m\n\e[32mworld\e[0m"

# Check visible width without ANSI codes
Philiprehberger::WordWrap.visible_width("\e[31mhello\e[0m")
# => 5
```

### Truncation

Truncate text at a word boundary with a configurable omission string.

```ruby
Philiprehberger::WordWrap.truncate('the quick brown fox', width: 15)
# => "the quick..."

# Custom omission string
Philiprehberger::WordWrap.truncate('the quick brown fox', width: 18, omission: ' [...]')
# => "the quick [...]"
```

## API

| Method | Description |
|--------|-------------|
| `WordWrap.wrap(text, width: 80, indent: nil, first_indent: nil)` | Wrap text at word boundaries to fit within the given width. Words exceeding the line width are hard-wrapped. |
| `WordWrap.truncate(text, width: 80, omission: '...')` | Truncate text at a word boundary, appending the omission string |
| `WordWrap.visible_width(text)` | Return the visible character width, excluding ANSI escape codes |
| `WordWrap::ANSI_PATTERN` | Regex matching ANSI escape sequences (`\e[...m`) |
| `WordWrap.wrap_paragraph` (private) | Wrap a single paragraph, applying indent and first_indent per line |
| `WordWrap.split_preserving_ansi` (private) | Split text into words while keeping ANSI codes attached to their word |
| `WordWrap.hard_wrap_word` (private) | Break a single word into chunks that fit within max width |
| `WordWrap.split_at_visible` (private) | Split a string at a visible-character offset, skipping ANSI sequences |
| `WordWrap.extract_active_ansi` (private) | Return the last active ANSI code from a string (or empty if reset) |
| `WordWrap.truncate_at_word_boundary` (private) | Truncate text to fit within available width at a word boundary |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-word-wrap)

🐛 [Report issues](https://github.com/philiprehberger/rb-word-wrap/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-word-wrap/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
