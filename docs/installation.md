# Installation and Configuration

The Spec-Kit Agent Skill Suite can be installed either globally (making the skills available across all project repositories) or locally (committing the skills to a specific repository).

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
  Copies selected skills to your user profile's global agent config directory. This makes the commands available in any directory when you start your agent CLI or IDE.
- **Local Installation**:
  Copies selected skills to the agent config folder in your current working directory. Use this option if you want to share the skills with your development team via Git.
- **Agent Selection**:
  You can target a specific agent (e.g., `--agent claude`, `--agent antigravity` / `agy`, `--agent codex`, `--agent opencode`, `--agent pi`) or install for all of them using `--agent all`.

---

## Supported Agents & Directories

The automated installer natively maps skills to the paths expected by different AI coding agents:

| Agent | Personal (Global) Skills | Project-Level (Local) Skills |
| :--- | :--- | :--- |
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` |
| **Google Antigravity / Agy** | `~/.gemini/antigravity-cli/skills/`<br>`~/.gemini/config/skills/`<br>`~/.agents/skills/` | `.agents/skills/`<br>`.agent/skills/` |
| **OpenAI Codex** | `~/.agents/skills/` | `.agents/skills/` |
| **OpenCode** | `~/.config/opencode/skills/` | `.opencode/skills/` |
| **Pi / General** | `~/.agents/skills/` | `.agents/skills/` |

---

## Manual Installation

If you prefer to configure your workspace manually:

### 1. Unified Skill (`/speckit`)
To install the unified, subcommand-router skill, create the appropriate directory for your agent and copy the skill file:

```bash
# Example for Claude Code (Global)
mkdir -p ~/.claude/skills/speckit
cp .claude/skills/speckit/SKILL.md ~/.claude/skills/speckit/SKILL.md

# Example for Google Antigravity / Codex (Local)
mkdir -p .agents/skills/speckit
cp .claude/skills/speckit/SKILL.md .agents/skills/speckit/SKILL.md
```

### 2. Granular Skills (`/speckit-*`)
To install the separate individual commands:

```bash
# Example for Claude Code (Global)
mkdir -p ~/.claude/skills
cp -R .claude/skills/speckit-* ~/.claude/skills/

# Example for Google Antigravity / Codex (Local)
mkdir -p .agents/skills
cp -R .claude/skills/speckit-* .agents/skills/
```

---

## Configuration & Prerequisites

To utilize the full capabilities of the skill suite, ensure the following tools are set up:

### Tooling Prerequisites
- **Agent CLI / IDE**: Installed and configured (e.g. `claude`, `agy`, `codex`, `opencode`).
- **Git CLI**: Verified and initialized in target repositories.
- **GitHub CLI (`gh`)**: Required specifically for the `taskstoissues` subcommand. Must be installed and authenticated (`gh auth login`).
- **GitHub MCP Server or Native Tools**: Enables the agent to interact with issues, repositories, and PRs.

### Workspace Prerequisites
The skills work out-of-the-box using built-in fallbacks. They are further enhanced by the presence of a `.specify/` configuration folder in your project root:
- **`.specify/memory/constitution.md`**: Project-wide coding standards and principles.
- **`.specify/templates/`**: Custom presets and templates for specs, plans, and tasks. (The local installer `./install-skills.sh --local` automatically provisions default templates if this folder is missing).
- **`.specify/extensions.yml`**: Custom extension hooks to automate setup, commits, or tests.
