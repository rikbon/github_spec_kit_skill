# Installation and Configuration

The Spec-Kit Claude Code Skill Suite can be installed either globally (making the skills available across all project repositories) or locally (committing the skills to a specific repository).

---

## Automated Installation

An executable installer script is provided in the root directory to automate the configuration:

```bash
# Set execute permissions (if not already set)
chmod +x install-skills.sh

# Run the installer
./install-skills.sh
```

### Installation Options

- **Global Installation**:
  Copies selected skills to `~/.claude/skills/`. This makes the commands available in any directory when you start Claude Code.
- **Local Installation**:
  Copies selected skills to `./.claude/skills/` in your current working directory. Use this option if you want to share the skills with your development team via Git.

---

## Manual Installation

If you prefer to configure your workspace manually:

### 1. Unified Skill (`/speckit`)
To install the unified, subcommand-router skill:
```bash
# Create directory
mkdir -p ~/.claude/skills/speckit

# Copy the skill file
cp .claude/skills/speckit/SKILL.md ~/.claude/skills/speckit/SKILL.md
```

### 2. Granular Skills (`/speckit-*`)
To install the separate individual commands:
```bash
# Create directory
mkdir -p ~/.claude/skills

# Copy granular skill folders
cp -R .claude/skills/speckit-* ~/.claude/skills/
```

---

## Configuration & Prerequisites

To utilize the full capabilities of the skill suite, ensure the following tools are set up:

### Tooling Prerequisites
- **Claude Code CLI**: Installed and configured.
- **Git CLI**: Verified and initialized in target repositories.
- **GitHub CLI (`gh`)**: Required specifically for the `taskstoissues` subcommand. Must be installed and authenticated (`gh auth login`).
- **GitHub MCP Server**: Enables Claude Code to interact with issues, repositories, and PRs via Model Context Protocol.

### Workspace Prerequisites
The skills work out-of-the-box using built-in fallbacks. They are further enhanced by the presence of a `.specify/` configuration folder in your project root:
- **`.specify/memory/constitution.md`**: Project-wide coding standards and principles.
- **`.specify/templates/`**: Custom presets and templates for specs, plans, and tasks. (The local installer `./install-skills.sh --local` automatically provisions default templates if this folder is missing).
- **`.specify/extensions.yml`**: Custom extension hooks to automate setup, commits, or tests.
