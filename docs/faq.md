# Frequently Asked Questions (FAQ)

This document addresses common questions and troubleshooting topics when using Spec-Kit skills with Claude Code.

---

## General Questions

### Q: Why should I use the Unified Skill `/speckit` instead of the Granular Skills?
**A**: The unified skill organizes all Spec-Kit steps under a single entry point `/speckit <subcommand>`. This prevents cluttering Claude's slash-commands dropdown menu, making it easier to see other project-specific commands.

### Q: Do these skills require the Python `specify-cli` package?
**A**: No. These skills are fully self-contained. Although they can use project configurations (like `.specify/` templates and extension hooks) if present, Claude Code performs all requirements parsing, checklist checks, directory creation, and task management natively.

---

## Troubleshooting

### Q: What happens if the spec-kit bash scripts are missing from my project?
**A**: Nothing will break. The skills have built-in **native fallbacks**. If Claude Code detects that the helper scripts under `.specify/scripts/bash/` (such as `setup-plan.sh` or `setup-tasks.sh`) are missing, it will automatically use its filesystem tools to resolve templates, directories, and task lists natively.

### Q: Claude Code complains that `.specify/` templates or constitution are missing. What should I do?
**A**: Running `./install-skills.sh --local` inside a repository automatically initializes a default `.specify/templates/` folder containing standard blueprints. If the project principles in `constitution.md` are missing, simply run `/speckit constitution` to generate them.

### Q: How do I resolve permission errors when executing custom scripts?
**A**: If you register a custom hook script, ensure the script is marked as executable:
```bash
chmod +x .specify/scripts/bash/*.sh
```

### Q: Can I run these skills globally?
**A**: Yes. Run `./install-skills.sh --global` to copy the skills to `~/.claude/skills/`. They will be available in any repository you open with Claude Code.
