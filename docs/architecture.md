# Architecture and Customization

The Spec-Kit Multi-Agent Skill Suite is designed to be highly customizable, supporting templates and event-driven extension hooks.

---

## Project Structure

When initialized, Spec-Kit projects adhere to the following directory structure:

```
├── .claude/ or .agents/ or .opencode/
│   └── skills/                  # Agent skill definitions (with references/, resources/, scripts/)
├── .specify/
│   ├── memory/
│   │   └── constitution.md      # Governing principles
│   ├── scripts/
│   │   └── bash/                # Prerequisite & context setup scripts
│   │       ├── check-prerequisites.sh
│   │       ├── setup-plan.sh
│   │       └── setup-tasks.sh
│   ├── templates/               # Preset overrides & core templates
│   │   ├── checklist-template.md
│   │   ├── constitution-template.md
│   │   ├── plan-template.md
│   │   ├── spec-template.md
│   │   └── tasks-template.md
│   └── extensions.yml           # Hook registry
└── specs/                       # Feature specifications and plans
    └── 001-create-taskify/
        ├── checklists/          # Requirements checklists
        ├── contracts/           # API and data contracts
        ├── data-model.md
        ├── plan.md
        ├── quickstart.md
        ├── research.md
        ├── spec.md
        └── tasks.md
```

---

## Extension Hooks

Spec-Kit supports pre-execution and post-execution hooks configured in `.specify/extensions.yml`. These hooks automate processes like committing code to Git, checking prerequisites, or triggering external audits.

### Hook Event Types
Each of the 10 commands checks for event hooks in `.specify/extensions.yml` before (pre-execution) and after (post-execution) execution:
- `before_constitution` / `after_constitution`
- `before_specify` / `after_specify`
- `before_clarify` / `after_clarify`
- `before_plan` / `after_plan`
- `before_checklist` / `after_checklist`
- `before_analyze` / `after_analyze`
- `before_tasks` / `after_tasks`
- `before_implement` / `after_implement`
- `before_converge` / `after_converge`
- `before_taskstoissues` / `after_taskstoissues`

### Hook Example Configuration
```yaml
hooks:
  before_specify:
    - name: "Git Branching"
      command: "speckit.git.branch"
      description: "Creates a feature branch based on short name"
      optional: false
  after_implement:
    - name: "Linter"
      command: "npm run lint"
      description: "Verifies code quality post-implementation"
      optional: true
```

---

## Template Resolution

When copying templates (e.g., spec template, plan template, task template), the skill resolves paths in the following priority order:

1. **Project-Local Overrides**: `.specify/templates/overrides/`
2. **Presets**: `.specify/presets/templates/`
3. **Extensions**: `.specify/extensions/templates/`
4. **Spec-Kit Core Defaults**: `.specify/templates/`
5. **Skill Bundled Fallback**: `resources/templates/` (bundled inside the unified skill package for global installs)

This allows you to change functional requirements structures or stack templates project-by-project without altering the global skills configuration.
