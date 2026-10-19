# Spec-Kit Multi-Agent Skill Suite

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Spec-Kit Version](https://img.shields.io/badge/version-1.2.0-brightgreen.svg)](.claude/skills/speckit/SKILL.md)
[![Format: SKILL.md](https://img.shields.io/badge/format-SKILL.md-purple.svg)](docs/architecture.md)
[![Agents: Multi-Agent](https://img.shields.io/badge/agents-Claude%20%7C%20Antigravity%20%7C%20Codex%20%7C%20OpenCode%20%7C%20Pi-orange.svg)](docs/installation.md)

An enterprise-grade, self-contained suite of AI agent skills implementing the **Spec-Driven Development (SDD)** methodology based on the open-source [GitHub Spec-Kit](https://github.com/github/spec-kit) framework. Designed natively for **Claude Code**, **Google Antigravity (`agy`)**, **OpenAI Codex**, **OpenCode**, **Pi**, and any coding agent supporting the standard `SKILL.md` specification.

Instead of relying on unguided, ad-hoc prompting (*"vibe coding"*), this suite enforces a deterministic, traceable engineering lifecycle where **constitutional principles**, **functional specifications**, **technical architecture plans**, **requirements checklists**, and **dependency-ordered task backlogs** are treated as first-class, version-controlled artifacts.

---

## Documentation Index

| Guide | Description |
| :--- | :--- |
| **[1. Introduction to SDD](docs/introduction.md)** | Core philosophy, SDD vs. ad-hoc prompting comparison, and end-to-end artifact traceability. |
| **[2. Installation & Setup](docs/installation.md)** | Interactive installer, CLI automation flags, agent directory mappings, and workspace setup. |
| **[3. Workflow Runbook](docs/workflows.md)** | Complete reference and step-by-step tutorial for all 10 Spec-Kit lifecycle subcommands. |
| **[4. System Architecture](docs/architecture.md)** | Progressive disclosure design, 5-tier template resolution, native fallbacks, and extension hooks. |
| **[5. Engineering Best Practices](docs/best_practices.md)** | Guidelines for authoring technology-agnostic specs, constitutional gates, and requirements checklists. |
| **[6. Contributing Guide](docs/contributing.md)** | Standards for authoring skills, maintaining unified/granular parity, and building extensions. |
| **[7. FAQ & Troubleshooting](docs/faq.md)** | Answers to common questions on cross-platform execution, fallbacks, and GitHub issue syncing. |

---

## Key Capabilities & Highlights

- **Zero External Runtime Dependencies**: Operates out-of-the-box without requiring the Python `specify-cli` package. Includes bundled POSIX bash helpers (`.specify/scripts/bash/`) **plus** automatic native agent filesystem fallbacks for environments without bash.
- **Progressive Disclosure Architecture**: The unified `/speckit` skill keeps initial token overhead minimal by routing commands dynamically and loading deep-dive rules from `references/<subcommand>.md` and fallback blueprints from `resources/templates/` on demand.
- **Native Interactive Questioning**: Automatically leverages your agent's native interactive question UI (`ask_question` in Google Antigravity, `AskUserQuestion` in Claude Code) during `/speckit clarify`, `/speckit specify`, and `/speckit checklist`, with graceful fallback to structured Markdown tables.
- **Dual GitHub Synchronization**: `/speckit taskstoissues` supports both the **GitHub MCP Server** and the **GitHub CLI (`gh`)** with strict remote-origin verification and regex-based task ID deduplication (`\bT\d{3}\b`).

---

## Architectural Packaging: Unified vs. Granular

You can install the skill suite in either (or both) of two layouts sourced from [`.claude/skills/`](.claude/skills/):

| Feature | Unified Skill (`/speckit`) | Granular Skill Suite (`/speckit-*`) |
| :--- | :--- | :--- |
| **Entry Point** | Single router command: `/speckit <subcommand> [args]` | 10 dedicated commands: `/speckit-specify`, `/speckit-plan`, etc. |
| **Source Path** | [`.claude/skills/speckit/`](.claude/skills/speckit/) | [`.claude/skills/speckit-*/`](.claude/skills/) |
| **Slash Menu Footprint** | Minimal (1 command in autocomplete menu) | Explicit (10 individual commands in autocomplete menu) |
| **Context Loading** | Progressive disclosure via bundled `references/` & `resources/` | Dedicated `SKILL.md` loaded per invoked command |
| **Best For** | Keep agent command palettes clean across global installs | Direct slash-command tab-completion for every phase |

---

## Quick Installation

Run the interactive installer script to configure the suite for your preferred agent and scope:

```bash
chmod +x install-skills.sh
./install-skills.sh
```

The interactive prompt walks you through:
1. **Installation Scope**: Global (user home config) or Local (current project repository).
2. **Target Agent**: Claude Code, Google Antigravity / Agy, OpenAI Codex, OpenCode, Pi, or All Agents.
3. **Skill Layout**: Unified (`/speckit`), Granular (`/speckit-*`), or Both.

### Non-Interactive CLI Presets

```bash
# Install Unified skill globally for Claude Code (~/.claude/skills/)
./install-skills.sh --global --type unified --agent claude

# Install Unified skill locally for Google Antigravity (.agents/skills/ + .specify/)
./install-skills.sh --local --type unified --agent antigravity

# Install Granular skill suite globally for OpenAI Codex (~/.agents/skills/)
./install-skills.sh --global --type granular --agent codex

# Install both Unified and Granular skills globally across all supported agents
./install-skills.sh --global --type both --agent all
```

---

## The 10-Phase SDD Lifecycle

```text
Constitution ──> Specify ──> Clarify ──> Plan ──> Checklist ──> Tasks ──> Analyze ──> Implement ──> Converge ──> TasksToIssues
```

| # | Unified Command | Granular Command | Primary Artifact(s) | Phase Objective |
| :- | :--- | :--- | :--- | :--- |
| **1** | `/speckit constitution` | `/speckit-constitution` | `.specify/memory/constitution.md` | Establish non-negotiable architectural principles, coding standards, and governance rules. |
| **2** | `/speckit specify` | `/speckit-specify` | `specs/<NNN>-<name>/spec.md`<br>`checklists/requirements.md` | Author a technology-agnostic functional specification with prioritized user stories (`P1`–`P3`), `FR-###`, and `SC-###`. |
| **3** | `/speckit clarify` | `/speckit-clarify` | Updates `spec.md` & `requirements.md` | Scan across a 10-category ambiguity taxonomy and run an interactive Q&A loop (max 5 questions). |
| **4** | `/speckit plan` | `/speckit-plan` | `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` | Define the technical stack, pass the Constitution Check gate, model entities, and specify interface contracts. |
| **5** | `/speckit checklist` | `/speckit-checklist` | `specs/<NNN>-<name>/checklists/<domain>.md` | Generate "Unit Tests for English" validating requirements completeness, clarity, and measurability. |
| **6** | `/speckit tasks` | `/speckit-tasks` | `specs/<NNN>-<name>/tasks.md` | Decompose design artifacts into phased, story-mapped, parallel-annotated (`[P]`) implementation tasks (`T001`...). |
| **7** | `/speckit analyze` | `/speckit-analyze` | In-session Consistency Report *(Read-Only)* | Audit cross-artifact alignment, requirement-to-task coverage, and constitutional compliance before coding. |
| **8** | `/speckit implement` | `/speckit-implement` | Source code + checked `[X]` items in `tasks.md` | Verify checklist gates and ignore files, then execute tasks phase-by-phase following TDD principles. |
| **9** | `/speckit converge` | `/speckit-converge` | Appends `## Phase N: Convergence` to `tasks.md` | Audit implemented code against `spec.md`, `plan.md`, and `tasks.md`; append remediation tasks for any drift. |
| **10** | `/speckit taskstoissues` | `/speckit-taskstoissues` | GitHub Issues (`T001: <description>`) | Deduplicate and synchronize incomplete tasks from `tasks.md` to GitHub Issues via MCP or `gh` CLI. |

For detailed examples of every command, see the **[Workflow Runbook](docs/workflows.md)**.

---

## License

This project is released under the **[MIT License](LICENSE)**.
