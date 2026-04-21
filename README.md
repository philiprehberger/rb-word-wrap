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

# Strip ANSI codes and return the plain string
Philiprehberger::WordWrap.strip_ansi("\e[31mhello\e[0m")
# => "hello"
```

### Justification

Full text justification expands spaces to fill the line width:

```ruby
Philiprehberger::WordWrap.wrap('the quick brown fox jumps over the lazy dog', width: 30, justify: true)
```

### Center Alignment

```ruby
Philiprehberger::WordWrap.center('hello', width: 20)
# => "       hello"
```

### Multi-Column Formatting

```ruby
Philiprehberger::WordWrap.columns(
  ['Column one text here', 'Column two text'],
  widths: [20, 20],
  separator: ' | '
)
```

### Hanging Indent

Wrap text where the first line is flush left and subsequent lines are indented. Useful for bullet lists and definition formatting.

```ruby
Philiprehberger::WordWrap.hanging_indent('the quick brown fox jumps over the lazy dog', 25, indent: 4)
# => "the quick brown fox\n    jumps over the lazy\n    dog"
```

### Fit to Box

Wrap text to a width, then truncate to at most a given number of lines. If truncated, an omission string is appended to the last line.

```ruby
Philiprehberger::WordWrap.fit('the quick brown fox jumps over the lazy dog', width: 20, height: 2)
# => "the quick brown fox\njumps over the..."
```

### Paragraph Wrapping

Split text on double newlines, wrap each paragraph independently, and rejoin with configurable spacing.

```ruby
text = "First paragraph here.\n\nSecond paragraph here."
Philiprehberger::WordWrap.paragraphs(text, 30)

# Custom spacing (2 blank lines between paragraphs)
Philiprehberger::WordWrap.paragraphs(text, 30, spacing: 2)
```

### Unwrap

Remove single newlines within paragraphs (rejoin soft-wrapped text) while preserving paragraph boundaries.

```ruby
text = "the quick brown\nfox jumps over\n\nthe lazy dog\nsleeps"
Philiprehberger::WordWrap.unwrap(text)
# => "the quick brown fox jumps over\n\nthe lazy dog sleeps"
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
| `WordWrap.wrap(text, width: 80, indent: nil, first_indent: nil, justify: false)` | Wrap text at word boundaries to fit within the given width. Words exceeding the line width are hard-wrapped. |
| `WordWrap.hanging_indent(text, width, indent:)` | Wrap text with first line flush left and subsequent lines indented by `indent` spaces |
| `WordWrap.fit(text, width:, height:, omission: '...')` | Wrap text to width, then truncate to at most `height` lines with omission string |
| `WordWrap.paragraphs(text, width, spacing: 1)` | Split on double newlines, wrap each paragraph independently, rejoin with `spacing` blank lines |
| `WordWrap.unwrap(text)` | Remove single newlines within paragraphs, preserving paragraph boundaries (double newlines) |
| `WordWrap.truncate(text, width: 80, omission: '...')` | Truncate text at a word boundary, appending the omission string |
| `WordWrap.visible_width(text)` | Return the visible character width, excluding ANSI escape codes |
| `WordWrap.strip_ansi(text)` | Return a copy of `text` with all ANSI escape codes removed |
| `WordWrap.center(text, width: 80)` | Center text within the given width |
| `WordWrap.columns(texts, widths:, separator: '  ')` | Format multiple strings into parallel columns |
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
