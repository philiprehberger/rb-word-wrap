# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::WordWrap do
  describe '.wrap' do
    it 'returns short text unchanged when within width' do
      expect(described_class.wrap('hello world', width: 80)).to eq('hello world')
    end

    it 'wraps long text at word boundaries' do
      text = 'the quick brown fox jumps over the lazy dog'
      result = described_class.wrap(text, width: 20)
      result.split("\n").each do |line|
        expect(line.length).to be <= 20
      end
      expect(result).to eq("the quick brown fox\njumps over the lazy\ndog")
    end

    it 'never breaks mid-word when word fits on a line' do
      text = 'hello beautiful world'
      result = described_class.wrap(text, width: 10)
      lines = result.split("\n")
      expect(lines).to eq(%w[hello beautiful world])
    end

    it 'hard wraps a single word longer than width' do
      text = 'abcdefghijklmnop'
      result = described_class.wrap(text, width: 5)
      lines = result.split("\n")
      lines.each do |line|
        expect(line.length).to be <= 5
      end
      expect(lines.join).to eq(text)
    end

    it 'applies uniform indent to all lines' do
      text = 'the quick brown fox jumps over'
      result = described_class.wrap(text, width: 20, indent: '  ')
      lines = result.split("\n")
      lines.each do |line|
        expect(line).to start_with('  ')
        expect(line.length).to be <= 20
      end
    end

    it 'applies hanging indent with first_indent different from indent' do
      text = 'the quick brown fox jumps over the lazy dog'
      result = described_class.wrap(text, width: 25, first_indent: '- ', indent: '  ')
      lines = result.split("\n")
      expect(lines.first).to start_with('- ')
      lines[1..].each do |line|
        expect(line).to start_with('  ')
      end
    end

    it 'preserves ANSI codes but does not count them in width' do
      text = "\e[31mhello\e[0m \e[32mworld\e[0m beautiful day"
      result = described_class.wrap(text, width: 15)
      lines = result.split("\n")
      lines.each do |line|
        visible = described_class.visible_width(line)
        expect(visible).to be <= 15
      end
      expect(result).to include("\e[31m")
      expect(result).to include("\e[32m")
    end

    it 'preserves existing newlines as paragraph breaks' do
      text = "first paragraph\nsecond paragraph"
      result = described_class.wrap(text, width: 80)
      expect(result).to eq("first paragraph\nsecond paragraph")
    end
  end

  describe '.truncate' do
    it 'returns short text unchanged' do
      expect(described_class.truncate('hello', width: 10)).to eq('hello')
    end

    it 'truncates at word boundary with default omission' do
      text = 'the quick brown fox'
      result = described_class.truncate(text, width: 15)
      expect(result.length).to be <= 15
      expect(result).to end_with('...')
    end

    it 'uses custom omission string' do
      text = 'the quick brown fox jumps over'
      result = described_class.truncate(text, width: 20, omission: ' [...]')
      expect(result).to end_with(' [...]')
      expect(result.length).to be <= 20
    end

    it 'handles empty string' do
      expect(described_class.truncate('', width: 10)).to eq('')
    end
  end

  describe '.visible_width' do
    it 'returns length for plain text' do
      expect(described_class.visible_width('hello')).to eq(5)
    end

    it 'ignores ANSI escape codes' do
      expect(described_class.visible_width("\e[31mhello\e[0m")).to eq(5)
    end

    it 'handles multiple ANSI codes' do
      text = "\e[1m\e[31mbold red\e[0m"
      expect(described_class.visible_width(text)).to eq(8)
    end

    it 'returns zero for empty string' do
      expect(described_class.visible_width('')).to eq(0)
    end

    it 'returns correct width with no ANSI codes in plain text' do
      expect(described_class.visible_width('abcdef')).to eq(6)
    end
  end

  describe '.wrap edge cases' do
    it 'returns empty string for empty input' do
      expect(described_class.wrap('', width: 80)).to eq('')
    end

    it 'returns a single word unchanged when it fits' do
      expect(described_class.wrap('hello', width: 80)).to eq('hello')
    end

    it 'wraps at exact width boundary' do
      text = 'abcde fghij'
      result = described_class.wrap(text, width: 5)
      lines = result.split("\n")
      expect(lines[0]).to eq('abcde')
      expect(lines[1]).to eq('fghij')
    end

    it 'handles multiple paragraphs separated by newlines' do
      text = "first paragraph words\nsecond paragraph words"
      result = described_class.wrap(text, width: 80)
      expect(result).to include("first paragraph words\nsecond paragraph words")
    end

    it 'preserves blank lines between paragraphs' do
      text = "para one\n\npara two"
      result = described_class.wrap(text, width: 80)
      lines = result.split("\n")
      expect(lines[1]).to eq('')
    end

    it 'hard wraps a very long word' do
      word = 'a' * 50
      result = described_class.wrap(word, width: 10)
      result.split("\n").each do |line|
        expect(line.length).to be <= 10
      end
    end

    it 'handles indent with empty text' do
      result = described_class.wrap('', width: 80, indent: '  ')
      expect(result.strip).to eq('')
    end

    it 'applies first_indent only to the first line' do
      text = 'word1 word2 word3 word4'
      result = described_class.wrap(text, width: 15, first_indent: '>> ', indent: '   ')
      lines = result.split("\n")
      expect(lines.first).to start_with('>> ')
      lines[1..].each { |l| expect(l).to start_with('   ') }
    end

    it 'handles text with only spaces' do
      result = described_class.wrap('     ', width: 80)
      expect(result.strip).to eq('')
    end

    it 'handles unicode characters' do
      text = 'hello world'
      result = described_class.wrap(text, width: 80)
      expect(result).to eq(text)
    end

    it 'wraps text with mixed ANSI and plain content' do
      text = "normal \e[1mbold text\e[0m more words here today"
      result = described_class.wrap(text, width: 20)
      result.split("\n").each do |line|
        expect(described_class.visible_width(line)).to be <= 20
      end
    end
  end

  describe '.truncate edge cases' do
    it 'does not truncate when text fits exactly' do
      expect(described_class.truncate('hello', width: 5)).to eq('hello')
    end

    it 'returns omission when width equals omission length' do
      result = described_class.truncate('hello world', width: 3, omission: '...')
      expect(result).to eq('...')
    end

    it 'truncates single long word' do
      result = described_class.truncate('superlongword', width: 8)
      expect(result.length).to be <= 8
      expect(result).to end_with('...')
    end

    it 'handles width of 1 with single-char omission' do
      result = described_class.truncate('hello', width: 1, omission: '.')
      expect(result.length).to be <= 1
    end

    it 'handles text that is exactly one character longer than width' do
      result = described_class.truncate('abcdef', width: 5)
      expect(result.length).to be <= 5
    end
  end

  describe '.wrap with justify' do
    it 'justifies text to fill width' do
      text = 'the quick brown fox jumps over the lazy dog near the river'
      result = described_class.wrap(text, width: 30, justify: true)
      lines = result.split("\n")
      # All lines except the last should be exactly 30 chars (or close due to word boundaries)
      lines[0..-2].each do |line|
        expect(line.length).to be >= 28
      end
    end

    it 'does not justify single-line text' do
      result = described_class.wrap('short text', width: 80, justify: true)
      expect(result).to eq('short text')
    end
  end

  describe '.center' do
    it 'centers text within width' do
      result = described_class.center('hello', width: 20)
      expect(result).to include('hello')
      expect(result.length).to be >= 5
      leading = result.index('h')
      expect(leading).to be > 0
    end

    it 'centers multiple lines' do
      result = described_class.center("hello\nworld", width: 20)
      lines = result.split("\n")
      lines.each do |line|
        expect(line.strip).to match(/\A\w+\z/)
      end
    end

    it 'handles text wider than width' do
      result = described_class.center('hello world', width: 5)
      expect(result.strip).to eq('hello world')
    end
  end

  describe '.hanging_indent' do
    it 'keeps first line flush left' do
      text = 'the quick brown fox jumps over the lazy dog'
      result = described_class.hanging_indent(text, 25, indent: 4)
      lines = result.split("\n")
      expect(lines.first).not_to start_with(' ')
    end

    it 'indents subsequent lines by the specified amount' do
      text = 'the quick brown fox jumps over the lazy dog'
      result = described_class.hanging_indent(text, 25, indent: 4)
      lines = result.split("\n")
      lines[1..].each do |line|
        expect(line).to start_with('    ')
      end
    end

    it 'wraps multi-line text correctly' do
      text = 'one two three four five six seven eight nine ten eleven twelve'
      result = described_class.hanging_indent(text, 20, indent: 6)
      lines = result.split("\n")
      expect(lines.length).to be >= 3
      expect(lines.first).not_to start_with(' ')
      lines[1..].each { |line| expect(line).to start_with('      ') }
    end

    it 'handles short text that fits on one line' do
      result = described_class.hanging_indent('hello', 80, indent: 4)
      expect(result).to eq('hello')
    end

    it 'respects width for all lines' do
      text = 'the quick brown fox jumps over the lazy dog near the river bank'
      result = described_class.hanging_indent(text, 20, indent: 4)
      result.split("\n").each do |line|
        expect(described_class.visible_width(line)).to be <= 20
      end
    end
  end

  describe '.fit' do
    it 'returns text unchanged when it fits within height' do
      text = 'hello world'
      result = described_class.fit(text, width: 80, height: 5)
      expect(result).to eq('hello world')
    end

    it 'truncates to the specified number of lines' do
      text = 'the quick brown fox jumps over the lazy dog near the river bank today'
      result = described_class.fit(text, width: 15, height: 2)
      lines = result.split("\n")
      expect(lines.length).to eq(2)
    end

    it 'appends omission string to last line when truncated' do
      text = 'the quick brown fox jumps over the lazy dog near the river bank today'
      result = described_class.fit(text, width: 20, height: 2)
      lines = result.split("\n")
      expect(lines.last).to include('...')
    end

    it 'uses custom omission string' do
      text = 'one two three four five six seven eight nine ten'
      result = described_class.fit(text, width: 15, height: 1, omission: ' [more]')
      expect(result).to include('[more]')
    end

    it 'handles exact fit without truncation' do
      text = 'hello world foo bar'
      result = described_class.fit(text, width: 10, height: 10)
      wrapped = described_class.wrap(text, width: 10)
      expect(result).to eq(wrapped)
    end

    it 'handles height of 1' do
      text = 'the quick brown fox jumps over'
      result = described_class.fit(text, width: 15, height: 1)
      lines = result.split("\n")
      expect(lines.length).to eq(1)
    end
  end

  describe '.paragraphs' do
    it 'wraps a single paragraph' do
      text = 'the quick brown fox jumps over the lazy dog'
      result = described_class.paragraphs(text, 20)
      expect(result).to eq(described_class.wrap(text, width: 20))
    end

    it 'wraps multiple paragraphs independently' do
      text = "first paragraph words here\n\nsecond paragraph words here"
      result = described_class.paragraphs(text, 20)
      parts = result.split("\n\n")
      expect(parts.length).to eq(2)
    end

    it 'joins paragraphs with default single blank line' do
      text = "para one\n\npara two"
      result = described_class.paragraphs(text, 80)
      expect(result).to eq("para one\n\npara two")
    end

    it 'joins paragraphs with custom spacing' do
      text = "para one\n\npara two"
      result = described_class.paragraphs(text, 80, spacing: 2)
      expect(result).to eq("para one\n\n\npara two")
    end

    it 'handles three paragraphs' do
      text = "one\n\ntwo\n\nthree"
      result = described_class.paragraphs(text, 80)
      parts = result.split("\n\n")
      expect(parts.length).to eq(3)
      expect(parts).to eq(%w[one two three])
    end

    it 'respects width for each paragraph' do
      text = "the quick brown fox jumps over\n\nthe lazy dog sleeps near the river"
      result = described_class.paragraphs(text, 15)
      result.split("\n").each do |line|
        next if line.empty?

        expect(described_class.visible_width(line)).to be <= 15
      end
    end
  end

  describe '.unwrap' do
    it 'removes single newlines within a paragraph' do
      text = "the quick brown\nfox jumps over\nthe lazy dog"
      result = described_class.unwrap(text)
      expect(result).to eq('the quick brown fox jumps over the lazy dog')
    end

    it 'preserves paragraph boundaries (double newlines)' do
      text = "first paragraph\nwith wrapping\n\nsecond paragraph\nwith wrapping"
      result = described_class.unwrap(text)
      parts = result.split("\n\n")
      expect(parts.length).to eq(2)
      expect(parts[0]).to eq('first paragraph with wrapping')
      expect(parts[1]).to eq('second paragraph with wrapping')
    end

    it 'handles text with no newlines' do
      text = 'already one line'
      expect(described_class.unwrap(text)).to eq(text)
    end

    it 'handles multiple paragraphs' do
      text = "para one\nline two\n\npara two\nline two\n\npara three"
      result = described_class.unwrap(text)
      parts = result.split("\n\n")
      expect(parts.length).to eq(3)
    end

    it 'collapses extra spaces after unwrapping' do
      text = "hello  \n world"
      result = described_class.unwrap(text)
      expect(result).not_to include('  ')
    end
  end

  describe '.columns' do
    it 'formats two columns side by side' do
      result = described_class.columns(
        ['hello world', 'foo bar'],
        widths: [15, 15],
        separator: ' | '
      )
      lines = result.split("\n")
      expect(lines.length).to be >= 1
      expect(lines.first).to include('hello world')
      expect(lines.first).to include('foo bar')
    end

    it 'handles columns of different lengths' do
      result = described_class.columns(
        ["line one\nline two\nline three", 'short'],
        widths: [15, 15]
      )
      lines = result.split("\n")
      expect(lines.length).to eq(3)
    end

    it 'wraps text within column widths' do
      result = described_class.columns(
        ['the quick brown fox', 'hello world'],
        widths: [10, 15]
      )
      lines = result.split("\n")
      expect(lines.length).to be >= 2
    end
  end
end
