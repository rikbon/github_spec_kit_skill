#!/usr/bin/env bash

# Install script for Spec-Kit Agent Skills
# Designed to easily distribute and install these skills globally or locally across multiple agents.

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
echo -e "              Multi-Agent Skill Installer Suite${NC}\n"

# Helper to print usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --global, -g    Install skills globally to the user's home directory config"
    echo "  --local, -l     Install skills locally to the current workspace"
    echo "  --type, -t      Skill type to install: 'unified' (default), 'granular', or 'both'"
    echo "  --agent, -a     Target agent: 'claude' (default), 'antigravity' (or 'agy'), 'codex', 'opencode', 'pi', or 'all'"
    echo "  --help, -h      Show this help message"
    exit 0
}

# Parse options
INSTALL_DEST=""
SKILL_TYPE="unified"
SKILL_TYPE_SPECIFIED="false"
TARGET_AGENT="claude"
TARGET_AGENT_SPECIFIED="false"

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
            SKILL_TYPE_SPECIFIED="true"
            shift
            ;;
        --agent|-a)
            TARGET_AGENT="$2"
            TARGET_AGENT_SPECIFIED="true"
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

# Ask destination if not provided
if [[ -z "$INSTALL_DEST" ]]; then
    echo -e "${YELLOW}Where would you like to install the skills?${NC}"
    select dest in "Globally (user home directory)" "Locally (current repository)" "Cancel"; do
        case $dest in
            "Globally (user home directory)")
                INSTALL_DEST="global"
                break
                ;;
            "Locally (current repository)")
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

# Ask target agent if not specified
if [[ "$TARGET_AGENT_SPECIFIED" == "false" ]]; then
    echo -e "${YELLOW}Which agent(s) would you like to install the skills for?${NC}"
    select agent_opt in "Claude Code" "Google Antigravity / Agy" "OpenAI Codex" "OpenCode" "Pi / General Agent (.agents)" "All Agents" "Cancel"; do
        case $agent_opt in
            "Claude Code")
                TARGET_AGENT="claude"
                break
                ;;
            "Google Antigravity / Agy")
                TARGET_AGENT="antigravity"
                break
                ;;
            "OpenAI Codex")
                TARGET_AGENT="codex"
                break
                ;;
            "OpenCode")
                TARGET_AGENT="opencode"
                break
                ;;
            "Pi / General Agent (.agents)")
                TARGET_AGENT="pi"
                break
                ;;
            "All Agents")
                TARGET_AGENT="all"
                break
                ;;
            *)
                echo "Installation cancelled."
                exit 0
                ;;
        esac
    done
fi

# Ask skill layout type if not specified
if [[ "$SKILL_TYPE_SPECIFIED" == "false" ]]; then
    echo -e "${YELLOW}Which skill layout would you like to install?${NC}"
    select type_opt in "Unified (/speckit master command)" "Granular (/speckit-* individual commands)" "Both" "Cancel"; do
        case $type_opt in
            "Unified (/speckit master command)")
                SKILL_TYPE="unified"
                break
                ;;
            "Granular (/speckit-* individual commands)")
                SKILL_TYPE="granular"
                break
                ;;
            "Both")
                SKILL_TYPE="both"
                break
                ;;
            *)
                echo "Installation cancelled."
                exit 0
                ;;
        esac
    done
fi

# Helper to get target directories for a given agent
get_target_dirs() {
    local agent="$1"
    local dest="$2"
    
    case "$agent" in
        claude)
            if [[ "$dest" == "global" ]]; then
                echo "$HOME/.claude/skills"
            else
                echo "$(pwd)/.claude/skills"
            fi
            ;;
        antigravity|agy)
            if [[ "$dest" == "global" ]]; then
                echo "$HOME/.gemini/config/skills"
            else
                echo "$(pwd)/.agents/skills"
            fi
            ;;
        codex)
            if [[ "$dest" == "global" ]]; then
                echo "$HOME/.agents/skills"
            else
                echo "$(pwd)/.agents/skills"
            fi
            ;;
        opencode)
            if [[ "$dest" == "global" ]]; then
                echo "$HOME/.config/opencode/skills"
            else
                echo "$(pwd)/.opencode/skills"
            fi
            ;;
        pi|general)
            if [[ "$dest" == "global" ]]; then
                echo "$HOME/.agents/skills"
            else
                echo "$(pwd)/.agents/skills"
            fi
            ;;
        *)
            echo -e "${RED}Warning: Unknown agent '$agent'. Skipping.${NC}" >&2
            ;;
    esac
}

# Resolve target agent list
RESOLVED_AGENTS=()
if [[ "$TARGET_AGENT" == "all" ]]; then
    RESOLVED_AGENTS=("claude" "antigravity" "codex" "opencode" "pi")
else
    # Normalize input
    case "$TARGET_AGENT" in
        claude|antigravity|agy|codex|opencode|pi|general)
            RESOLVED_AGENTS=("$TARGET_AGENT")
            ;;
        *)
            echo -e "${RED}Error: Unknown agent type '$TARGET_AGENT'${NC}"
            exit 1
            ;;
    esac
fi

# Accumulate target directories
TARGET_DIRS=()
for ag in "${RESOLVED_AGENTS[@]}"; do
    while read -r dir; do
        if [[ -n "$dir" ]]; then
            TARGET_DIRS+=("$dir")
        fi
    done <<< "$(get_target_dirs "$ag" "$INSTALL_DEST")"
done

# Keep only unique target directories
UNIQUE_TARGET_DIRS=()
for dir in "${TARGET_DIRS[@]}"; do
    [[ -z "$dir" ]] && continue
    exists=false
    for udir in "${UNIQUE_TARGET_DIRS[@]}"; do
        if [[ "$udir" == "$dir" ]]; then
            exists=true
            break
        fi
    done
    if [[ "$exists" == "false" ]]; then
        UNIQUE_TARGET_DIRS+=("$dir")
    fi
done

SOURCE_DIR_ABS="$(cd "$SOURCE_SKILLS_DIR" && pwd)"

# Perform copies
install_unified() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    local target_dir_abs
    target_dir_abs="$(cd "$target_dir" && pwd)"
    
    if [[ "$SOURCE_DIR_ABS" == "$target_dir_abs" ]]; then
        echo -e "${YELLOW}Unified skill is already in source directory. Skipping copy for $target_dir.${NC}"
        return
    fi
    echo -e "${BLUE}Installing Unified Master Skill (/speckit) to $target_dir...${NC}"
    mkdir -p "$target_dir/speckit"
    cp -R "$SOURCE_SKILLS_DIR/speckit/." "$target_dir/speckit/"
    echo -e "${GREEN}✓ Unified skill installed at: $target_dir/speckit/SKILL.md${NC}"
}

install_granular() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    local target_dir_abs
    target_dir_abs="$(cd "$target_dir" && pwd)"
    
    if [[ "$SOURCE_DIR_ABS" == "$target_dir_abs" ]]; then
        echo -e "${YELLOW}Granular skills are already in source directory. Skipping copy for $target_dir.${NC}"
        return
    fi
    echo -e "${BLUE}Installing Granular Skills (speckit-*) to $target_dir...${NC}"
    for skill_path in "$SOURCE_SKILLS_DIR"/speckit-*; do
        if [[ -d "$skill_path" ]]; then
            skill_name=$(basename "$skill_path")
            mkdir -p "$target_dir/$skill_name"
            cp -R "$skill_path/." "$target_dir/$skill_name/"
            echo -e "${GREEN}✓ Granular skill installed: $target_dir/$skill_name${NC}"
        fi
    done
}

# Install default templates and helper scripts for local projects
setup_local_templates() {
    if [[ "$INSTALL_DEST" == "local" ]]; then
        local target_project_root="$(pwd)"
        local source_specify_dir="$SCRIPT_DIR/.specify"
        
        # Avoid copying to itself
        if [[ "$(cd "$source_specify_dir" && pwd)" == "$(cd "$target_project_root" 2>/dev/null && pwd)/.specify" ]]; then
            return
        fi
        
        if [[ ! -d "$target_project_root/.specify" ]]; then
            echo -e "${BLUE}Initializing .specify/ configuration folder in target project...${NC}"
            cp -R "$source_specify_dir" "$target_project_root/.specify"
            chmod +x "$target_project_root/.specify/scripts/bash/"*.sh 2>/dev/null || true
            echo -e "${GREEN}✓ Default templates and helper scripts set up in .specify/${NC}"
        else
            if [[ ! -d "$target_project_root/.specify/scripts/bash" && -d "$source_specify_dir/scripts/bash" ]]; then
                mkdir -p "$target_project_root/.specify/scripts"
                cp -R "$source_specify_dir/scripts/bash" "$target_project_root/.specify/scripts/bash"
                chmod +x "$target_project_root/.specify/scripts/bash/"*.sh 2>/dev/null || true
                echo -e "${GREEN}✓ Helper scripts added to .specify/scripts/bash/${NC}"
            fi
        fi
    fi
}

# Run installation for each target directory
for target_dir in "${UNIQUE_TARGET_DIRS[@]}"; do
    if [[ "$SKILL_TYPE" == "unified" ]]; then
        install_unified "$target_dir"
    elif [[ "$SKILL_TYPE" == "granular" ]]; then
        install_granular "$target_dir"
    elif [[ "$SKILL_TYPE" == "both" ]]; then
        install_unified "$target_dir"
        install_granular "$target_dir"
    else
        echo -e "${RED}Invalid skill type: $SKILL_TYPE. Choose 'unified', 'granular', or 'both'.${NC}"
        exit 1
    fi
done

setup_local_templates

echo -e "\n${GREEN}🎉 Successfully installed agent skills!${NC}"
echo -e "You can now run your agent in a project directory and start using them."
if [[ "$SKILL_TYPE" == "unified" || "$SKILL_TYPE" == "both" ]]; then
    echo -e "Try typing: ${CYAN}/speckit specify 'description'${NC} in your agent chat."
fi
if [[ "$SKILL_TYPE" == "granular" || "$SKILL_TYPE" == "both" ]]; then
    echo -e "Try typing: ${CYAN}/speckit-specify 'description'${NC} in your agent chat."
fi
