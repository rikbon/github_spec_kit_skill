# Introduction to Spec-Driven Development (SDD)

**Spec-Driven Development (SDD)** is a disciplined software engineering methodology purpose-built for AI-assisted development. Instead of treating natural-language prompts as disposable chat messages, SDD elevates **specifications, architectural plans, requirements checklists, and task backlogs** into structured, version-controlled engineering artifacts that govern how AI coding agents build software.

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                        CONSTITUTION (constitution.md)                        │
│       Non-negotiable architectural principles, constraints & standards       │
└──────────────┬───────────────────────────────┬───────────────────────────────┘
               │ governs                       │ gates
               ▼                               ▼
     ┌───────────────────┐           ┌───────────────────┐
     │   SPECIFICATION   │ ────────> │  TECHNICAL PLAN   │
     │     (spec.md)     │  clarify  │     (plan.md)     │
     │  WHAT & WHY only  │           │   HOW & stack     │
     └─────────┬─────────┘           └─────────┬─────────┘
               │                               │
               └───────────────┬───────────────┘
                               │ decomposes into
                               ▼
                     ┌───────────────────┐
                     │   TASK BACKLOG    │ <───────┐
                     │    (tasks.md)     │         │ appends drift
                     └─────────┬─────────┘         │
                               │ executes          │
                               ▼                   │
                     ┌───────────────────┐   ┌─────┴─────────────┐
                     │     CODEBASE      │ ─>│    CONVERGENCE    │
                     │  Implementation   │   │  Audit & Verify   │
                     └───────────────────┘   └───────────────────┘
```

---

## SDD vs. Ad-Hoc Prompting ("Vibe Coding")

Traditional AI-assisted coding often degrades as features grow in complexity because architectural context is trapped in ephemeral chat history. SDD solves this by externalizing state into deterministic repository files:

| Dimension | Ad-Hoc Prompting ("Vibe Coding") | Spec-Driven Development (SDD) |
| :--- | :--- | :--- |
| **Source of Truth** | Ephemeral chat history; lost on context compaction. | Version-controlled Markdown artifacts under `.specify/` and `specs/`. |
| **Requirement Clarity** | Agent silently guesses unstated edge cases. | Explicit `[NEEDS CLARIFICATION]` markers and structured 5-question `/speckit clarify` loop. |
| **Concern Separation** | Product goals and framework choices mixed together. | Strict boundary: `spec.md` defines **WHAT/WHY**; `plan.md` defines **HOW**. |
| **Governance** | Agent introduces arbitrary libraries or patterns. | Every plan must pass the **Constitution Compliance Gate** against `constitution.md`. |
| **Execution Granularity** | Monolithic code generation prone to partial completion. | Phased, story-mapped task checklist (`T001`, `[P]`, `[US1]`) with explicit target file paths. |
| **Quality Assurance** | Manual spot-checking after code is written. | Pre-implementation `/speckit checklist` & `/speckit analyze`, plus post-implementation `/speckit converge`. |

---

## The Four Pillars of Spec-Kit

### 1. Constitutional Governance (`constitution.md`)
Every repository has architectural invariants—whether that means strict TypeScript typing, test-first development, specific database adapters, or security compliance rules. `.specify/memory/constitution.md` codifies these rules using normative `MUST` and `SHOULD` statements. Downstream commands (`/speckit plan`, `/speckit analyze`, `/speckit converge`) treat constitutional violations as **CRITICAL** blockers.

### 2. Separation of Problem Space and Solution Space
A common failure mode in software engineering is premature optimization—designing database tables before understanding user workflows.
- **Problem Space (`spec.md`)**: Written for product stakeholders. Describes user stories (`P1`, `P2`, `P3`), Given/When/Then acceptance scenarios (`US1/AC1`), testable functional requirements (`FR-001`), and technology-agnostic success criteria (`SC-001`). Mentioning frameworks or databases in `spec.md` is explicitly flagged as a validation failure.
- **Solution Space (`plan.md`, `research.md`, `data-model.md`, `contracts/`)**: Translates validated requirements into concrete technology decisions, entity schemas, API contracts, and runnable end-to-end validation steps (`quickstart.md`).

### 3. Requirements Validation Before Code ("Unit Tests for English")
Fixing an ambiguous requirement in `spec.md` takes seconds; fixing an architectural flaw after 3,000 lines of code have been generated takes hours. Spec-Kit introduces two pre-implementation quality gates:
- **`/speckit checklist`**: Generates domain-specific checklists (`ux.md`, `security.md`, `api.md`) that test whether the *requirements themselves* are complete, unambiguous, and measurable.
- **`/speckit analyze`**: Performs a read-only semantic audit across `spec.md`, `plan.md`, `tasks.md`, and `constitution.md` to uncover unmapped requirements, terminology drift, or conflicting constraints.

### 4. Traceable Execution & Closed-Loop Convergence
When `/speckit tasks` generates `tasks.md`, tasks are organized into independent User Story phases (`[US1]`, `[US2]`), annotated for safe concurrency (`[P]`), and tied to exact file paths. After `/speckit implement` executes the backlog, `/speckit converge` inspects the actual codebase against the specification and plan—appending any `missing`, `partial`, `contradicts`, or `unrequested` gaps directly to `tasks.md` as a new `## Phase N: Convergence` section until zero drift remains.

---

## End-to-End Traceability Matrix

Every artifact in the Spec-Kit workflow links deterministically to upstream and downstream artifacts:

| Identifier Format | Artifact Origin | Referenced By | Example |
| :--- | :--- | :--- | :--- |
| **`Principle I..N`** | `.specify/memory/constitution.md` | `plan.md`, `analyze`, `converge` | `Principle II: Mandatory Contract Testing` |
| **`US1`, `US1/AC1`** | `specs/<NNN>-<feature>/spec.md` | `tasks.md`, `analyze`, `converge` | `[US1]` story phase label in `tasks.md` |
| **`FR-001` .. `FR-NNN`** | `specs/<NNN>-<feature>/spec.md` | `checklist`, `analyze`, `converge` | `- [ ] T042 Add rate limiting per FR-008 (missing)` |
| **`SC-001` .. `SC-NNN`** | `specs/<NNN>-<feature>/spec.md` | `quickstart.md`, `analyze`, `converge` | `SC-001: 95% of queries complete under 200ms` |
| **`CHK001` .. `CHK-NNN`** | `specs/<NNN>-<feature>/checklists/*.md` | `implement` prerequisite gate | `- [x] CHK004 Are error states defined? [Coverage, Spec §2]` |
| **`T001` .. `T-NNN`** | `specs/<NNN>-<feature>/tasks.md` | `implement`, `converge`, `taskstoissues` | `GitHub Issue: "T012: Create User model in src/models/user.py"` |
