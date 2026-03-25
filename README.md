# philiprehberger-word_wrap

[![Tests](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-word_wrap.svg)](https://rubygems.org/gems/philiprehberger-word_wrap)
[![License](https://img.shields.io/github/license/philiprehberger/rb-word-wrap)](LICENSE)

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

# Basic wrapping
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over the lazy dog', width: 20)
# => "the quick brown fox\njumps over the lazy\ndog"

# Indentation
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over', width: 25, indent: '  ')
# => "  the quick brown fox\n  jumps over"

# Hanging indent
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over', width: 25, first_indent: '- ', indent: '  ')
# => "- the quick brown fox\n  jumps over"

# ANSI codes preserved but not counted in width
text = "\e[31mhello\e[0m \e[32mworld\e[0m"
Philiprehberger::WordWrap.wrap(text, width: 8)
# => "\e[31mhello\e[0m\n\e[32mworld\e[0m"

# Truncation
Philiprehberger::WordWrap.truncate('the quick brown fox', width: 15)
# => "the quick..."
```

## API

| Method | Description |
|--------|-------------|
| `WordWrap.wrap(text, width: 80, indent: nil, first_indent: nil)` | Wrap text at word boundaries to fit within the given width |
| `WordWrap.truncate(text, width: 80, omission: '...')` | Truncate text at a word boundary with omission string |
| `WordWrap.visible_width(text)` | Return the visible character width excluding ANSI escape codes |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
