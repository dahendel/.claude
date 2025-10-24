#!/bin/bash
# Claude Skill Creator
# Embedded documentation scraper for creating Claude skills
# Creates Claude skills from documentation URLs

set -e

CLAUDE_DIR="$HOME/.claude"
DOC_SCRAPER="$CLAUDE_DIR/bin/doc_scraper.py"
VENV_DIR="$CLAUDE_DIR/venv-skill-create"
CONFIGS_DIR="$CLAUDE_DIR/skill-configs"
OUTPUT_DIR="$CLAUDE_DIR/skill-output"
CLAUDE_SKILLS_DIR="$CLAUDE_DIR/skills"
REQUIREMENTS_FILE="$CLAUDE_DIR/requirements-skill-create.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     Claude Skill Creator                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_dependencies() {
    # Check if doc_scraper exists
    if [ ! -f "$DOC_SCRAPER" ]; then
        echo -e "${RED}✗ doc_scraper.py not found at $DOC_SCRAPER${NC}"
        echo ""
        echo "The skill-create Python script is missing."
        echo "Reinstall ~/.claude or contact support."
        exit 1
    fi

    # Check if Python 3 is available
    if ! command -v python3 >/dev/null 2>&1; then
        echo -e "${RED}✗ Python 3 is required but not installed${NC}"
        exit 1
    fi

    # Create directories
    mkdir -p "$CONFIGS_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$CLAUDE_SKILLS_DIR"

    # Check if venv exists
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${YELLOW}⚠ Virtual environment not found${NC}"
        echo ""
        echo "Creating virtual environment..."
        python3 -m venv "$VENV_DIR"

        echo "Installing dependencies..."
        source "$VENV_DIR/bin/activate"
        pip install --quiet --upgrade pip
        pip install --quiet -r "$REQUIREMENTS_FILE"

        echo -e "${GREEN}✓ Virtual environment created${NC}"
        echo ""
    fi
}

create_config() {
    local name="$1"
    local url="$2"
    local config_file="$CONFIGS_DIR/${name}.json"

    # Create configs directory if it doesn't exist
    mkdir -p "$CONFIGS_DIR"

    # Create config
    cat > "$config_file" << EOF
{
  "name": "${name}",
  "base_url": "${url}",
  "start_urls": ["${url}"],
  "url_patterns": {
    "include": [],
    "exclude": [
      "/api/",
      "/blog/",
      "/changelog/"
    ]
  },
  "content_selectors": {
    "main": ["main", "article", ".content", ".documentation"],
    "title": ["h1", "title"],
    "remove": [".navigation", ".sidebar", "nav", "footer", "header"]
  },
  "checkpoint": {
    "enabled": true,
    "interval": 100
  },
  "limits": {
    "max_pages": 500,
    "max_depth": 10
  }
}
EOF

    echo "$config_file"
}

create_skill() {
    local name="$1"
    local url="$2"
    local use_browser="${3:-false}"

    print_header

    if [ -z "$name" ] || [ -z "$url" ]; then
        echo -e "${RED}✗ Missing required arguments${NC}"
        echo ""
        echo "Usage: skill-create <name> <url> [--use-browser]"
        echo ""
        echo "Example:"
        echo "  skill-create react https://react.dev/"
        echo "  skill-create golang https://go.dev/doc/effective_go --use-browser"
        exit 1
    fi

    check_dependencies

    echo -e "${BLUE}Creating skill: ${name}${NC}"
    echo -e "${BLUE}Documentation URL: ${url}${NC}"
    if [ "$use_browser" = "true" ]; then
        echo -e "${BLUE}Mode: Browser (JavaScript support)${NC}"
    else
        echo -e "${BLUE}Mode: Static (Fast)${NC}"
    fi
    echo ""

    # Create config
    echo -e "${BLUE}Creating configuration...${NC}"
    config_file=$(create_config "$name" "$url")
    echo -e "${GREEN}✓ Config created: ${config_file}${NC}"
    echo ""

    # Activate venv
    source "$VENV_DIR/bin/activate"

    # Run doc_scraper
    echo -e "${BLUE}Scraping documentation...${NC}"
    echo -e "${YELLOW}This may take a while depending on the site size...${NC}"
    echo ""

    local scraper_args="--config $config_file"
    if [ "$use_browser" = "true" ]; then
        scraper_args="$scraper_args --use-browser"
    fi

    if python3 "$DOC_SCRAPER" $scraper_args; then
        echo ""
        echo -e "${GREEN}✓ Skill created successfully!${NC}"
        echo ""

        # Copy to claude skills directory
        if [ -d "$OUTPUT_DIR/${name}" ]; then
            echo -e "${BLUE}Installing to Claude...${NC}"
            mkdir -p "$CLAUDE_SKILLS_DIR"
            cp -r "$OUTPUT_DIR/${name}" "$CLAUDE_SKILLS_DIR/"
            echo -e "${GREEN}✓ Skill installed to: ${CLAUDE_SKILLS_DIR}/${name}/${NC}"
            echo ""

            # Show usage
            echo -e "${BLUE}Usage:${NC}"
            echo -e "  Add to Claude Desktop config:"
            echo -e "  ${YELLOW}~/.config/Claude/claude_desktop_config.json${NC}"
            echo ""
            echo -e "  Or use the skill directly in conversations:"
            echo -e "  ${YELLOW}/${name}${NC}"
        fi
    else
        echo ""
        echo -e "${RED}✗ Skill creation failed${NC}"
        echo ""
        echo "Check logs in: $OUTPUT_DIR/${name}_data/"
        exit 1
    fi
}

list_skills() {
    print_header
    echo -e "${BLUE}Available Skills:${NC}"
    echo ""

    if [ -d "$OUTPUT_DIR" ]; then
        local count=0
        for skill_dir in "$OUTPUT_DIR"/*/ ; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                # Skip _data directories
                if [[ ! "$skill_name" =~ _data$ ]]; then
                    echo -e "  ${GREEN}✓${NC} $skill_name"
                    ((count++))
                fi
            fi
        done

        if [ $count -eq 0 ]; then
            echo -e "  ${YELLOW}No skills found${NC}"
        else
            echo ""
            echo -e "${BLUE}Total: ${count} skills${NC}"
        fi
    else
        echo -e "  ${YELLOW}No skills found${NC}"
    fi

    echo ""
    echo -e "${BLUE}Installed in Claude:${NC}"
    echo ""

    if [ -d "$CLAUDE_SKILLS_DIR" ]; then
        local count=0
        for skill_dir in "$CLAUDE_SKILLS_DIR"/*/ ; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                echo -e "  ${GREEN}✓${NC} $skill_name"
                ((count++))
            fi
        done

        if [ $count -eq 0 ]; then
            echo -e "  ${YELLOW}No skills installed${NC}"
        fi
    else
        echo -e "  ${YELLOW}Skills directory not found${NC}"
    fi
}

install_skill() {
    local name="$1"

    if [ -z "$name" ]; then
        echo -e "${RED}✗ Skill name required${NC}"
        echo "Usage: skill-create install <name>"
        exit 1
    fi

    if [ ! -d "$OUTPUT_DIR/${name}" ]; then
        echo -e "${RED}✗ Skill not found: ${name}${NC}"
        echo ""
        echo "Available skills:"
        list_skills
        exit 1
    fi

    mkdir -p "$CLAUDE_SKILLS_DIR"
    cp -r "$OUTPUT_DIR/${name}" "$CLAUDE_SKILLS_DIR/"
    echo -e "${GREEN}✓ Skill installed: ${name}${NC}"
}

case "${1:-help}" in
    create)
        # Check if --use-browser flag is present
        use_browser="false"
        if [ "$4" = "--use-browser" ] || [ "$3" = "--use-browser" ]; then
            use_browser="true"
        fi
        create_skill "$2" "$3" "$use_browser"
        ;;

    list)
        list_skills
        ;;

    install)
        install_skill "$2"
        ;;

    help|--help|-h)
        print_header
        echo "Create Claude skills from documentation URLs"
        echo ""
        echo "Usage:"
        echo "  skill-create create <name> <url> [--use-browser]    Create new skill"
        echo "  skill-create list                                   List available skills"
        echo "  skill-create install <name>                         Install skill to Claude"
        echo "  skill-create help                                   Show this help"
        echo ""
        echo "Options:"
        echo "  --use-browser    Enable browser automation for JavaScript-heavy sites"
        echo "                   (Requires: pip install playwright && playwright install chromium)"
        echo ""
        echo "Examples:"
        echo "  # Static site (fast)"
        echo "  skill-create create react https://react.dev/"
        echo ""
        echo "  # JavaScript-heavy site (slower but handles dynamic content)"
        echo "  skill-create create golang https://go.dev/doc/effective_go --use-browser"
        echo ""
        echo "  # More examples"
        echo "  skill-create create tailwind https://tailwindcss.com/docs"
        echo "  skill-create create vue https://vuejs.org/guide/"
        echo ""
        echo "Output:"
        echo "  Skills: ~/.claude/skill-output/<name>/"
        echo "  Claude: ~/.claude/skills/<name>/"
        ;;

    *)
        # Default: create skill with name and url
        if [ -n "$1" ] && [ -n "$2" ]; then
            use_browser="false"
            if [ "$3" = "--use-browser" ]; then
                use_browser="true"
            fi
            create_skill "$1" "$2" "$use_browser"
        else
            echo -e "${RED}✗ Invalid command${NC}"
            echo "Run 'skill-create help' for usage"
            exit 1
        fi
        ;;
esac
