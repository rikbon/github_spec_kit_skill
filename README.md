# 🚀 Spec-Kit Claude Code Skill Suite

An advanced, production-ready set of [Claude Code](https://docs.anthropic.com/en/docs/claude-code/setup) skills implementing the **Spec-Driven Development (SDD)** workflow based on the open-source [GitHub Spec-Kit](https://github.com/github/spec-kit) project.

This toolkit replaces unguided AI development ("vibe coding") with a predictable, trace-driven process that treats specifications, architecture plans, and checklists as first-class executable artifacts.

---

## 📖 Table of Contents

1. [Introduction to Spec-Driven Development](docs/introduction.md)
2. [Installation and Configuration](docs/installation.md)
3. [Workflow Subcommands](docs/workflows.md)
4. [Architecture and Customization](docs/architecture.md)
5. [SDD Best Practices](docs/best_practices.md)
6. [Contributing Guide](docs/contributing.md)
7. [Frequently Asked Questions (FAQ)](docs/faq.md)
8. [License](LICENSE)

---

## 📦 What is Included?

You can choose between two installation layouts, both located under the [.claude/skills/](.claude/skills/) folder:

### 1. The Unified Skill (`/speckit`)
A single, all-in-one skill located at [.claude/skills/speckit/SKILL.md](.claude/skills/speckit/SKILL.md).
- **Command**: `/speckit <subcommand> [args]`
- **Subcommands**: `constitution`, `specify`, `clarify`, `plan`, `checklist`, `analyze`, `tasks`, `implement`, `converge`, `taskstoissues`.
- **Advantage**: Keeps the Claude Code slash-command menu neat by encapsulating the entire workflow.

### 2. The Granular Skill Suite (`/speckit-*`)
Ten separate, dedicated skills.
- **Commands**: `/speckit-constitution`, `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`, `/speckit-checklist`, `/speckit-analyze`, `/speckit-tasks`, `/speckit-implement`, `/speckit-converge`, `/speckit-taskstoissues`.
- **Advantage**: Provides dedicated slash-commands with direct auto-complete in the Claude terminal.

---

## ⚡ Quick Installation

Use the provided shell script to automate installation:

```bash
# Set execute permission
chmod +x install-skills.sh

# Run installer (prompts for local/global and unified/granular choices)
./install-skills.sh
```

### Automation Presets
```bash
# Install globally to ~/.claude/skills/ (Unified master command)
./install-skills.sh --global --type unified

# Install locally to your current repository (Granular commands suite)
./install-skills.sh --local --type granular
```

---

## 📚 SDD Workflow Overview

```
Specify ──> Clarify ──> Plan ──> Tasks ──> Implement ──> Converge ──> TasksToIssues
```

1. **Establish Principles**: `/speckit constitution` writes the project's governing standards to `.specify/memory/constitution.md`.
2. **Author Spec**: `/speckit specify` creates a functional specification (`spec.md`) in a numbered feature directory under `specs/`.
3. **Interactive Clarification**: `/speckit clarify` scans the spec and runs a 5-question interactive loop to resolve ambiguities.
4. **Build Plan**: `/speckit plan` outlines the tech stack (`plan.md`), data model schemas (`data-model.md`), contracts, and verification scenarios (`quickstart.md`).
5. **Quality Checklists**: `/speckit checklist` produces requirement validation checklists ("Unit Tests for English").
6. **Task Backlog**: `/speckit tasks` converts design files into structured, checklist-formatted tasks in `tasks.md`.
7. **Consistency Audit**: `/speckit analyze` maps task coverage and scans for constitution violations.
8. **Implementation Execution**: `/speckit implement` executes tasks sequentially, checking off boxes in `tasks.md`.
9. **Convergence Audit**: `/speckit converge` checks codebase drift and appends incomplete work to `tasks.md`.
10. **Issue Synchronization**: `/speckit taskstoissues` syncs your task list to GitHub Issues for team tracking.

For a full step-by-step tutorial, see the [Spec-Kit Workflows Guide](docs/workflows.md).

---

## 🛡️ License

This project is licensed under the terms of the **MIT License**. See the [LICENSE](LICENSE) file for the full license text.
