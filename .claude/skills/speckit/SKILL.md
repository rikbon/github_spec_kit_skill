---
name: speckit
description: "Unified Spec-Driven Development (SDD) assistant implementing the GitHub Spec-Kit workflow. Run with subcommands: constitution, specify, clarify, plan, checklist, analyze, tasks, implement, converge, or taskstoissues."
argument-hint: "<subcommand> [args] (e.g., specify 'create a photo organizer')"
compatibility: "Works in any project directory. Detects and integrates with .specify/ project config if present."
metadata:
  author: "github-spec-kit"
  version: "1.1.0"
user-invocable: true
disable-model-invocation: false
---

# GitHub Spec-Kit: Unified Spec-Driven Development

This skill implements the complete Spec-Driven Development (SDD) workflow defined by [GitHub Spec-Kit](https://github.com/github/spec-kit). Instead of writing code directly from ad-hoc prompts ("vibe coding"), you will use a structured, predictable process:

```
Specify ────> Clarify ────> Plan ────> Tasks ────> Implement ────> Converge
```

---

## 🎮 Subcommand Router

When the user invokes this skill (e.g., `/speckit specify "build user auth"` or `/speckit plan`), parse the first argument as the **subcommand**. 
- If the first word matches one of the subcommands below, route execution to the corresponding section.
- If no subcommand is specified, or if the argument is empty, display a usage guide explaining the available subcommands.

---

## 🛡️ General Operating Guidelines & Fallbacks

1. **Path Normalization**: Always use absolute paths for file system edits and project-relative paths inside Markdown documentation.
2. **Native Tool Fallback (Self-Containment)**:
   Many spec-kit commands check prerequisites or resolve directories using local bash scripts under `.specify/scripts/bash/` (such as `check-prerequisites.sh`, `setup-plan.sh`, and `setup-tasks.sh`).
   - If these scripts are **missing** or fail to execute (e.g., on Windows without Git Bash or in a fresh repository), **you MUST NOT fail**. 
   - Instead, fall back to native Claude Code commands and filesystem tools to scan for files, read `.specify/feature.json`, find the latest folder in `specs/`, and copy/create templates directly.
3. **Constitution Graceful Handling**:
   - If `.specify/memory/constitution.md` is missing, output: `⚠️ Warning: Project constitution.md not found. Establishing core principles is highly recommended before specification and planning. Proceeding with default guidelines.`
   - Run the command without crashing, but remind the user to run `/speckit constitution` to establish core principles.
4. **Extension Hooks**: If `.specify/extensions.yml` exists, parse and output pre-execution and post-execution hooks commands, giving the user instructions to execute optional hooks and automatically executing mandatory ones (using `EXECUTE_COMMAND:`).
5. **Progressive Disclosure**: When reading specifications or plans, read sections incrementally rather than pulling entire massive files into the prompt context at once.
6. **Template Resolution Priority**:
   When copying or reading templates, always resolve them in this priority order (highest to lowest):
   1. **Project-Local Overrides**: `.specify/templates/overrides/`
   2. **Presets**: `.specify/presets/templates/`
   3. **Extensions**: `.specify/extensions/templates/`
   4. **Spec-Kit Core Defaults**: `.specify/templates/`

---

## 1. `/speckit constitution`
**Goal**: Create or update the project's governing principles in `.specify/memory/constitution.md` (or `.claude/spec-kit/constitution.md` if not initialized with spec-kit CLI).

### Execution Flow:
1. **Initialize/Load**:
   - Check if `.specify/memory/constitution.md` exists. If not, resolve `constitution-template.md` using the template resolution priority, and copy it.
   - If neither exists, initialize a new constitution with sections: `## Project Vision`, `## Core Principles`, `## Design Constraints`, `## Governance & Amendments`.
2. **Collect Inputs**:
   - Parse user arguments. If they contain specific principles, integrate them.
   - Otherwise, ask the user or infer principles based on the existing codebase (README, package.json, src structure, etc.).
   - Define versioning: increment MAJOR for backward-incompatible principle additions/changes, MINOR for new minor guidelines, PATCH for wording fixes.
3. **Write and Report**:
   - Save the constitution to `.specify/memory/constitution.md` (or `.claude/spec-kit/constitution.md`).
   - Propagate changes: if principles change, check if `plan-template.md` or `tasks-template.md` require updates.
   - Output a **Sync Impact Report** detailing the version changes, modified principles, and a suggested git commit message.

---

## 2. `/speckit specify`
**Goal**: Create a feature specification (`spec.md`) under a new feature directory.

### Execution Flow:
1. **Parse Input**:
   - Verify feature description is provided. If empty, return an error.
   - Generate a concise short name (2–4 words, action-noun, e.g., `user-auth`, `analytics-dashboard`).
2. **Directory & Branch Resolution**:
   - Scan the `specs/` directory.
   - Check `.specify/init-options.json` for `"feature_numbering"` settings:
     - If `"timestamp"`: prefix is `YYYYMMDD-HHMMSS`.
     - If `"sequential"` or absent: prefix is `NNN` (next available 3-digit sequential number starting at `001`).
   - Create directory `specs/<prefix>-<short-name>/` (e.g., `specs/001-user-auth/`).
   - Write resolved directory to `.specify/feature.json` under the key `"feature_directory"`.
3. **Template Resolution & Generation**:
   - Resolve `spec-template.md` via the resolution hierarchy. Copy to `specs/<prefix>-<short-name>/spec.md`.
   - Incorporate the project's constitution principles if available.
   - Document assumptions and allow up to **3 [NEEDS CLARIFICATION] markers** for major ambiguities.
4. **Quality Checklist Validation**:
   - Generate `checklists/requirements.md` in the feature directory using `checklist-template.md`.
   - Validate that requirements are technology-agnostic (no frameworks or database types listed in the spec).
   - Save and report the feature directory path to the user.

---

## 3. `/speckit clarify`
**Goal**: Run an interactive Q&A loop to resolve ambiguity and update the `spec.md` before planning.

### Execution Flow:
1. **Ambiguity Scan**:
   - Load `spec.md` and check against the **10-Category Taxonomy**:
     1. Functional Scope & Behavior
     2. Domain & Data Model (Entities, relationships)
     3. Interaction & UX Flow (Journeys, error states)
     4. Quality Attributes (Latency, scalability targets)
     5. Security & Privacy (AuthN/Z, data protection)
     6. Compliance / Regulatory
     7. Integration & External Dependencies
     8. Edge Cases & Exception Handling
     9. Technical Constraints & Tradeoffs
     10. Terminology & Placeholders (TODO, TKTK)
2. **Sequential Questioning Loop**:
   - Queue up to **5 questions** based on high-priority gaps. Ask **EXACTLY ONE** at a time.
   - For multiple-choice questions, present a **prominent recommendation** with brief reasoning, followed by a Markdown options table.
   - For short answers, suggest a default answer.
3. **Spec Integration**:
   - After the user answers a question, immediately update `spec.md`.
   - Append to the `## Clarifications` section: `- Q: <question> → A: <final answer>`.
   - Propagate answers to respective sections of the spec.
   - Re-validate the `checklists/requirements.md` file, toggling resolved items to checked `[x]`.
4. **Loop Termination**:
   - End when all questions are resolved, the user types "done"/"stop", or 5 questions have been answered. Present a coverage summary table.

---

## 4. `/speckit plan`
**Goal**: Create technical design and contract documents in the active feature directory based on the spec.

### Execution Flow:
1. **Load Context**:
   - Retrieve feature path from `.specify/feature.json` or scan `specs/` for the latest folder.
   - Load `spec.md` and `.specify/memory/constitution.md` (handle missing constitution gracefully).
2. **Execute Plan Workflow**:
   - Resolve `plan-template.md` and copy to the feature directory as `plan.md`.
   - **Phase 0: Research**: Generate `research.md` documenting tech stack choices, spiking results, and alternatives considered.
   - **Phase 1: Design**: 
     - Generate `data-model.md` detailing entities, attributes, and relationships.
     - Generate interface specifications under a `/contracts/` directory (e.g. APIs, schemas).
     - Generate `quickstart.md` defining validation setups to verify end-to-end functionality.
3. **Constitution Compliance Gate**:
   - Evaluate all tech choices against `constitution.md`. Flag and justify any deviations.

---

## 5. `/speckit checklist`
**Goal**: Generate domain-specific requirements quality checklists ("Unit Tests for English").

### Execution Flow:
1. **Validate Purpose**:
   - **MUST NOT** verify code or implementation correctness (no "Verify button works").
   - **MUST** validate requirements completeness, clarity, measurability, and consistency.
   - *Example Correct*: "Are error response formats specified for all API failure modes? [Completeness]"
2. **Dynamic Calibration**:
   - Ask up to 3 context questions (Q1–Q3) to calibrate focus (e.g., UX focus vs API security focus).
3. **Create Checklist**:
   - Write to `checklists/[domain].md` (e.g., `ux.md`, `security.md`, `api.md`).
   - Group by quality dimensions (Completeness, Clarity, Consistency, Measurability).
   - Use checklist IDs like `CHK001`, `CHK002` etc. If the file exists, append new items continuing the ID numbering without deleting old ones.
   - Traceability: Ensure >=80% of items reference spec sections `[Spec §X.Y]` or gaps `[Gap]`.

---

## 6. `/speckit analyze`
**Goal**: Non-destructive consistency report cross-referencing spec, plan, tasks, and constitution.

### Execution Flow:
1. **Strict Read-Only**:
   - Do not modify any files.
2. **Semantic Checking**:
   - **Duplication**: Identify redundant requirements.
   - **Ambiguity**: Flag vague adjectives or placeholders.
   - **Underspecification**: Flag requirements with no mapped tasks, or tasks referencing files not defined in plan.md.
   - **Constitution**: Mark any principle violations as CRITICAL.
   - **Inconsistency**: Identify naming mismatches (e.g. "User" vs "Client").
3. **Report Generation**:
   - Display a Markdown report containing:
     - Analysis findings table with Severity (CRITICAL, HIGH, MEDIUM, LOW) and Recommendation.
     - Coverage statistics (e.g. "Requirements checked: 12, Coverage: 85%").
     - Next Actions block.

---

## 7. `/speckit tasks`
**Goal**: Generate a dependency-ordered, story-mapped `tasks.md` task list.

### Execution Flow:
1. **Task Breakdown**:
   - Load `plan.md`, `spec.md`, and `data-model.md`.
   - Group tasks into phases: Setup, Foundation, User Stories (one phase per story in priority order), and Polish.
2. **Format Constraint (STRICT)**:
   - Every task must strictly follow this exact format:
     ```markdown
     - [ ] [TaskID] [P?] [Story?] Description with target file path
     ```
     - `TaskID`: Sequential numbering (`T001`, `T002`...).
     - `[P]`: Include ONLY if task is parallelizable (different files, no dependency on incomplete tasks).
     - `[Story]`: Required for story tasks (e.g., `[US1]`).
     - Target file path must be specified.
     - *Example*: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
3. **Save**:
   - Resolve `tasks-template.md` and copy/save tasks list to `specs/<NNN>-<short-name>/tasks.md`.

---

## 8. `/speckit implement`
**Goal**: Execute the task list in `tasks.md` systematically.

### Execution Flow:
1. **Verify Prerequisites**:
   - Scan all checklist files under `checklists/`. If any checklist contains incomplete `[ ]` items, print a status table and request explicit user confirmation to proceed.
2. **Project Setup & Ignore Files**:
   - If git repository: verify/create `.gitignore`.
   - Detect tech stack and verify/create `.dockerignore`, `.eslintignore`, `.prettierignore`, or C#/.NET, Rust, and Python equivalents.
3. **Execution Loop**:
   - Process `tasks.md` task-by-task.
   - For each task, check off its box `[X]` in `tasks.md` upon completion.
   - Follow Test-Driven Development (TDD) if requested (write tests before implementation).
   - Report progress after each task. Halt if any sequential task fails.

---

## 9. `/speckit converge`
**Goal**: Check codebase implementation against spec, plan, and tasks. Append outstanding work to `tasks.md`.

### Execution Flow:
1. **Drift Assessment**:
   - Compare the current codebase state with `spec.md`, `plan.md`, and `tasks.md`.
   - Identify gaps and classify findings: `missing`, `partial`, `contradicts`, `unrequested`.
   - Assign severity: CRITICAL (violates constitution or blocks core story), HIGH, MEDIUM, LOW.
2. **Append-Only Contract**:
   - **NEVER** modify existing sections or code.
   - If gaps exist, append a new section `## Phase <N>: Convergence` at the bottom of `tasks.md`.
   - Add new sequential task IDs starting after the highest existing task ID.
   - *Example*: `- [ ] T045 Implement missing validation check per FR-008 (partial)`
   - If zero gaps are found, do not write anything. Report **"✅ Converged — the codebase is consistent with specs."**.

---

## 10. `/speckit taskstoissues`
**Goal**: Sync the task list in `tasks.md` to GitHub Issues using the GitHub CLI.

### Execution Flow:
1. **Verify Prerequisites & Git Remote**:
   - Ensure the repository has a git remote setup. Run `git config --get remote.origin.url`. If missing, output a warning.
   - Run `gh auth status` to check if user is logged into GitHub CLI. If authentication fails, output: `⚠️ Error: gh CLI is not authenticated. Please run "gh auth login" to sync tasks.` and halt.
2. **Sync Tasks**:
   - Read `tasks.md` and fetch current open issues on the repository using GitHub CLI or GitHub MCP `list_issues` (handling pagination) to prevent duplicates.
   - Create a GitHub issue for each incomplete task (or grouped by User Story).
   - Add titles containing the Task ID and labels matching the User Story tag.
   - Output a table of synced issues with their corresponding URLs.
