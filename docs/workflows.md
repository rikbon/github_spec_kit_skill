# Spec-Kit Workflow Runbook

This runbook provides a comprehensive operational reference for all **10 Spec-Kit subcommands**, detailing their prerequisites, inputs, execution steps, generated artifacts, and concrete usage examples.

---

## Quick Reference Matrix

| Order | Subcommand | Prerequisite Artifact(s) | Output / Modified Artifact(s) | Mutates Files? |
| :---: | :--- | :--- | :--- | :---: |
| **1** | [`constitution`](#1-constitution) | *(None — initializes if missing)* | `.specify/memory/constitution.md` | Yes |
| **2** | [`specify`](#2-specify) | `.specify/memory/constitution.md` *(optional)* | `specs/<NNN>-<short-name>/spec.md`<br>`specs/<NNN>-<short-name>/checklists/requirements.md`<br>`.specify/feature.json` | Yes |
| **3** | [`clarify`](#3-clarify) | `specs/<NNN>-<short-name>/spec.md` | Updates `spec.md` (`## Clarifications` + sections)<br>Updates `checklists/requirements.md` | Yes |
| **4** | [`plan`](#4-plan) | `specs/<NNN>-<short-name>/spec.md` | `plan.md`, `research.md`, `data-model.md`, `contracts/*`, `quickstart.md` | Yes |
| **5** | [`checklist`](#5-checklist) | `spec.md` (`plan.md`, `tasks.md` optional) | `specs/<NNN>-<short-name>/checklists/<domain>.md` | Yes (Append-Only) |
| **6** | [`tasks`](#6-tasks) | `plan.md`, `spec.md` (`data-model.md`, `contracts/` optional) | `specs/<NNN>-<short-name>/tasks.md` | Yes |
| **7** | [`analyze`](#7-analyze) | `spec.md`, `plan.md`, `tasks.md` | In-session Markdown Consistency Report | **No (Read-Only)** |
| **8** | [`implement`](#8-implement) | `tasks.md`, `plan.md`, `checklists/*` | Application source code, ignore files, `[X]` checkboxes in `tasks.md` | Yes |
| **9** | [`converge`](#9-converge) | Implemented codebase + `spec.md`, `plan.md`, `tasks.md` | Appends `## Phase N: Convergence` to `tasks.md` (if gaps exist) | Yes (Append-Only) |
| **10** | [`taskstoissues`](#10-taskstoissues) | `tasks.md` + GitHub remote (`origin`) | GitHub Issues (`T001: <description>`) | External (GitHub) |

---

## Phase-by-Phase Detailed Walkthrough

### 1. `constitution`
**Purpose**: Author or amend the project's governing architectural principles, technical constraints, and compliance rules in `.specify/memory/constitution.md`.

- **Unified Invocation**: `/speckit constitution [principles or amendment guidance]`
- **Granular Invocation**: `/speckit-constitution [principles or amendment guidance]`

#### Execution Behavior:
1. Resolves `.specify/memory/constitution.md` (initializing from `constitution-template.md` if absent).
2. Extracts values from user arguments or infers principles from existing repository context (`README.md`, `package.json`, `pyproject.toml`, directory layout).
3. Enforces declarative, testable rules using normative keywords (`MUST`, `MUST NOT`, `SHOULD`).
4. Applies Semantic Versioning (`MAJOR.MINOR.PATCH`) based on change scope and prepends an HTML **Sync Impact Report** comment block at the top of `constitution.md`.

#### Example:
```text
/speckit constitution "1. Strict TypeScript (no implicit any). 2. Contract-first REST APIs documented with OpenAPI 3.1. 3. Minimum 85% unit test coverage using Vitest before PR merge."
```

---

### 2. `specify`
**Purpose**: Translate a natural-language feature request into a structured, technology-agnostic functional specification (`spec.md`) and an initial quality checklist (`checklists/requirements.md`).

- **Unified Invocation**: `/speckit specify "<feature description>"`
- **Granular Invocation**: `/speckit-specify "<feature description>"`

#### Execution Behavior:
1. Derives a concise 2–4 word action-noun short name (e.g., `oauth2-user-login`, `invoice-pdf-export`).
2. Checks `.specify/init-options.json` for `"feature_numbering"` (`"sequential"` → `001`, `002`... or `"timestamp"` → `YYYYMMDD-HHMMSS`) and creates `specs/<prefix>-<short-name>/`.
3. Persists the active directory path to `.specify/feature.json`:
   ```json
   {
     "feature_directory": "specs/001-invoice-pdf-export"
   }
   ```
4. Populates `spec.md` with prioritized User Stories (`P1`, `P2`, `P3`), Given/When/Then acceptance scenarios (`US1/AC1`), Functional Requirements (`FR-001`...), Key Entities, measurable Success Criteria (`SC-001`...), and Assumptions/Out-of-Scope boundaries.
5. Marks at most **3 critical ambiguities** with `[NEEDS CLARIFICATION: ...]` and generates `checklists/requirements.md` to validate spec readiness.

#### Example:
```text
/speckit specify "Allow billing administrators to export monthly customer invoices as branded PDF documents with itemized tax breakdowns and batch ZIP download support."
```

---

### 3. `clarify`
**Purpose**: Detect underspecified areas in the active `spec.md` across a 10-category taxonomy and resolve them through a focused, one-question-at-a-time interactive loop.

- **Unified Invocation**: `/speckit clarify [optional focus area]`
- **Granular Invocation**: `/speckit-clarify [optional focus area]`

#### Execution Behavior:
1. Scans `spec.md` across 10 engineering categories: *Functional Scope, Domain & Data Model, Interaction & UX Flow, Non-Functional Attributes, Security & Privacy, Compliance, External Integrations, Edge Cases, Constraints & Tradeoffs, and Terminology*.
2. Prioritizes up to **5 high-impact questions** (`Impact × Uncertainty`) and presents **exactly one question at a time** using the agent's native interactive question UI (`ask_question` / `AskUserQuestion`) or a Markdown table with a highlighted `**Recommended:**` option.
3. Immediately after each user response, records `- Q: <question> → A: <answer>` under `## Clarifications` (`### Session YYYY-MM-DD`), updates the relevant sections of `spec.md` on disk, and re-evaluates `checklists/requirements.md`.

#### Example:
```text
/speckit clarify "Focus on batch export limits and failure handling"
```

---

### 4. `plan`
**Purpose**: Translate the clarified functional specification into a concrete technical architecture blueprint (`plan.md`), research log (`research.md`), entity schema (`data-model.md`), interface contracts (`contracts/`), and end-to-end validation guide (`quickstart.md`).

- **Unified Invocation**: `/speckit plan [tech stack or architectural guidance]`
- **Granular Invocation**: `/speckit-plan [tech stack or architectural guidance]`

#### Execution Behavior:
1. Copies `plan-template.md` to `specs/<NNN>-<short-name>/plan.md` and evaluates the **Constitution Check** gate against `.specify/memory/constitution.md`.
2. **Phase 0 (`research.md`)**: Investigates technical unknowns, library comparisons, and performance trade-offs, recording structured `Decision / Rationale / Alternatives Considered` entries.
3. **Phase 1 (`data-model.md`, `contracts/`, `quickstart.md`)**:
   - Extracts domain entities, fields, validation constraints, and state transitions into `data-model.md`.
   - Defines external API/CLI/UI interface specifications under `contracts/`.
   - Writes runnable verification commands and expected outcomes in `quickstart.md`.

#### Example:
```text
/speckit plan "Use Node.js 22 with TypeScript, PDFKit for streaming PDF generation, Archiver for ZIP streaming, and PostgreSQL with Drizzle ORM."
```

---

### 5. `checklist`
**Purpose**: Generate domain-specific requirements quality checklists (*"Unit Tests for English"*) under `specs/<NNN>-<short-name>/checklists/<domain>.md`.

- **Unified Invocation**: `/speckit checklist "<domain or focus area>"`
- **Granular Invocation**: `/speckit-checklist "<domain or focus area>"`

#### Execution Behavior:
1. Calibrates scope and rigor by asking up to 3 brief context questions (if not already clear from arguments).
2. Creates or appends to `checklists/<domain>.md` (e.g., `security.md`, `ux.md`, `api.md`, `performance.md`) using globally sequential IDs (`CHK001`, `CHK002`...).
3. Enforces the **"Unit Tests for English"** rule: every item must question the *quality of the written requirements* (`Completeness`, `Clarity`, `Consistency`, `Measurability`, `Coverage`), with `>=80%` including traceability markers (`[Spec §FR-002]`, `[Gap]`, `[Ambiguity]`).

#### Example:
```text
/speckit checklist "security and tenant data isolation"
```

---

### 6. `tasks`
**Purpose**: Convert `plan.md`, `spec.md`, `data-model.md`, and `contracts/` into an executable, dependency-ordered task backlog in `specs/<NNN>-<short-name>/tasks.md`.

- **Unified Invocation**: `/speckit tasks [optional constraints or TDD preference]`
- **Granular Invocation**: `/speckit-tasks [optional constraints or TDD preference]`

#### Execution Behavior:
1. Organizes tasks into a strict multi-phase hierarchy:
   - **Phase 1: Setup** (project initialization & dependencies)
   - **Phase 2: Foundational** (shared blocking infrastructure)
   - **Phase 3+: User Stories** (one phase per User Story in priority order `P1`, `P2`, `P3`..., each independently testable)
   - **Final Phase: Polish & Cross-Cutting Concerns**
2. Formats every task using the mandatory checklist grammar:
   ```markdown
   - [ ] T012 [P] [US1] Implement InvoicePdfGenerator service in src/services/invoice-pdf.ts
   ```
   where `[P]` denotes tasks that touch independent files and can run concurrently, and `[US#]` maps story-phase tasks to their User Story.

#### Example:
```text
/speckit tasks "Include unit and contract test tasks before implementation (TDD)"
```

---

### 7. `analyze`
**Purpose**: Perform a strictly **read-only**, cross-artifact consistency and coverage audit across `spec.md`, `plan.md`, `tasks.md`, and `constitution.md` before implementation begins.

- **Unified Invocation**: `/speckit analyze [optional focus area]`
- **Granular Invocation**: `/speckit-analyze [optional focus area]`

#### Execution Behavior:
1. Builds an internal semantic inventory of all `FR-###`, buildable `SC-###`, user-story acceptance scenarios, plan touch-points, task IDs, and constitutional rules.
2. Runs 6 detection passes: *Duplication, Ambiguity, Underspecification, Constitution Alignment, Coverage Gaps, and Terminology/Entity Inconsistency*.
3. Outputs a severity-ranked (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`) **Specification Analysis Report** table, a **Coverage Summary Table**, and remediation recommendations without modifying any files.

#### Example:
```text
/speckit analyze
```

---

### 8. `implement`
**Purpose**: Execute the implementation plan systematically by processing tasks in `tasks.md` phase-by-phase.

- **Unified Invocation**: `/speckit implement [optional phase or task filter]`
- **Granular Invocation**: `/speckit-implement [optional phase or task filter]`

#### Execution Behavior:
1. **Checklist Gate**: Scans `specs/<NNN>-<short-name>/checklists/*.md` and displays a pass/fail table. If any checklist contains unchecked `[ ]` items, halts and asks for explicit user confirmation before proceeding.
2. **Ignore Files Verification**: Detects project stack and verifies/creates `.gitignore`, `.dockerignore`, `.eslintignore`, `.prettierignore`, etc.
3. **Task Execution Loop**: Executes tasks in phase order, respecting sequential file dependencies, running tests before implementation when TDD tasks are present, and checking off completed items (`- [X] T001 ...`) in `tasks.md` in real time.

#### Example:
```text
/speckit implement "Complete Phase 1 through Phase 3 (MVP User Story 1)"
```

---

### 9. `converge`
**Purpose**: Audit the current codebase implementation against `spec.md`, `plan.md`, `tasks.md`, and `constitution.md`, appending any remaining unbuilt or drifting work to the bottom of `tasks.md`.

- **Unified Invocation**: `/speckit converge`
- **Granular Invocation**: `/speckit-converge`

#### Execution Behavior:
1. Inspects all source files in scope and classifies discrepancies into four gap types:
   - `missing`: Required functionality is absent from the codebase.
   - `partial`: Functionality exists but does not fully satisfy acceptance criteria.
   - `contradicts`: Implementation conflicts with `spec.md`, `plan.md`, or a `constitution.md` `MUST` rule.
   - `unrequested`: Code exists that was not specified in the artifacts.
2. Prints an in-session `## Convergence Findings` summary table graded by severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`).
3. **Append-Only Contract**:
   - Never modifies source code, `spec.md`, `plan.md`, or existing lines in `tasks.md`.
   - If actionable gaps exist, appends `## Phase N: Convergence` at the end of `tasks.md` with new sequential task IDs (`T{M+1:03d}`), ready for a follow-up `/speckit implement` pass.
   - If zero gaps exist, leaves `tasks.md` byte-for-byte unchanged and reports: `✅ Converged — the implementation satisfies the spec, plan, and tasks.`

#### Example:
```text
/speckit converge
```

---

### 10. `taskstoissues`
**Purpose**: Synchronize incomplete tasks (`- [ ]`) from `tasks.md` to GitHub Issues with automatic deduplication.

- **Unified Invocation**: `/speckit taskstoissues [optional label or filter]`
- **Granular Invocation**: `/speckit-taskstoissues [optional label or filter]`

#### Execution Behavior:
1. Verifies `git config --get remote.origin.url` points to a valid GitHub repository (aborting immediately if not).
2. Queries existing open and closed issues via the **GitHub MCP Server** (`list_issues`) or **GitHub CLI** (`gh issue list --state all`) and matches titles against `\bT\d{3}\b` to prevent duplicate issue creation on re-runs.
3. Creates a GitHub Issue titled `T001: <description>` for each unsynced incomplete task and outputs a summary table with issue URLs.

#### Example:
```text
/speckit taskstoissues
```
