#!/usr/bin/env bash

# Install script for Spec-Kit Claude Code Skills
# Designed to easily distribute and install these skills globally or locally.

set -e

# Styling helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "    ███████╗██████╗ ███████╗ ██████╗██╗  ██╗██╗████████╗"
echo "    ██╔════╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝"
echo "    ███████╗██████╔╝█████╗  ██║     █████╔╝ ██║   ██║   "
echo "    ╚════██║██╔═══╝ ██╔══╝  ██║     ██╔═██╗ ██║   ██║   "
echo "    ███████║██║     ███████╗╚██████╗██║  ██╗██║   ██║   "
echo "    ╚══════╝╚═╝     ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝   "
echo -e "           Claude Code Skill Installer Suite${NC}\n"

# Helper to print usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --global, -g    Install skills globally to ~/.claude/skills/"
    echo "  --local, -l     Install skills locally to ./.claude/skills/"
    echo "  --type, -t      Skill type to install: 'unified' (default), 'granular', or 'both'"
    echo "  --help, -h      Show this help message"
    exit 0
}

# Parse options
INSTALL_DEST=""
SKILL_TYPE="unified"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --global|-g)
            INSTALL_DEST="global"
            ;;
        --local|-l)
            INSTALL_DEST="local"
            ;;
        --type|-t)
            SKILL_TYPE="$2"
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
    shift
done

# Resolve source directory of skills
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/.claude/skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
    echo -e "${RED}Error: Source skills directory not found at $SOURCE_SKILLS_DIR${NC}"
    exit 1
fi

# Ask if not provided
if [[ -z "$INSTALL_DEST" ]]; then
    echo -e "${YELLOW}Where would you like to install the skills?${NC}"
    select dest in "Globally (~/.claude/skills/)" "Locally (./.claude/skills/)" "Cancel"; do
        case $dest in
            "Globally (~/.claude/skills/)")
                INSTALL_DEST="global"
                break
                ;;
            "Locally (./.claude/skills/)")
                INSTALL_DEST="local"
                break
                ;;
            *)
                echo "Installation cancelled."
                exit 0
                ;;
        esac
    done
fi

# Define target path
if [[ "$INSTALL_DEST" == "global" ]]; then
    TARGET_DIR="$HOME/.claude/skills"
else
    TARGET_DIR="$(pwd)/.claude/skills"
fi

# Resolve absolute paths for comparison
SOURCE_DIR_ABS="$(cd "$SOURCE_SKILLS_DIR" && pwd)"
mkdir -p "$TARGET_DIR"
TARGET_DIR_ABS="$(cd "$TARGET_DIR" && pwd)"

# Perform copies
install_unified() {
    if [[ "$SOURCE_DIR_ABS" == "$TARGET_DIR_ABS" ]]; then
        echo -e "${YELLOW}Unified skill is already in source directory. Skipping copy.${NC}"
        return
    fi
    echo -e "${BLUE}Installing Unified Master Skill (/speckit)...${NC}"
    mkdir -p "$TARGET_DIR/speckit"
    cp "$SOURCE_SKILLS_DIR/speckit/SKILL.md" "$TARGET_DIR/speckit/SKILL.md"
    echo -e "${GREEN}✓ Unified skill installed at: $TARGET_DIR/speckit/SKILL.md${NC}"
}

install_granular() {
    if [[ "$SOURCE_DIR_ABS" == "$TARGET_DIR_ABS" ]]; then
        echo -e "${YELLOW}Granular skills are already in source directory. Skipping copy.${NC}"
        return
    fi
    echo -e "${BLUE}Installing Granular Skills (speckit-*)...${NC}"
    for skill_path in "$SOURCE_SKILLS_DIR"/speckit-*; do
        if [[ -d "$skill_path" ]]; then
            skill_name=$(basename "$skill_path")
            mkdir -p "$TARGET_DIR/$skill_name"
            cp "$skill_path/SKILL.md" "$TARGET_DIR/$skill_name/SKILL.md"
            echo -e "${GREEN}✓ Granular skill installed: /$skill_name${NC}"
        fi
    done
}

# Install default templates for local projects
setup_local_templates() {
    if [[ "$INSTALL_DEST" == "local" ]]; then
        local target_project_root="$(pwd)"
        local source_templates_dir="$SCRIPT_DIR/.specify"
        
        # Avoid copying to itself
        if [[ "$(cd "$source_templates_dir" && pwd)" == "$(cd "$target_project_root" 2>/dev/null && pwd)/.specify" ]]; then
            return
        fi
        
        if [[ ! -d "$target_project_root/.specify" ]]; then
            echo -e "${BLUE}Initializing .specify/ configuration folder in target project...${NC}"
            cp -r "$source_templates_dir" "$target_project_root/.specify"
            echo -e "${GREEN}✓ Default templates and configurations set up in .specify/${NC}"
        fi
    fi
}

# Run install based on type
if [[ "$SKILL_TYPE" == "unified" ]]; then
    install_unified
    setup_local_templates
elif [[ "$SKILL_TYPE" == "granular" ]]; then
    install_granular
    setup_local_templates
elif [[ "$SKILL_TYPE" == "both" ]]; then
    install_unified
    install_granular
    setup_local_templates
else
    echo -e "${RED}Invalid skill type: $SKILL_TYPE. Choose 'unified', 'granular', or 'both'.${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Successfully installed Claude Code skills!${NC}"
echo -e "You can now run Claude Code in a project directory and start using them."
if [[ "$SKILL_TYPE" == "unified" || "$SKILL_TYPE" == "both" ]]; then
    echo -e "Try typing: ${CYAN}/speckit specify 'description'${NC} in Claude Code."
fi
if [[ "$SKILL_TYPE" == "granular" || "$SKILL_TYPE" == "both" ]]; then
    echo -e "Try typing: ${CYAN}/speckit-specify 'description'${NC} in Claude Code."
fi
