# Contributing to the Spec-Kit Skill Suite

Thank you for contributing to the **Spec-Kit Multi-Agent Skill Suite**! This guide documents the architectural standards, YAML frontmatter conventions, synchronization rules, and verification steps required for submitting improvements or new extensions.

---

## 1. Repository Layout & Synchronization Rules

The skill suite ships in two complementary layouts under [`.claude/skills/`](../.claude/skills/):
1. **Granular Skills (`.claude/skills/speckit-<subcommand>/SKILL.md`)**: Ten standalone skill definitions.
2. **Unified Skill (`.claude/skills/speckit/`)**:
   - `SKILL.md`: The master router and condensed execution guide.
   - `references/<subcommand>.md`: Full deep-dive instructions mirrored from the corresponding granular skill.
   - `resources/templates/*.md`: Bundled fallback templates mirrored from `.specify/templates/*.md`.
   - `scripts/*.sh`: Bundled helper scripts mirrored from `.specify/scripts/bash/*.sh`.

> [!IMPORTANT]
> **Parity Requirement**: Whenever you modify a granular skill (`.claude/skills/speckit-<name>/SKILL.md`), a template (`.specify/templates/<name>-template.md`), or a bash helper (`.specify/scripts/bash/<script>.sh`), you **MUST** synchronize the corresponding file inside `.claude/skills/speckit/references/`, `resources/templates/`, or `scripts/`:
> ```bash
> cp .specify/templates/*.md .claude/skills/speckit/resources/templates/
> cp .specify/scripts/bash/*.sh .claude/skills/speckit/scripts/
> for s in constitution specify clarify plan checklist analyze tasks implement converge taskstoissues; do
>   cp ".claude/skills/speckit-$s/SKILL.md" ".claude/skills/speckit/references/$s.md"
> done
> ```

---

## 2. Skill Authoring Standards (`SKILL.md`)

### YAML Frontmatter Schema
Every `SKILL.md` file must begin with valid YAML frontmatter:

```yaml
---
name: "speckit-example"
description: "Concise, third-person description of what the skill does and when to trigger it."
argument-hint: "Optional hint shown in the agent's slash-command input prompt"
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "github-spec-kit"
  source: "templates/commands/example.md"
user-invocable: true
disable-model-invocation: false
---
```

### Prompt Engineering Guidelines for Multi-Agent Compatibility
1. **Agent-Agnostic Tooling Instructions**:
   - Do not hardcode instructions that only work in a single agent IDE unless paired with a universal fallback.
   - *Example (Interactive Questions)*: Instruct the agent to prefer its native question tool (`ask_question` or `AskUserQuestion`) if available, and provide a standard Markdown table format as a fallback.
   - *Example (GitHub Integration)*: Support both the **GitHub MCP Server** and the **GitHub CLI (`gh`)**.
2. **Mandatory Native Fallbacks**:
   - Any step that invokes a bash script under `.specify/scripts/bash/` must include a **Native Tool Fallback** bullet explaining how the agent should resolve paths using `.specify/feature.json` and native filesystem tools if the script is missing or fails.
3. **Imperative, Deterministic Steps**:
   - Write execution steps in clear, numbered stages (`## Pre-Execution Checks`, `## Outline` / `## Execution Steps`, `## Mandatory Post-Execution Hooks`, `## Completion Report`, `## Done When`).
   - State explicit read/write constraints (e.g., `STRICTLY READ-ONLY` in `analyze`, `APPEND-ONLY, NEVER REWRITE` in `converge`).

---

## 3. Bash Helper Script Standards (`.specify/scripts/bash/`)

All helper scripts in `.specify/scripts/bash/` must adhere to:
- **Shebang**: `#!/usr/bin/env bash` with `set -e`.
- **Portability**: Compatible with macOS default `bash 3.2` as well as Linux `bash 4+/5+` (avoid `declare -A` associative arrays or GNU-only `sed`/`grep` flags).
- **Clean JSON Output**: When invoked with `--json`, stdout must be valid, parseable JSON and error messages must be directed to `stderr` (`>&2`).

---

## 4. Developing Custom Extensions

You can extend Spec-Kit with custom pre/post lifecycle hooks via `.specify/extensions.yml`:

1. Create your extension skill in `.claude/skills/speckit-<ext>-<action>/SKILL.md` (or `.agents/skills/`).
2. Register the hook in `.specify/extensions.yml` under the target lifecycle event (`before_specify`, `after_implement`, etc.).
3. Set `optional: false` for mandatory automated gates or `optional: true` for interactive user prompts.

---

## 5. Pre-Submission Checklist

Before opening a Pull Request, verify all of the following:

- [ ] **Bash Syntax Check**: Run `bash -n install-skills.sh .specify/scripts/bash/*.sh` with zero errors.
- [ ] **Unified / Granular Parity**: Ensure `.claude/skills/speckit/references/`, `resources/templates/`, and `scripts/` are synced with their source counterparts.
- [ ] **No Machine-Local Paths**: Verify no hardcoded user paths (e.g., `/Users/...` or `/home/...`) appear in any skill, template, or documentation file.
- [ ] **Local Installer Smoke Test**: Test `./install-skills.sh --local --type both --agent antigravity` in a temporary directory and verify skills and `.specify/` files are provisioned cleanly.
