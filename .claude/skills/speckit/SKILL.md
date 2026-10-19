---
name: speckit
description: "Unified Spec-Driven Development (SDD) assistant implementing the GitHub Spec-Kit workflow. Run with subcommands: constitution, specify, clarify, plan, checklist, analyze, tasks, implement, converge, or taskstoissues."
argument-hint: "<subcommand> [args] (e.g., specify 'create a photo organizer')"
compatibility: "Works in any project directory. Detects and integrates with .specify/ project config if present."
metadata:
  author: "github-spec-kit"
  version: "1.2.0"
user-invocable: true
disable-model-invocation: false
---

# GitHub Spec-Kit: Unified Spec-Driven Development

This skill implements the complete Spec-Driven Development (SDD) workflow defined by [GitHub Spec-Kit](https://github.com/github/spec-kit). Instead of writing code directly from ad-hoc prompts ("vibe coding"), you will use a structured, predictable process:

```text
Constitution ──> Specify ──> Clarify ──> Plan ──> Checklist ──> Tasks ──> Analyze ──> Implement ──> Converge ──> TasksToIssues
```

---

## 🎮 Subcommand Router

When the user invokes this skill (e.g., `/speckit specify "build user auth"` or `/speckit plan`), parse the first argument as the **subcommand**:
- If the first word matches one of the subcommands below, route execution to the corresponding section (and consult [`./references/<subcommand>.md`](./references/) if detailed edge-case rules are needed).
- If no subcommand is specified, or if the argument is empty, display a concise usage guide explaining the 10 available subcommands and their workflow order.

---

## 🛡️ General Operating Guidelines & Fallbacks

1. **Path Normalization**: Always use absolute paths for file system edits and project-relative paths inside Markdown documentation.
2. **Native Tool Fallback (Self-Containment)**:
   Many spec-kit commands check prerequisites or resolve directories using local bash scripts under `.specify/scripts/bash/` (such as `check-prerequisites.sh`, `setup-plan.sh`, and `setup-tasks.sh`).
   - If these scripts are **missing** or fail to execute (e.g., on Windows without Git Bash or in a fresh repository), **you MUST NOT fail**.
   - Instead, fall back to native agent commands and filesystem tools to scan for files, read `.specify/feature.json`, find the latest folder in `specs/`, and copy/create templates directly.
3. **Constitution Graceful Handling**:
   - If `.specify/memory/constitution.md` is missing, output: `⚠️ Warning: Project constitution.md not found. Establishing core principles is highly recommended before specification and planning. Proceeding with default guidelines.`
   - Run the command without crashing, reminding the user they can run `/speckit constitution` to establish core principles.
4. **Extension Hooks**: If `.specify/extensions.yml` exists, check `hooks.before_<subcommand>` before execution and `hooks.after_<subcommand>` after execution. Skip hooks with `enabled: false` or non-empty `condition` fields. Output optional hooks (`optional: true`) as suggestions, and automatically execute mandatory hooks (`optional: false`) by emitting `EXECUTE_COMMAND: <command>` and invoking the command before continuing.
5. **Interactive Questions**: Whenever a subcommand asks clarifying questions (`specify`, `clarify`, `checklist`), prefer your agent environment's native interactive question tool (e.g., `ask_question` or `AskUserQuestion`) with the recommended option listed first; otherwise fall back to well-aligned Markdown tables.
6. **Progressive Disclosure**: When reading specifications or plans, read sections incrementally rather than pulling entire massive files into the prompt context at once.
7. **Template Resolution Priority**:
   When copying or reading templates, always resolve them in this priority order (highest to lowest):
   1. **Project-Local Overrides**: `.specify/templates/overrides/<name>-template.md`
   2. **Presets**: `.specify/presets/templates/<name>-template.md`
   3. **Extensions**: `.specify/extensions/templates/<name>-template.md`
   4. **Spec-Kit Core Defaults**: `.specify/templates/<name>-template.md`
   5. **Skill Bundled Fallback**: `./resources/templates/<name>-template.md` (relative to this `SKILL.md`)

---

## 1. `/speckit constitution`
**Goal**: Create or update the project's governing principles in `.specify/memory/constitution.md`.
*Detailed reference*: [`./references/constitution.md`](./references/constitution.md)

### Execution Flow:
1. **Initialize/Load**:
   - Check if `.specify/memory/constitution.md` exists. If not, `mkdir -p .specify/memory`, resolve `constitution-template.md` using the Template Resolution Priority, and copy it.
   - Identify all `[ALL_CAPS_IDENTIFIER]` placeholders (`[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`, `[CONSTITUTION_VERSION]`, `[RATIFICATION_DATE]`, `[LAST_AMENDED_DATE]`).
2. **Collect Inputs**:
   - Parse user arguments. If they contain specific principles, integrate them.
   - Otherwise, ask the user or infer principles based on the existing codebase (`README.md`, `package.json`, `src/` structure, etc.).
   - Define semantic versioning: increment **MAJOR** for backward-incompatible principle removals/redefinitions, **MINOR** for new principles/sections, **PATCH** for wording fixes.
3. **Write and Report**:
   - Ensure principles use declarative, testable normative language (`MUST` / `SHOULD`).
   - Prepend an HTML comment **Sync Impact Report** at the top of `.specify/memory/constitution.md` and save.
   - Propagate changes to dependent templates if needed and output version change summary + suggested commit message.

---

## 2. `/speckit specify`
**Goal**: Create a feature specification (`spec.md`) under a new feature directory.
*Detailed reference*: [`./references/specify.md`](./references/specify.md)

### Execution Flow:
1. **Parse Input**:
   - Verify feature description is provided. If empty, return an error asking for the feature description.
   - Generate a concise short name (2–4 words, action-noun, e.g., `user-auth`, `analytics-dashboard`).
2. **Directory & Branch Resolution**:
   - Scan the `specs/` directory (or use `SPECIFY_FEATURE_DIRECTORY` if explicitly provided).
   - Check `.specify/init-options.json` for `"feature_numbering"` settings:
     - If `"timestamp"`: prefix is `YYYYMMDD-HHMMSS`.
     - If `"sequential"` or absent: prefix is `NNN` (next available 3-digit sequential number starting at `001`).
   - Create directory `specs/<prefix>-<short-name>/` (e.g., `specs/001-user-auth/`).
   - Persist resolved directory to `.specify/feature.json`: `{"feature_directory": "specs/<prefix>-<short-name>"}`.
3. **Template Resolution & Generation**:
   - Resolve `spec-template.md` via the resolution hierarchy and copy to `specs/<prefix>-<short-name>/spec.md`.
   - Incorporate `.specify/memory/constitution.md` principles if available.
   - Populate `Overview`, `User Scenarios & Testing` (with priorities `P1`, `P2`, acceptance scenarios `US1/AC1`, and `Edge Cases`), `Functional Requirements` (`FR-001`...), `Key Entities`, `Success Criteria` (`SC-001`...), and `Assumptions & Out of Scope`.
   - Document assumptions and allow at most **3 `[NEEDS CLARIFICATION: ...]` markers** for major scope/security/UX ambiguities.
4. **Quality Checklist Validation**:
   - Generate `checklists/requirements.md` in the feature directory using `checklist-template.md`.
   - Validate that requirements and success criteria are technology-agnostic and testable. If any `[NEEDS CLARIFICATION]` markers remain (max 3), ask the user to resolve them and update `spec.md`.

---

## 3. `/speckit clarify`
**Goal**: Run an interactive Q&A loop to resolve ambiguity and update `spec.md` before planning.
*Detailed reference*: [`./references/clarify.md`](./references/clarify.md)

### Execution Flow:
1. **Ambiguity Scan**:
   - Load active `spec.md` (via `.specify/feature.json` or latest `specs/` folder) and scan against the **10-Category Taxonomy**:
     1. Functional Scope & Behavior
     2. Domain & Data Model (Entities, relationships, state transitions)
     3. Interaction & UX Flow (Journeys, error/empty/loading states)
     4. Non-Functional Quality Attributes (Latency, throughput, reliability, observability)
     5. Security & Privacy (AuthN/Z, data protection)
     6. Compliance / Regulatory
     7. Integration & External Dependencies
     8. Edge Cases & Failure Handling
     9. Technical Constraints & Tradeoffs
     10. Terminology, Completion Signals & Placeholders (`TODO`, `TKTK`)
2. **Sequential Questioning Loop**:
   - Queue up to **5 high-impact questions** (prioritized by `Impact * Uncertainty`). Ask **EXACTLY ONE** question at a time.
   - Use native interactive question UI (`ask_question` / `AskUserQuestion`) if available, or present a prominent `**Recommended:** Option [X] - <reasoning>` followed by a Markdown options table.
   - For short-answer questions (`<=5 words`), provide `**Suggested:** <answer> - <reasoning>`.
3. **Incremental Spec Integration**:
   - After EACH accepted answer, immediately update `spec.md`:
     - Record `- Q: <question> → A: <final answer>` under `## Clarifications` → `### Session YYYY-MM-DD`.
     - Update the corresponding section of `spec.md` (Requirements, User Stories, Data Model, Success Criteria, or Edge Cases), replacing any obsolete/ambiguous text.
   - Re-evaluate `checklists/requirements.md` (if present), toggling newly satisfied items to `[x]`.
4. **Loop Termination**:
   - Stop when all critical ambiguities are resolved, the user replies `"done"`/`"stop"`, or 5 questions are answered. Output a coverage summary table.

---

## 4. `/speckit plan`
**Goal**: Create technical design and contract documents in the active feature directory based on the spec.
*Detailed reference*: [`./references/plan.md`](./references/plan.md)

### Execution Flow:
1. **Load Context**:
   - Run `.specify/scripts/bash/setup-plan.sh --json` or resolve `FEATURE_DIR` via `.specify/feature.json` / `specs/`.
   - Load `spec.md` and `.specify/memory/constitution.md` (handle missing constitution gracefully).
2. **Execute Plan Workflow**:
   - Resolve `plan-template.md` and copy to `FEATURE_DIR/plan.md`.
   - **Phase 0: Research**: Generate `research.md` documenting tech stack decisions, rationale, and alternatives considered to resolve any technical unknowns.
   - **Phase 1: Design & Contracts**:
     - Generate `data-model.md` detailing entities, fields, validation rules, and relationships.
     - Generate interface specifications under `contracts/` (e.g., OpenAPI, CLI schemas, UI contracts) if the feature exposes external boundaries.
     - Generate `quickstart.md` defining runnable end-to-end validation scenarios (without dumping full implementation bodies).
3. **Constitution Compliance Gate**:
   - Evaluate all architecture choices against `constitution.md` in the `Constitution Check` section of `plan.md`. Flag and justify any deviations.

---

## 5. `/speckit checklist`
**Goal**: Generate domain-specific requirements quality checklists ("Unit Tests for English").
*Detailed reference*: [`./references/checklist.md`](./references/checklist.md)

### Execution Flow:
1. **Validate Purpose ("Unit Tests for English")**:
   - Checklists test **requirements quality**, NOT implementation behavior.
   - ❌ **PROHIBITED**: Items starting with "Verify", "Test", "Confirm", or checking code execution (e.g., "Verify button clicks correctly").
   - ✅ **REQUIRED**: Questions evaluating whether requirements are written clearly (e.g., `"Are error response formats specified for all API failure modes? [Completeness, Spec §FR-002]"`).
2. **Dynamic Calibration**:
   - Ask up to 3 clarifying questions (Q1–Q3) to calibrate scope, risk prioritization, and depth unless already clear from `$ARGUMENTS`.
3. **Create / Append Checklist**:
   - Write to `FEATURE_DIR/checklists/[domain].md` (e.g., `ux.md`, `security.md`, `api.md`).
   - Group by requirement quality dimensions: `Requirement Completeness`, `Requirement Clarity`, `Requirement Consistency`, `Acceptance Criteria Quality`, `Scenario & Edge Case Coverage`.
   - Use sequential IDs (`CHK001`, `CHK002`...). If the file already exists, **append** new items continuing from the last `CHK` ID without deleting existing items.
   - Ensure `>=80%` of items include a traceability tag (`[Spec §X.Y]`, `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`).

---

## 6. `/speckit analyze`
**Goal**: Non-destructive consistency report cross-referencing `spec.md`, `plan.md`, `tasks.md`, and `constitution.md`.
*Detailed reference*: [`./references/analyze.md`](./references/analyze.md)

### Execution Flow:
1. **Strict Read-Only**:
   - **NEVER** modify any files during analysis. Require `spec.md`, `plan.md`, and `tasks.md` to exist.
2. **Semantic Detection Passes**:
   - **Duplication**: Near-duplicate requirements across sections.
   - **Ambiguity**: Unquantified adjectives ("fast", "robust") or unresolved placeholders (`TODO`, `TKTK`).
   - **Underspecification**: Requirements missing measurable outcomes or tasks referencing undefined components.
   - **Constitution Alignment**: Any requirement, plan decision, or task conflicting with a `constitution.md` `MUST` principle (always **CRITICAL**).
   - **Coverage Gaps**: Requirements (`FR-###`, buildable `SC-###`) with zero mapped tasks, or unmapped tasks.
   - **Inconsistency**: Terminology drift, entity mismatches between `spec.md` and `plan.md`, or task ordering contradictions.
3. **Report Generation**:
   - Output a Markdown report with:
     - **Specification Analysis Report** table (`ID | Category | Severity | Location(s) | Summary | Recommendation`, max 50 rows).
     - **Coverage Summary Table** (`Requirement Key | Has Task? | Task IDs | Notes`).
     - **Metrics** (Total Requirements, Total Tasks, Coverage %, Critical Issues Count) and **Next Actions** (offering optional remediation edits upon user approval).

---

## 7. `/speckit tasks`
**Goal**: Generate a dependency-ordered, story-mapped `tasks.md` task list.
*Detailed reference*: [`./references/tasks.md`](./references/tasks.md)

### Execution Flow:
1. **Task Breakdown**:
   - Load `plan.md` (required), `spec.md` (required), and optional `data-model.md`, `contracts/`, `research.md`, `quickstart.md`, and `constitution.md`.
   - Organize tasks into phases:
     - **Phase 1**: Setup (project initialization)
     - **Phase 2**: Foundational (blocking prerequisites for all stories)
     - **Phase 3+**: User Stories in priority order (`P1`, `P2`, `P3`...) — each phase is an independently testable increment
     - **Final Phase**: Polish & Cross-Cutting Concerns
2. **Format Constraint (STRICT)**:
   - Every task MUST strictly follow this exact format:
     ```markdown
     - [ ] [TaskID] [P?] [Story?] Description with target file path
     ```
     - `TaskID`: Sequential ID (`T001`, `T002`, `T003`...).
     - `[P]`: Include ONLY if parallelizable (touches different files, no dependency on incomplete tasks).
     - `[Story]`: REQUIRED for User Story phases only (e.g., `[US1]`, `[US2]`); omit in Setup, Foundational, and Polish phases.
     - Target file path MUST be included in the description.
     - *Example*: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
3. **Save & Report**:
   - Resolve `tasks-template.md`, write `FEATURE_DIR/tasks.md`, and report total tasks, tasks per story, parallel opportunities, and suggested MVP scope.

---

## 8. `/speckit implement`
**Goal**: Execute the task list in `tasks.md` systematically.
*Detailed reference*: [`./references/implement.md`](./references/implement.md)

### Execution Flow:
1. **Verify Checklists Gate**:
   - Scan all files under `FEATURE_DIR/checklists/`. Count total, completed (`[X]`/`[x]`), and incomplete (`[ ]`) items and display a status table.
   - If any checklist has incomplete items, **STOP** and ask the user whether to proceed anyway before writing code.
2. **Project Setup & Ignore Files Verification**:
   - Verify/create `.gitignore` (if inside a Git repo) and stack-appropriate ignore files (`.dockerignore`, `.eslintignore`, `.prettierignore`, `.npmignore`, `.terraformignore`, `.helmignore`) covering build artifacts, dependencies (`node_modules/`, `.venv/`, `target/`), and `.env*` secrets.
3. **Phase-by-Phase Execution Loop**:
   - Execute `tasks.md` phase-by-phase, respecting sequential dependencies and running `[P]` tasks on independent files.
   - Follow TDD when test tasks exist (run test tasks before corresponding implementation tasks).
   - **Mark each completed task as `[X]` in `tasks.md` immediately upon completion.**
   - Halt and report diagnostics if any sequential task fails. Validate final implementation against `spec.md` and `plan.md`.

---

## 9. `/speckit converge`
**Goal**: Assess the current codebase against `spec.md`, `plan.md`, and `tasks.md`, and append any remaining unbuilt work to `tasks.md`.
*Detailed reference*: [`./references/converge.md`](./references/converge.md)

### Execution Flow:
1. **Drift Assessment**:
   - Require `spec.md`, `plan.md`, and `tasks.md` to exist. Build an intent inventory of `FR-###`, buildable `SC-###`, user-story acceptance scenarios, plan touch-points, and `constitution.md` `MUST` rules.
   - Inspect in-scope source files and classify every gap as: `missing`, `partial`, `contradicts`, or `unrequested`.
   - Assign severity: `CRITICAL` (violates constitution `MUST` or blocks `P1` story), `HIGH`, `MEDIUM`, or `LOW`.
   - Present the in-session `## Convergence Findings` table (`ID | Gap Type | Severity | Source | Evidence | Remaining Work`) and summary metrics before touching disk.
2. **Append-Only Contract**:
   - **NEVER** modify `spec.md`, `plan.md`, application source code, or existing lines in `tasks.md`.
   - If actionable findings exist (`tasks_appended` outcome):
     - Find highest existing task ID `M` and highest phase number `N-1`.
     - Append `## Phase N: Convergence` at the very bottom of `tasks.md`.
     - Emit items ordered `CRITICAL`/`HIGH` first with sequential IDs `T{M+1:03d}`:
       ```markdown
       - [ ] T042 <imperative description> per <source-ref> (<gap-type>)
       ```
   - If zero gaps are found (`converged` outcome):
     - Leave `tasks.md` **byte-for-byte unchanged** (no empty header) and report: **"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

---

## 10. `/speckit taskstoissues`
**Goal**: Sync incomplete tasks in `tasks.md` to GitHub Issues with deduplication.
*Detailed reference*: [`./references/taskstoissues.md`](./references/taskstoissues.md)

### Execution Flow:
1. **Verify Prerequisites & GitHub Remote Safety**:
   - Check `git config --get remote.origin.url`.
   - > [!CAUTION]
     > **ONLY PROCEED IF THE REMOTE IS A GITHUB URL. NEVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL.**
   - Verify either GitHub MCP server availability or GitHub CLI authentication (`gh auth status`).
2. **Deduplicate & Sync Incomplete Tasks**:
   - Extract incomplete tasks (`- [ ] T### ...`) from `tasks.md`.
   - Fetch existing open and closed issues (via GitHub MCP `list_issues` with `perPage: 100` or `gh issue list --state all --limit 200 --json number,title,url`).
   - Match existing issue titles against `\bT\d{3}\b` (word boundaries). Skip any task ID that already has a matching issue.
   - For each unsynced incomplete task, strip `- [ ]`, `[P]`, and `[US#]` markers and create an issue titled `T001: <description>` (attaching the user story label/context if applicable).
   - Output a summary table of created and skipped issues with their URLs.
