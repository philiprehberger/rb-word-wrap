# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.5] - 2026-03-24

### Fixed
- Standardize README API section to table format

## [0.1.4] - 2026-03-23

### Fixed
- Standardize README to match template (installation order, code fences, license section, one-liner format)
- Update gemspec summary to match README description

## [0.1.3] - 2026-03-22

### Changed
- Fix README badges to match template (Tests, Gem Version, License)

## [0.1.2] - 2026-03-22

### Added
- Expanded test suite from 16 to 30+ examples covering empty strings, exact width boundaries, paragraph preservation, unicode, indent edge cases, and truncation boundary conditions

## [0.1.0] - 2026-03-22

### Added

- `WordWrap.wrap` with word-boundary-aware text wrapping
- `WordWrap.truncate` to truncate text at word boundaries with omission string
- Configurable line width, indentation, and hanging indent
- ANSI escape code-safe width calculation
- Hard wrap for words exceeding line width

[0.1.0]: https://github.com/philiprehberger/rb-word-wrap/releases/tag/v0.1.0
