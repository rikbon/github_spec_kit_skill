# Spec-Kit workflows

This document provides a detailed breakdown of each phase in the Spec-Driven Development (SDD) lifecycle and how to trigger them using the Spec-Kit Claude Code skills.

---

## 🧭 Workflow Subcommands

Whether you are using the unified command (`/speckit <subcommand>`) or granular commands (`/speckit-<subcommand>`), the execution flow remains identical:

| Subcommand | Output File / Path | Purpose |
| :--- | :--- | :--- |
| `constitution` | `.specify/memory/constitution.md` | Establishes project coding rules, constraints, and architecture guardrails. |
| `specify` | `specs/<NNN>-<name>/spec.md` | Documents functional specifications, scenarios, and out-of-scope boundaries. |
| `clarify` | Modifies active `spec.md` | Starts interactive questioning to reduce ambiguity before planning. |
| `plan` | `specs/<NNN>-<name>/plan.md` | Builds technical architecture, data models, and API contracts. |
| `checklist` | `specs/<NNN>-<name>/checklists/` | Generates quality check files ("Unit Tests for English"). |
| `analyze` | Console Output (Read-Only) | Validates cross-artifact consistency and highlights coverage gaps. |
| `tasks` | `specs/<NNN>-<name>/tasks.md` | Generates a sequential, checklist-formatted task backlog. |
| `implement` | Codebase changes | Systematically runs through tasks, implementing and validating code. |
| `converge` | Appends tasks to `tasks.md` | Audits codebase state against specs and appends outstanding work. |
| `taskstoissues` | GitHub Issues created | Syncs the task list in `tasks.md` to GitHub Issues via the GitHub CLI. |

---

## 🏃 Detailed Walkthrough

### Step 1: `/speckit constitution`
Use this command at the beginning of a project to set standard rules. Claude Code will help you fill out core principles:
```text
/speckit constitution "Enforce strict TypeScript, REST API standards, and mandatory Vitest unit coverage above 90%."
```

### Step 2: `/speckit specify`
Define functional goals without touching implementation details. Specify actors, user stories, and acceptance scenarios:
```text
/speckit specify "Develop a Markdown editor containing live previews, export to HTML, and local autosave features."
```

### Step 3: `/speckit clarify`
Run this command to find ambiguities. Claude Code will scan the specification and ask up to 5 multiple-choice questions:
```text
/speckit clarify
```
*Example question*: "Should autosave happen on keypress, or debounced by a specific duration (e.g., 2 seconds)?"

### Step 4: `/speckit plan`
Now specify the tech stack and implementation design. This generates `plan.md`, `data-model.md`, and any schemas in `contracts/`:
```text
/speckit plan "Use React with Tailwind CSS, localstorage for autosave, and marked.js for markdown parsing."
```

### Step 5: `/speckit checklist`
Validate requirements quality. Generates domain-specific checklist files ensuring non-functional areas (like security and UX consistency) are properly specified:
```text
/speckit checklist "security"
```

### Step 6: `/speckit tasks`
Generate the implementation backlog. This translates your technical design into checkbox items:
```text
/speckit tasks
```

### Step 7: `/speckit analyze`
Before writing code, verify that every requirement maps to a task and there are no constitution violations:
```text
/speckit analyze
```

### Step 8: `/speckit implement`
Let Claude Code process the backlog. It will check off each task in `tasks.md` as it writes files and runs tests:
```text
/speckit implement
```

### Step 9: `/speckit converge`
If implementation is interrupted or feature drift occurs, check consistency and append missing items:
```text
/speckit converge
```
If no drift is found, it reports **"✅ Converged"**.

### Step 10: `/speckit taskstoissues`
Sync the outstanding tasks in `tasks.md` directly to your GitHub repository as issues:
```text
/speckit taskstoissues
```
Note that this requires you to have the GitHub CLI (`gh`) installed and authenticated.
