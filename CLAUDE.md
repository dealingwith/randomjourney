# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Ruby-based web scraping project for randomly selecting and checking links from a personal website archive. The project consists of several utility scripts that work with the daniel.industries website to extract, track, and validate links.

## Ruby Environment

- Ruby version: 3.2.2 (specified in `.ruby-version`)
- Dependencies managed via Bundler (see `Gemfile`)

## Common Commands

```bash
# Install dependencies
bundle install

# Run the main random journey script (random selection)
ruby randomjourney.rb

# Run with a specific URL fragment
ruby randomjourney.rb /path/to/specific/page

# Check links in a file
ruby link_check.rb -f filename.html

# Check links from a URL
ruby link_check.rb -u http://example.com

# Scrape links from a URL
ruby link_scraper.rb http://example.com

# Generate titles CSV from archives
ruby gen_title_csv.rb
```

## Core Scripts

### randomjourney.rb
The main script that:
- Scrapes a random archive link from daniel.industries/archives (or uses a specified URL fragment)
- Tracks used links in `links.txt` to avoid duplicates
- Validates all links on the selected page using ruby-link-checker
- Outputs link validation results by category (success, error, failure)
- Accepts optional URL fragment as first argument to check a specific page instead of random selection

### link_check.rb
A configurable link checker that:
- Accepts either a file (`-f`) or URL (`-u`) as input
- Parses HTML content to extract links
- Validates HTTP links and reports broken ones
- Uses Typhoeus for concurrent link checking

### link_scraper.rb
Simple utility to extract all links from a given URL using Mechanize.

### gen_title_csv.rb
Extracts titles from archive links and saves them to `titles.csv`.

## Architecture

The project uses a simple file-based approach:
- `links.txt`: Tracks previously selected links to prevent repeats
- `titles.csv`: Stores extracted link titles
- All scripts are standalone Ruby files with minimal shared state

## Key Dependencies

- **mechanize**: Web scraping and HTML parsing
- **typhoeus**: High-performance HTTP requests with concurrent processing
- **ruby-link-checker**: Link validation using Typhoeus::Hydra for parallel checking
- **nokogiri**: HTML/XML parsing
- **amazing_print**: Pretty printing for debugging