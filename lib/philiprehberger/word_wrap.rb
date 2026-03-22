# frozen_string_literal: true

require_relative 'word_wrap/version'

module Philiprehberger
  module WordWrap
    ANSI_PATTERN = /\e\[[0-9;]*m/

    class << self
      def wrap(text, width: 80, indent: nil, first_indent: nil)
        indent ||= ''
        first_indent ||= indent
        paragraphs = text.split("\n")

        wrapped_paragraphs = paragraphs.map do |paragraph|
          wrap_paragraph(paragraph, width: width, indent: indent, first_indent: first_indent)
        end

        wrapped_paragraphs.join("\n")
      end

      def truncate(text, width: 80, omission: '...')
        return text if visible_width(text) <= width

        omission_width = visible_width(omission)
        available = width - omission_width
        return omission if available <= 0

        truncate_at_word_boundary(text, available) + omission
      end

      def visible_width(text)
        text.gsub(ANSI_PATTERN, '').length
      end

      private

      def wrap_paragraph(paragraph, width:, indent:, first_indent:)
        words = split_preserving_ansi(paragraph)
        return first_indent if words.empty?

        lines = []
        current_line = +''
        current_width = 0
        first_line = true

        words.each do |word|
          word_width = visible_width(word)
          line_indent = first_line ? first_indent : indent
          indent_width = visible_width(line_indent)
          max_content_width = width - indent_width

          if current_line.empty?
            if word_width <= max_content_width
              current_line << word
              current_width = word_width
            else
              hard_wrapped = hard_wrap_word(word, max_content_width)
              hard_wrapped.each_with_index do |chunk, i|
                if i < hard_wrapped.length - 1
                  lines << "#{line_indent}#{chunk}"
                  first_line = false
                  line_indent = indent
                  indent_width = visible_width(indent)
                  max_content_width = width - indent_width
                else
                  current_line << chunk
                  current_width = visible_width(chunk)
                end
              end
            end
          elsif current_width + 1 + word_width <= max_content_width
            current_line << ' ' << word
            current_width += 1 + word_width
          else
            lines << "#{line_indent}#{current_line}"
            first_line = false
            line_indent = indent
            indent_width = visible_width(indent)
            max_content_width = width - indent_width

            if word_width <= max_content_width
              current_line = +word
              current_width = word_width
            else
              current_line = +''
              current_width = 0
              hard_wrapped = hard_wrap_word(word, max_content_width)
              hard_wrapped.each_with_index do |chunk, i|
                if i < hard_wrapped.length - 1
                  lines << "#{line_indent}#{chunk}"
                else
                  current_line << chunk
                  current_width = visible_width(chunk)
                end
              end
            end
          end
        end

        line_indent = first_line ? first_indent : indent
        lines << "#{line_indent}#{current_line}" unless current_line.empty?

        lines.join("\n")
      end

      def split_preserving_ansi(text)
        tokens = text.split(/(\e\[[0-9;]*m|\s+)/)
        words = []
        current_word = +''

        tokens.each do |token|
          if token.match?(/\A\s+\z/)
            words << current_word unless current_word.empty?
            current_word = +''
          elsif token.match?(ANSI_PATTERN)
            current_word << token
          else
            current_word << token
          end
        end

        words << current_word unless current_word.empty?
        words
      end

      def hard_wrap_word(word, max_width)
        return [word] if max_width <= 0

        chunks = []
        remaining = +word
        ansi_state = +''

        while visible_width(remaining) > max_width
          chunk, remaining = split_at_visible(remaining, max_width)
          chunks << chunk
          ansi_state = extract_active_ansi(chunk)
          remaining = "#{ansi_state}#{remaining}" unless ansi_state.empty?
        end

        chunks << remaining unless remaining.empty?
        chunks
      end

      def split_at_visible(text, width)
        visible_count = 0
        byte_pos = 0

        while byte_pos < text.length && visible_count < width
          if text[byte_pos..].match?(/\A\e\[[0-9;]*m/)
            match = text[byte_pos..].match(/\A\e\[[0-9;]*m/)[0]
            byte_pos += match.length
          else
            byte_pos += 1
            visible_count += 1
          end
        end

        [text[0...byte_pos], text[byte_pos..]]
      end

      def extract_active_ansi(text)
        codes = text.scan(ANSI_PATTERN)
        return '' if codes.empty?
        return '' if codes.last == "\e[0m"

        codes.last
      end

      def truncate_at_word_boundary(text, available)
        words = split_preserving_ansi(text)
        result = +''
        result_width = 0

        words.each do |word|
          word_width = visible_width(word)
          new_width = result.empty? ? word_width : result_width + 1 + word_width

          break if new_width > available

          result << ' ' unless result.empty?
          result << word
          result_width = new_width
        end

        return text[0...available] if result.empty?

        result
      end
    end
  end
end
