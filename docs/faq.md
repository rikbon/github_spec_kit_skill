# Frequently Asked Questions (FAQ) & Troubleshooting

This guide answers common architectural and operational questions when using the **Spec-Kit Multi-Agent Skill Suite** across **Claude Code**, **Google Antigravity (`agy`)**, **OpenAI Codex**, **OpenCode**, and **Pi**.

---

## General & Architectural Questions

### Q: Should I install the Unified Skill (`/speckit`) or the Granular Skill Suite (`/speckit-*`)?
**A**: Both provide identical capabilities and guardrails:
- Choose **Unified (`/speckit`)** if you want a clean slash-command menu with a single `/speckit <subcommand>` entry point and progressive context loading via `references/<subcommand>.md`.
- Choose **Granular (`/speckit-*`)** if you prefer direct tab-autocompletion for each individual command (`/speckit-specify`, `/speckit-plan`, `/speckit-implement`, etc.).
- You can also install **Both** (`./install-skills.sh --type both`).

### Q: Does this skill suite require the Python `specify-cli` (`uvx specify`) package?
**A**: **No.** This suite is 100% self-contained. It bundles POSIX bash helper scripts (`.specify/scripts/bash/`), standard Markdown templates (`.specify/templates/`), and native agent filesystem fallbacks directly inside the repository and skill packages.

### Q: How do downstream commands know which feature directory under `specs/` is active?
**A**: When `/speckit specify` creates a new feature folder (e.g., `specs/001-user-auth`), it writes that path to `.specify/feature.json`:
```json
{
  "feature_directory": "specs/001-user-auth"
}
```
All subsequent commands (`/speckit clarify`, `/speckit plan`, `/speckit tasks`, `/speckit implement`, `/speckit converge`, `/speckit taskstoissues`) read `.specify/feature.json` first, falling back to the highest-numbered directory under `specs/` if `feature.json` is absent. This means your Git branch name does **not** need to match your spec folder name.

### Q: How can I switch from sequential numbering (`001-`, `002-`) to timestamp prefixes (`20261019-093000-`)?
**A**: Create or edit `.specify/init-options.json` in your repository root:
```json
{
  "feature_numbering": "timestamp"
}
```
Timestamp numbering prevents directory number collisions when multiple engineers create specifications in parallel on separate branches.

---

## Troubleshooting

### Q: What happens if `.specify/scripts/bash/` is missing or I am running on Windows without bash?
**A**: Every skill (both unified and granular) includes an explicit **Native Tool Fallback**. If `check-prerequisites.sh`, `setup-plan.sh`, or `setup-tasks.sh` is missing or fails to execute, the agent automatically falls back to reading `.specify/feature.json`, scanning `specs/`, and copying templates using its built-in filesystem tools without interrupting your workflow.

### Q: I installed the skills globally (`--global`). Where does the agent find templates in a brand-new repository that doesn't have a `.specify/` folder?
**A**: The unified skill (`speckit/`) bundles a complete copy of all 5 default templates inside `resources/templates/` (Tier 5 of the Template Resolution Priority) and also includes inline fallback section structures in `SKILL.md`. If you want to customize templates for a specific repository, run `./install-skills.sh --local` in that repository to provision `.specify/templates/`.

### Q: `/speckit implement` stopped and asked for confirmation before writing code. Why?
**A**: By design, `/speckit implement` scans all checklist files in `specs/<NNN>-<feature>/checklists/` as a pre-implementation quality gate. If any checklist contains unchecked items (`- [ ]`), the agent displays a status table and asks whether you want to resolve the spec/checklist gaps first or proceed anyway.

### Q: `/speckit taskstoissues` refuses to run or reports an authentication error. How do I fix it?
**A**: `/speckit taskstoissues` enforces two safety and authentication checks:
1. **GitHub Remote Check**: Run `git config --get remote.origin.url` and verify it points to a `github.com` repository. The skill will never create issues if the remote is missing or points to a non-GitHub host.
2. **GitHub MCP or `gh` CLI Authentication**: Ensure either the GitHub MCP Server is connected in your agent **or** the GitHub CLI (`gh`) is installed and authenticated via:
   ```bash
   gh auth login
   gh auth status
   ```

### Q: If I run `/speckit taskstoissues` twice, will it create duplicate GitHub Issues?
**A**: **No.** Before creating any issues, the skill fetches existing open and closed issues and matches their titles against the task ID pattern `\bT\d{3}\b` (e.g., `T001: ...` or `[T001] ...`). Any task ID that already has a matching issue—or is already marked completed (`- [X]`) in `tasks.md`—is automatically skipped.
