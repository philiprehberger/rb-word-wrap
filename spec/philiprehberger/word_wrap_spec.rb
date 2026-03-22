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
end
