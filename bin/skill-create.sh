#!/bin/bash
# Claude Skill Creator
# Wrapper for Skill_Seekers doc_scraper.py
# Creates Claude skills from documentation URLs

set -e

SKILL_SEEKERS_DIR="$HOME/Skill_Seekers"
DOC_SCRAPER="$SKILL_SEEKERS_DIR/cli/doc_scraper.py"
VENV_DIR="$SKILL_SEEKERS_DIR/venv"
CONFIGS_DIR="$SKILL_SEEKERS_DIR/configs"
OUTPUT_DIR="$SKILL_SEEKERS_DIR/output"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

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
    # Check if Skill_Seekers exists
    if [ ! -d "$SKILL_SEEKERS_DIR" ]; then
        echo -e "${RED}✗ Skill_Seekers not found at $SKILL_SEEKERS_DIR${NC}"
        echo ""
        echo "Clone Skill_Seekers:"
        echo "  git clone https://github.com/USER/Skill_Seekers.git ~/Skill_Seekers"
        echo "  cd ~/Skill_Seekers"
        echo "  python3 -m venv venv"
        echo "  source venv/bin/activate"
        echo "  pip install -r requirements.txt"
        exit 1
    fi

    # Check if venv exists
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${YELLOW}⚠ Virtual environment not found${NC}"
        echo ""
        echo "Creating virtual environment..."
        cd "$SKILL_SEEKERS_DIR"
        python3 -m venv venv
        source venv/bin/activate

        if [ -f "requirements.txt" ]; then
            echo "Installing dependencies..."
            pip install -r requirements.txt
        fi

        echo -e "${GREEN}✓ Virtual environment created${NC}"
    fi

    # Check if doc_scraper exists
    if [ ! -f "$DOC_SCRAPER" ]; then
        echo -e "${RED}✗ doc_scraper.py not found${NC}"
        exit 1
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
    local interactive="${3:-false}"

    print_header

    if [ -z "$name" ] || [ -z "$url" ]; then
        echo -e "${RED}✗ Missing required arguments${NC}"
        echo ""
        echo "Usage: skill-create <name> <url>"
        echo ""
        echo "Example:"
        echo "  skill-create react https://react.dev/"
        echo "  skill-create tailwind https://tailwindcss.com/docs"
        exit 1
    fi

    check_dependencies

    echo -e "${BLUE}Creating skill: ${name}${NC}"
    echo -e "${BLUE}Documentation URL: ${url}${NC}"
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

    cd "$SKILL_SEEKERS_DIR"

    if python3 "$DOC_SCRAPER" --config "$config_file"; then
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
        create_skill "$2" "$3"
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
        echo "  skill-create create <name> <url>    Create new skill"
        echo "  skill-create list                   List available skills"
        echo "  skill-create install <name>         Install skill to Claude"
        echo "  skill-create help                   Show this help"
        echo ""
        echo "Examples:"
        echo "  skill-create create react https://react.dev/"
        echo "  skill-create create tailwind https://tailwindcss.com/docs"
        echo "  skill-create create vue https://vuejs.org/guide/"
        echo ""
        echo "Output:"
        echo "  Skills: ~/Skill_Seekers/output/<name>/"
        echo "  Claude: ~/.claude/skills/<name>/"
        ;;

    *)
        # Default: create skill with name and url
        if [ -n "$1" ] && [ -n "$2" ]; then
            create_skill "$1" "$2"
        else
            echo -e "${RED}✗ Invalid command${NC}"
            echo "Run 'skill-create help' for usage"
            exit 1
        fi
        ;;
esac
