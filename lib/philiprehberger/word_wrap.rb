# frozen_string_literal: true

require_relative 'word_wrap/version'

module Philiprehberger
  module WordWrap
    ANSI_PATTERN = /\e\[[0-9;]*m/

    class << self
      def wrap(text, width: 80, indent: nil, first_indent: nil, justify: false)
        indent ||= ''
        first_indent ||= indent
        paragraphs = text.split("\n")

        wrapped_paragraphs = paragraphs.map do |paragraph|
          wrap_paragraph(paragraph, width: width, indent: indent, first_indent: first_indent)
        end

        result = wrapped_paragraphs.join("\n")
        justify ? justify_text(result, width) : result
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

      # Center text within a given width
      #
      # @param text [String] the text to center
      # @param width [Integer] the total width
      # @return [String] centered text
      def center(text, width: 80)
        text.split("\n").map do |line|
          vis_width = visible_width(line.strip)
          padding = [(width - vis_width) / 2, 0].max
          "#{' ' * padding}#{line.strip}"
        end.join("\n")
      end

      # Format multiple strings into parallel columns
      #
      # @param texts [Array<String>] array of text strings, one per column
      # @param widths [Array<Integer>] width of each column
      # @param separator [String] separator between columns
      # @return [String] multi-column formatted text
      def columns(texts, widths:, separator: '  ')
        wrapped = texts.each_with_index.map do |text, i|
          wrap(text, width: widths[i]).split("\n")
        end

        max_lines = wrapped.map(&:length).max || 0

        (0...max_lines).map do |line_idx|
          wrapped.each_with_index.map do |col_lines, col_idx|
            line = col_lines[line_idx] || ''
            pad_width = widths[col_idx]
            vis = visible_width(line)
            line + (' ' * [(pad_width - vis), 0].max)
          end.join(separator)
        end.join("\n")
      end

      # Wrap text with a hanging indent where the first line is flush left
      # and subsequent lines are indented
      #
      # @param text [String] the text to wrap
      # @param width [Integer] the total line width
      # @param indent [Integer] number of spaces to indent subsequent lines
      # @return [String] wrapped text with hanging indent
      def hanging_indent(text, width, indent:)
        indent_str = ' ' * indent
        wrap(text, width: width, first_indent: '', indent: indent_str)
      end

      # Wrap text to width, then truncate to at most height lines
      #
      # @param text [String] the text to wrap and fit
      # @param width [Integer] the line width
      # @param height [Integer] the maximum number of lines
      # @param omission [String] string to append when truncated
      # @return [String] wrapped and height-truncated text
      def fit(text, width:, height:, omission: '...')
        wrapped = wrap(text, width: width)
        lines = wrapped.split("\n")

        return wrapped if lines.length <= height

        truncated_lines = lines[0...height]
        last_line = truncated_lines.last
        omission_width = visible_width(omission)
        available = width - omission_width

        truncated_lines[-1] = if available <= 0
                                omission[0...width]
                              elsif visible_width(last_line) > available
                                truncate_at_word_boundary(last_line, available) + omission
                              else
                                "#{last_line}#{omission}"
                              end

        truncated_lines.join("\n")
      end

      # Split on double newlines, wrap each paragraph independently,
      # and rejoin with spacing blank lines
      #
      # @param text [String] the text containing paragraphs
      # @param width [Integer] the line width
      # @param spacing [Integer] number of blank lines between paragraphs
      # @return [String] wrapped paragraphs joined with spacing
      def paragraphs(text, width, spacing: 1)
        parts = text.split(/\n{2,}/)
        wrapped_parts = parts.map { |para| wrap(para.strip, width: width) }
        separator = "\n#{"\n" * spacing}"
        wrapped_parts.join(separator)
      end

      # Remove single newlines within paragraphs (rejoin soft-wrapped text)
      # while preserving paragraph boundaries (double newlines)
      #
      # @param text [String] the soft-wrapped text
      # @return [String] unwrapped text with paragraph boundaries preserved
      def unwrap(text)
        paragraphs = text.split(/\n{2,}/)
        paragraphs.map { |para| para.gsub("\n", ' ').squeeze(' ').strip }.join("\n\n")
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

      def justify_text(text, width)
        lines = text.split("\n")
        return text if lines.length <= 1

        lines[0..-2].map { |line| justify_line(line, width) }.append(lines.last).join("\n")
      end

      def justify_line(line, width)
        stripped = line.lstrip
        leading = line.length - stripped.length
        indent_str = ' ' * leading
        words = stripped.split(/\s+/)

        return line if words.length <= 1

        target = width - leading
        total_word_width = words.sum { |w| visible_width(w) }
        total_spaces = target - total_word_width
        return line if total_spaces <= 0

        gaps = words.length - 1
        base_space = total_spaces / gaps
        extra = total_spaces % gaps

        result = +indent_str
        words.each_with_index do |word, i|
          result << word
          if i < gaps
            spaces = base_space + (i < extra ? 1 : 0)
            result << (' ' * spaces)
          end
        end
        result
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
