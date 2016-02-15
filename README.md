# philiprehberger-word_wrap

[![Gem Version](https://badge.fury.io/rb/philiprehberger-word_wrap.svg)](https://badge.fury.io/rb/philiprehberger-word_wrap)
$badge_line
[![CI](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-word-wrap/actions/workflows/ci.yml)

Text wrapping with word-boundary awareness, indentation, and ANSI support. Wraps text at word boundaries, supports hanging indent, and preserves ANSI escape codes in output.

## Requirements

- Ruby >= 3.1

## Installation

```sh
gem install philiprehberger-word_wrap
```

Or add to your Gemfile:

```ruby
gem 'philiprehberger-word_wrap'
```

## Usage

```ruby
require 'philiprehberger/word_wrap'

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

### `WordWrap.wrap(text, width: 80, indent: nil, first_indent: nil)`

Wraps text at word boundaries to fit within the given width. If `indent` is provided, it is prepended to each line. If `first_indent` is provided, it overrides `indent` for the first line only (hanging indent). Words longer than the available width are hard-wrapped.

### `WordWrap.truncate(text, width: 80, omission: '...')`

Truncates text at a word boundary to fit within the given width, appending the omission string. ANSI escape codes are excluded from width calculation.

### `WordWrap.visible_width(text)`

Returns the visible character width of a string, excluding ANSI escape codes.

## Development

```sh
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT License. See [LICENSE](LICENSE) for details.
