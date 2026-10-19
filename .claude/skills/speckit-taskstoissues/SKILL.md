---
name: "speckit-taskstoissues"
description: "Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts."
argument-hint: "Optional filter or label for GitHub issues"
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "github-spec-kit"
  source: "templates/commands/taskstoissues.md"
user-invocable: true
disable-model-invocation: false
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before tasks-to-issues conversion)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_taskstoissues` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- When constructing slash commands from hook command names, replace dots (`.`) with hyphens (`-`). For example, `speckit.git.commit` → `/speckit-git-commit`.
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing. Run it the same way you would run the command yourself in this agent/session (the invocation may differ from the literal `{command}` id shown above, e.g. a skills-mode agent runs it as `/skill:speckit-...` or `$speckit-...`). Emitting the block alone does not run the hook.
- If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently

## Outline

1. **Resolve Feature & Tasks Path**:
   - Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse `FEATURE_DIR` and `AVAILABLE_DOCS` list. All paths must be absolute.
   - **Native Tool Fallback**: If `.specify/scripts/bash/check-prerequisites.sh` is missing or fails to execute, do **NOT** fail. Resolve `FEATURE_DIR` natively by reading `"feature_directory"` from `.specify/feature.json` (or finding the latest directory under `specs/`), and set `TASKS` to `FEATURE_DIR/tasks.md`.
2. **IF EXISTS**: Load `.specify/memory/constitution.md` for project principles and governance constraints.
3. **Verify Git Remote & Authentication**:
   - Get the Git remote by running:
     ```bash
     git config --get remote.origin.url
     ```
   - > [!CAUTION]
     > ONLY PROCEED TO NEXT STEPS IF THE REMOTE IS A GITHUB URL
   - If using the GitHub CLI (`gh`), verify authentication via `gh auth status`. If neither GitHub MCP nor an authenticated `gh` CLI is available, output: `⚠️ Error: Neither GitHub MCP nor authenticated gh CLI found. Please run "gh auth login" to sync tasks.` and halt.
4. **Fetch existing issues for deduplication**:
   - Build the set of incomplete task IDs (`- [ ]`) you are about to process from `tasks.md` (each is a `T` followed by three digits, e.g. `T001`). Skip already completed tasks (`- [X]` or `- [x]`) unless the user explicitly requested syncing completed tasks.
   - **Via GitHub MCP (preferred if available)**: Use the `list_issues` tool without a `state` filter (returns both open and closed issues), requesting `perPage: 100` and paginating with `after` (`endCursor`) until all task IDs are matched or no pages remain.
   - **Via GitHub CLI (`gh` fallback)**: Run `gh issue list --state all --limit 200 --json number,title,url` against the target repository.
   - Match each existing issue title against `\bT\d{3}\b` (word boundaries so tokens like `ST001` or `T0010` are not matched by mistake; recognises `T001 ...`, `T001: ...`, or `[T001] ...`). When it matches one of your task IDs, mark that ID as already having an issue.
5. **Create Issues for Unsynced Tasks**:
   - For each incomplete task in `tasks.md` not already in the existing issues set:
     - Strip the leading `- [ ]` (and extract any `[P]` or `[US#]` markers) to recover the task ID and description.
     - Create the issue in the repository matching the Git remote using a canonical title of the form `T001: <description>` (either via the GitHub MCP server or `gh issue create --title "T001: <description>" --body "<context>"`). If a `[US#]` tag is present and a matching label exists, attach it or include the story reference in the issue body.
     - **Skip** any task whose ID already has an issue and report it (e.g., `T001 already has an issue, skipping`).
   - Output a Markdown summary table of newly created and skipped issues with their issue numbers and URLs.

> [!CAUTION]
> UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL

## Post-Execution Checks

**Check for extension hooks (after tasks-to-issues conversion)**:
Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_taskstoissues` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- When constructing slash commands from hook command names, replace dots (`.`) with hyphens (`-`). For example, `speckit.git.commit` → `/speckit-git-commit`.
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing. Run it the same way you would run the command yourself in this agent/session (the invocation may differ from the literal `{command}` id shown above, e.g. a skills-mode agent runs it as `/skill:speckit-...` or `$speckit-...`). Emitting the block alone does not run the hook.
- If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently
