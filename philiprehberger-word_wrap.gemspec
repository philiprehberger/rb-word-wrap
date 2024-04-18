# frozen_string_literal: true

require_relative 'lib/philiprehberger/word_wrap/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-word_wrap'
  spec.version = Philiprehberger::WordWrap::VERSION
  spec.authors = ['philiprehberger']
  spec.email = ['philiprehberger@users.noreply.github.com']

  spec.summary = 'Text wrapping with word-boundary awareness, indentation, and ANSI escape code support'
  spec.description = 'Wrap text to a specific width at word boundaries. Supports indentation, ' \
                     'hanging indent, ANSI escape code-safe width calculation, and truncation ' \
                     'with configurable omission strings.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-word_wrap'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-word-wrap'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-word-wrap/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-word-wrap/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
