# Documentation Scraper - JavaScript Support

## Overview

The documentation scraper now supports JavaScript-heavy sites using Playwright browser automation.

## Features

- **Static Sites:** Fast scraping with `requests` + `BeautifulSoup`
- **JavaScript Sites:** Browser automation with Playwright for dynamic content
- **Auto-fallback:** Gracefully falls back to requests if Playwright unavailable
- **Rate limiting:** Configurable delays between requests
- **Checkpointing:** Resume interrupted scrapes

## Installation

### Basic (Static Sites Only)
```bash
pip install requests beautifulsoup4
```

### With JavaScript Support
```bash
pip install requests beautifulsoup4 playwright
playwright install chromium
```

## Usage

### For Static Sites (Default - Faster)
```bash
python3 doc_scraper.py --name react --url https://react.dev/
```

### For JavaScript-Heavy Sites
```bash
python3 doc_scraper.py --name golang --url https://go.dev/doc/effective_go --use-browser
```

### Via Configuration File
```json
{
  "name": "golang",
  "base_url": "https://go.dev/doc/",
  "use_browser": true,
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "rate_limit": 1.0,
  "max_pages": 100
}
```

```bash
python3 doc_scraper.py --config configs/golang.json
```

## Command-Line Options

```
--use-browser          Enable browser automation for JavaScript sites
--name NAME            Skill name
--url URL              Base documentation URL
--config FILE          Load configuration from JSON file
--dry-run              Preview what will be scraped
--skip-scrape          Use existing data
--resume               Resume from checkpoint
--fresh                Clear checkpoint and start fresh
--interactive          Interactive configuration mode
```

## When to Use Browser Mode

Use `--use-browser` for sites that:
- Require JavaScript to render content
- Use client-side routing (React, Vue, etc.)
- Have dynamically loaded documentation
- Show "Loading..." or blank content without JavaScript

Examples:
- go.dev (Go documentation)
- Modern React/Vue documentation sites
- Single-page applications

## Performance

- **Static mode:** ~0.5-2 seconds per page
- **Browser mode:** ~2-5 seconds per page

## Troubleshooting

### "Playwright not installed"
```bash
pip install playwright
playwright install chromium
```

### "No content retrieved"
Try with `--use-browser` flag

### Timeout errors
Increase rate limit in config:
```json
{
  "rate_limit": 2.0
}
```

## Examples

### Create Go Skill with Browser Mode
```bash
python3 doc_scraper.py \
  --name go-effective \
  --url https://go.dev/doc/effective_go \
  --use-browser \
  --max-pages 50
```

### Create React Skill (Static)
```bash
python3 doc_scraper.py \
  --name react \
  --url https://react.dev/reference/react \
  --max-pages 100
```

### Dry Run to Preview
```bash
python3 doc_scraper.py \
  --name test \
  --url https://example.com/docs/ \
  --use-browser \
  --dry-run
```

## Configuration File Format

```json
{
  "name": "example",
  "description": "Example skill",
  "base_url": "https://example.com/docs/",
  "use_browser": false,
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "url_patterns": {
    "include": ["/docs/", "/guide/"],
    "exclude": ["/blog/", "/404"]
  },
  "categories": {
    "getting_started": ["intro", "quickstart", "tutorial"],
    "api": ["api", "reference", "class"]
  },
  "rate_limit": 0.5,
  "max_pages": 500,
  "checkpoint": {
    "enabled": true,
    "interval": 100
  }
}
```

## Output

Scraped skills are saved to:
```
output/
├── {name}_data/         # Raw scraped data
│   ├── pages/           # Individual page JSON files
│   └── summary.json     # Scrape summary
└── {name}/              # Generated skill
    ├── SKILL.md         # Main skill file
    ├── references/      # Documentation by category
    ├── scripts/         # Helper scripts
    └── assets/          # Templates/examples
```

## Tips

1. **Start with dry-run:** Preview scraping behavior
2. **Use checkpoints:** Enable for large scrapes
3. **Tune selectors:** Inspect site HTML to optimize
4. **Rate limiting:** Be respectful to documentation sites
5. **Browser mode trade-off:** Slower but handles JavaScript

## Integration with claude-env

```bash
# After scraping
claude-env skill-install ~/.claude/bin/output/{name}
```
