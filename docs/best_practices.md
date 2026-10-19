# SDD Engineering Best Practices Guide

The reliability of AI-generated software is directly proportional to the precision of the specifications and constraints governing the agent. This guide codifies proven engineering practices for each stage of the **Spec-Kit** workflow.

---

## 1. Authoring Effective Project Constitutions (`constitution.md`)

Your `.specify/memory/constitution.md` is the architectural bedrock of the repository. Every `/speckit plan`, `/speckit analyze`, and `/speckit converge` run evaluates compliance against this file.

### Do's and Don'ts
- **Use Normative RFC-2119 Keywords**: State rules using explicit `MUST`, `MUST NOT`, and `SHOULD` clauses so `/speckit analyze` and `/speckit converge` can deterministically classify violations as `CRITICAL`.
- **Keep Principles Testable & Verifiable**:
  - *Weak*: "Write clean, maintainable code and good tests."
  - *Strong*: "All domain services under `src/services/` MUST have unit tests with >=85% branch coverage using Vitest, and MUST NOT import HTTP request/response objects directly."
- **Include Explicit Rationale**: Briefly state *why* each constraint exists so the agent makes aligned trade-offs when encountering edge cases.

---

## 2. Writing Technology-Agnostic Specifications (`spec.md`)

A functional specification defines **WHAT** the system must do and **WHY** users need it—never **HOW** it is implemented internally.

### Key Rules
1. **Zero Tech-Stack Leakage**: Never mention programming languages, frameworks, database engines, or caching layers in `spec.md` (unless the product itself is a developer tool or SDK). Save technical choices for `/speckit plan`.
2. **Prioritize User Stories Independently (`P1`, `P2`, `P3`)**:
   - `P1` represents the Minimum Viable Product (MVP) slice.
   - Each User Story should be vertically sliceable so `/speckit tasks` can generate an independently testable phase for it.
3. **Write Quantifiable Success Criteria (`SC-###`)**:
   | Anti-Pattern (Vague or Implementation-Coupled) | Best Practice (Measurable & User-Centric) |
   | :--- | :--- |
   | "Redis cache hit ratio must exceed 85%." | "**SC-001**: 95% of product catalog searches return results in under 500ms." |
   | "React components should render smoothly." | "**SC-002**: Users can filter 1,000 log entries with zero input lag (<16ms frame time)." |
   | "The system should be easy to use." | "**SC-003**: First-time users complete onboarding without errors in under 2 minutes." |
4. **Bound Scope Explicitly**: Always populate `Out of Scope` in `spec.md` soneither `/speckit plan` nor `/speckit implement` over-engineers unrequested features.

---

## 3. Resolving Ambiguities Early (`/speckit clarify`)

- **Never Skip Clarification on Complex Features**: Unresolved `[NEEDS CLARIFICATION]` markers in `spec.md` cause exponential rework if deferred to `/speckit implement`.
- **Focus on High-Impact Categories**: Prioritize questions around *Security/Privacy*, *Data Lifecycle & Uniqueness*, *Failure/Recovery Flows*, and *Scope Boundaries* over minor UI copy details.

---

## 4. Designing "Unit Tests for English" (`/speckit checklist`)

Checklists in Spec-Kit (`specs/<NNN>-<feature>/checklists/*.md`) are **not** QA test plans for checking whether the application works; they are **unit tests for the requirements documents themselves**.

| Dimension | ❌ Wrong (Tests Implementation Behavior) | ✅ Correct (Tests Requirements Quality) |
| :--- | :--- | :--- |
| **Completeness** | "Verify the export endpoint returns a CSV file." | "Are column ordering, delimiter escaping, and UTF-8 BOM rules specified for CSV exports? `[Completeness, Spec §FR-004]`" |
| **Clarity** | "Test that large uploads fail gracefully." | "Is the maximum file upload size quantified in megabytes along with the exact user-facing error state? `[Clarity, Spec §FR-007]`" |
| **Consistency** | "Check that user roles work across pages." | "Are role names (`Admin` vs `Owner`) used consistently across User Stories and Functional Requirements? `[Consistency, Spec §2]`" |
| **Coverage** | "Confirm retry logic works when Stripe fails." | "Are idempotency and rollback requirements defined when payment webhook delivery fails mid-transaction? `[Coverage, Gap]`" |

---

## 5. Structuring Actionable Task Backlogs (`/speckit tasks`)

When reviewing or refining `tasks.md`:
1. **Strict Task Grammar**: Every task line must follow:
   ```markdown
   - [ ] T014 [P] [US1] Implement InvoiceRepository in src/repositories/invoice-repository.ts
   ```
2. **Use `[P]` Conservatively**: Only mark a task as parallelizable `[P]` if it modifies a distinct file path and does not depend on types or interfaces being created by another incomplete task in the same phase.
3. **One Target File Path Per Task**: Avoid broad tasks that touch 10 unrelated files. Granular tasks allow `/speckit implement` to validate and check off progress deterministically.

---

## 6. Running the Implementation & Convergence Loop

1. **Pass the Checklist Gate First**: Complete all items in `checklists/*.md` before running `/speckit implement`.
2. **Deliver Incrementally by Phase**: For large features, run `/speckit implement "Phase 1 to Phase 3 (US1 MVP)"`, verify the MVP using `quickstart.md`, and then implement subsequent user story phases.
3. **Always Run `/speckit converge` Before Opening a PR**:
   - After `/speckit implement` finishes, run `/speckit converge` to verify that no acceptance scenario or constitutional rule was missed or only partially satisfied.
   - If `/speckit converge` appends a `## Phase N: Convergence` section to `tasks.md`, run `/speckit implement` again to close the remaining tasks, then re-run `/speckit converge` until it reports `✅ Converged`.
