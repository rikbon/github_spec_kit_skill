# Installation and Configuration Guide

The **Spec-Kit Multi-Agent Skill Suite** supports flexible deployment across individual developer machines (**Global Installation**) and team-shared version control repositories (**Local Installation**).

---

## 1. Automated Installation (`install-skills.sh`)

The repository includes an interactive, idempotent bash installer ([`install-skills.sh`](../install-skills.sh)) that provisions skill packages, helper scripts, and default templates.

```bash
# Ensure the installer is executable
chmod +x install-skills.sh

# Launch interactive guided setup
./install-skills.sh
```

### Interactive Prompts
When invoked without flags, `install-skills.sh` prompts you for three choices:
1. **Installation Destination**:
   - `Globally (user home directory)`: Installs skills into your user profile so they are available across every project on your machine.
   - `Locally (current repository)`: Installs skills into the current working directory and initializes `.specify/templates/` and `.specify/scripts/bash/` so your team can share the workflow via Git.
2. **Target Agent**:
   - `Claude Code`, `Google Antigravity / Agy`, `OpenAI Codex`, `OpenCode`, `Pi / General Agent (.agents)`, or `All Agents`.
3. **Skill Layout Type**:
   - `Unified (/speckit master command)`, `Granular (/speckit-* individual commands)`, or `Both`.

---

## 2. CLI Flags & Non-Interactive Automation

For CI/CD pipelines, dotfiles bootstrap scripts, or rapid setup, pass CLI arguments directly:

| Flag | Short | Accepted Values | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `--global` | `-g` | *(boolean flag)* | *(prompt)* | Install skills to the user's global home configuration directory. |
| `--local` | `-l` | *(boolean flag)* | *(prompt)* | Install skills to the current repository workspace and bootstrap `.specify/`. |
| `--type` | `-t` | `unified`, `granular`, `both` | `unified` *(when non-interactive)* | Select the single `/speckit` router skill, the 10 `/speckit-*` granular skills, or both. |
| `--agent` | `-a` | `claude`, `antigravity` (`agy`), `codex`, `opencode`, `pi`, `all` | `claude` *(when non-interactive)* | Target specific AI coding agent directory conventions or install for all agents at once. |
| `--help` | `-h` | *(boolean flag)* | — | Display usage instructions and exit. |

### Common CLI Examples

```bash
# Google Antigravity (Agy) — Local workspace install with Unified /speckit skill
./install-skills.sh --local --type unified --agent antigravity

# Claude Code — Global install with both Unified and Granular skills
./install-skills.sh --global --type both --agent claude

# OpenAI Codex — Global install with Granular /speckit-* commands
./install-skills.sh --global --type granular --agent codex

# OpenCode — Local workspace install with Unified skill
./install-skills.sh --local --type unified --agent opencode

# Multi-Agent Workstation — Install Unified skill globally for ALL supported agents
./install-skills.sh --global --type unified --agent all
```

---

## 3. Supported Agents & Directory Mapping

Each AI coding agent discovers `SKILL.md` packages from specific global and workspace-relative paths. `install-skills.sh` maps each agent to its canonical discovery path and deduplicates overlapping directories automatically:

| AI Agent | Global Discovery Path (`--global`) | Project-Local Discovery Path (`--local`) | Invocation Syntax |
| :--- | :--- | :--- | :--- |
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` | `/speckit <subcommand>` or `/speckit-<subcommand>` |
| **Google Antigravity (`agy`)** | `~/.gemini/config/skills/` | `.agents/skills/` | `/speckit <subcommand>` or natural-language skill activation |
| **OpenAI Codex** | `~/.agents/skills/` | `.agents/skills/` | `$speckit` / `/speckit` or natural-language prompt |
| **OpenCode** | `~/.config/opencode/skills/` | `.opencode/skills/` | `/speckit <subcommand>` or `/speckit-<subcommand>` |
| **Pi / General Agents** | `~/.agents/skills/` | `.agents/skills/` | `/skill:speckit` or `/speckit` |

---

## 4. Manual Installation

If you prefer to copy files manually without running `install-skills.sh`:

### Option A: Unified Skill (`/speckit`)
Copy the entire `.claude/skills/speckit/` directory (which includes `SKILL.md`, `references/`, `resources/templates/`, and `scripts/`):

```bash
# Example: Google Antigravity (Global)
mkdir -p ~/.gemini/config/skills/speckit
cp -R .claude/skills/speckit/. ~/.gemini/config/skills/speckit/

# Example: Claude Code (Global)
mkdir -p ~/.claude/skills/speckit
cp -R .claude/skills/speckit/. ~/.claude/skills/speckit/
```

### Option B: Granular Skill Suite (`/speckit-*`)
Copy the 10 individual `speckit-*` directories into your target skills folder:

```bash
# Example: Project-local (.agents/skills/)
mkdir -p .agents/skills
cp -R .claude/skills/speckit-* .agents/skills/
```

### Option C: Provision `.specify/` Workspace Templates & Scripts (Optional for Local Projects)
```bash
cp -R .specify /path/to/your/project/.specify
chmod +x /path/to/your/project/.specify/scripts/bash/*.sh
```

---

## 5. Environment & Tooling Prerequisites

| Requirement | Required By | Purpose & Verification |
| :--- | :--- | :--- |
| **Git CLI** | All commands | Repository root detection and branch resolution (`git --version`). |
| **POSIX Shell (`bash`)** | Optional (`scripts/bash/*.sh`) | Runs helper scripts (`check-prerequisites.sh`, `setup-plan.sh`, `setup-tasks.sh`). If unavailable, skills automatically fall back to native agent file tools. |
| **GitHub MCP Server** *or* **GitHub CLI (`gh`)** | `/speckit taskstoissues` only | Authenticates with GitHub to list and create issues. Verify CLI auth via `gh auth status`. |

---

## 6. Post-Installation Verification

After installing, open your agent in any repository and run:

```text
/speckit
```

Your agent should load the Spec-Kit skill and display the subcommand router overview. To initialize your project's governing principles, run:

```text
/speckit constitution
```
