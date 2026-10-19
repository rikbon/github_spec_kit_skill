# System Architecture & Customization Reference

The **Spec-Kit Multi-Agent Skill Suite** is engineered around modular progressive disclosure, multi-tier template resolution, native fallback resilience, and event-driven extension hooks.

---

## 1. Repository & Workspace Directory Structure

When initialized in a project, Spec-Kit organizes agent skills, project-wide configuration, and feature-scoped artifacts into three distinct directory trees:

```text
<project-root>/
├── .claude/ or .agents/ or .opencode/
│   └── skills/
│       ├── speckit/                          # Unified Router Skill
│       │   ├── SKILL.md                      # Lightweight subcommand router & core rules
│       │   ├── references/                   # On-demand deep-dive subcommand instructions
│       │   │   ├── constitution.md
│       │   │   ├── specify.md
│       │   │   ├── clarify.md
│       │   │   ├── plan.md
│       │   │   ├── checklist.md
│       │   │   ├── analyze.md
│       │   │   ├── tasks.md
│       │   │   ├── implement.md
│       │   │   ├── converge.md
│       │   │   └── taskstoissues.md
│       │   ├── resources/
│       │   │   └── templates/                # 5th-tier bundled fallback templates
│       │   └── scripts/                      # Bundled POSIX helper scripts
│       └── speckit-<subcommand>/             # Granular Skills (10 dedicated packages)
│           └── SKILL.md
│
├── .specify/                                 # Project-level Spec-Kit configuration
│   ├── feature.json                          # Active feature pointer {"feature_directory": "..."}
│   ├── init-options.json                     # Optional numbering config {"feature_numbering": "..."}
│   ├── extensions.yml                        # Optional Pre/Post lifecycle hook registry
│   ├── memory/
│   │   └── constitution.md                   # Project-wide governing principles
│   ├── scripts/
│   │   └── bash/                             # Prerequisite & context setup scripts
│   │       ├── check-prerequisites.sh
│   │       ├── setup-plan.sh
│   │       └── setup-tasks.sh
│   └── templates/                            # Core & override Markdown blueprints
│       ├── overrides/                        # Tier 1: Project-local template overrides
│       ├── checklist-template.md
│       ├── constitution-template.md
│       ├── plan-template.md
│       ├── spec-template.md
│       └── tasks-template.md
│
└── specs/                                    # Feature artifact directories
    └── 001-user-auth/                        # Sequentially or timestamp-prefixed feature folder
        ├── spec.md                           # Functional specification (WHAT / WHY)
        ├── plan.md                           # Technical implementation plan (HOW)
        ├── research.md                       # Phase 0 architectural spike & decision log
        ├── data-model.md                     # Phase 1 entity schemas & state transitions
        ├── quickstart.md                     # Phase 1 end-to-end verification guide
        ├── tasks.md                          # Phased, story-mapped implementation backlog
        ├── contracts/                        # API / CLI / UI interface schemas
        └── checklists/                       # Requirements quality checklists
            ├── requirements.md               # Auto-generated spec readiness checklist
            └── security.md                   # Domain-specific checklist (/speckit checklist)
```

---

## 2. Progressive Disclosure & Context Efficiency

Modern AI coding agents enforce strict context-window budgets. Loading thousands of lines of instructions into every turn degrades reasoning accuracy and increases token costs. Spec-Kit solves this through two complementary mechanisms:

1. **Skill-Level Progressive Disclosure**:
   - At session startup, agents only inject the `name` and `description` frontmatter fields of installed skills.
   - In the **Unified Skill (`speckit/`)**, `SKILL.md` acts as a compact subcommand router (~250 lines), while exhaustive rules, taxonomies, and anti-examples live under `references/<subcommand>.md` and are read only when that specific subcommand is triggered.
2. **Artifact-Level Progressive Disclosure**:
   - Commands like `/speckit analyze`, `/speckit checklist`, and `/speckit converge` explicitly instruct the agent to load only the relevant sections of `spec.md`, `plan.md`, and `tasks.md` rather than dumping entire files into working memory.

---

## 3. Dual-Execution Engine: Bash Helpers + Native Fallbacks

Spec-Kit commands resolve active feature paths and verify prerequisite files before executing. To guarantee 100% reliability across macOS, Linux, Windows (with or without Git Bash), and global skill installations, every skill uses a two-layer resolution strategy:

### Layer 1: Bundled Bash Helpers (`.specify/scripts/bash/`)
| Script | Supported Flags | JSON Output Keys |
| :--- | :--- | :--- |
| **`check-prerequisites.sh`** | `--json`, `--paths-only`, `--require-tasks`, `--include-tasks` | `REPO_ROOT`, `FEATURE_DIR`, `FEATURE_SPEC`, `IMPL_PLAN`, `TASKS`, `AVAILABLE_DOCS` |
| **`setup-plan.sh`** | `--json` | `FEATURE_DIR`, `FEATURE_SPEC`, `IMPL_PLAN`, `SPECS_DIR`, `BRANCH` |
| **`setup-tasks.sh`** | `--json` | `FEATURE_DIR`, `TASKS_TEMPLATE`, `AVAILABLE_DOCS` |

### Layer 2: Native Agent Tool Fallback
If `.specify/scripts/bash/` is absent (for example, in a fresh repository where the user installed skills via `--global`) or if shell execution fails, the skill **never aborts**. Instead, the agent natively:
1. Reads `"feature_directory"` from `.specify/feature.json` (or scans `specs/` for the latest feature folder).
2. Resolves template files through the 5-tier Template Resolution Priority.
3. Inspects `FEATURE_DIR` directly using native file-listing and file-reading tools.

---

## 4. Five-Tier Template Resolution Priority

Whenever `/speckit constitution`, `/speckit specify`, `/speckit plan`, `/speckit checklist`, or `/speckit tasks` initializes an artifact, it searches for `<name>-template.md` in the following order (highest priority first):

1. **Project-Local Overrides**: `.specify/templates/overrides/<name>-template.md`
2. **Preset Templates**: `.specify/presets/templates/<name>-template.md`
3. **Extension Templates**: `.specify/extensions/templates/<name>-template.md`
4. **Workspace Core Defaults**: `.specify/templates/<name>-template.md`
5. **Skill Bundled Fallback**: `resources/templates/<name>-template.md` (inside the skill package itself)

This allows teams to customize templates per repository (Tier 1) without modifying the base templates (Tier 4) or global skill installations (Tier 5).

---

## 5. Feature Directory State & Numbering Configuration

### Active Feature Tracking (`.specify/feature.json`)
When `/speckit specify` creates a feature directory, it writes the resolved path to `.specify/feature.json`:

```json
{
  "feature_directory": "specs/001-user-auth"
}
```

Downstream commands (`/speckit clarify`, `/speckit plan`, `/speckit tasks`, `/speckit implement`, `/speckit converge`) read `.specify/feature.json` first, decoupling feature directory resolution from Git branch naming conventions.

### Feature Numbering Mode (`.specify/init-options.json`)
You can control how `/speckit specify` prefixes new directories under `specs/` by creating `.specify/init-options.json`:

```json
{
  "feature_numbering": "sequential"
}
```

- `"sequential"` *(default)*: Auto-increments a 3-digit prefix (`001-<short-name>`, `002-<short-name>`).
- `"timestamp"`: Uses a UTC timestamp prefix (`YYYYMMDD-HHMMSS-<short-name>`), ideal for large teams creating specs concurrently on separate branches to avoid merge conflicts on sequence numbers.

---

## 6. Lifecycle Extension Hooks (`.specify/extensions.yml`)

Every Spec-Kit command supports pre-execution (`before_<command>`) and post-execution (`after_<command>`) hooks defined in `.specify/extensions.yml`.

### Supported Hook Events
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

### Configuration Schema
```yaml
hooks:
  before_specify:
    - extension: "git-workflow"
      command: "speckit.git.branch"
      description: "Automatically create and switch to a feature branch"
      optional: false
      enabled: true

  after_implement:
    - extension: "quality-gate"
      command: "speckit.qa.verify"
      description: "Run test suite and linter after task implementation"
      prompt: "Would you like to run the quality verification suite now?"
      optional: true
      enabled: true
```

### Hook Execution Semantics
- **`enabled: false`**: Skipped silently. Hooks without an `enabled` key default to `true`.
- **`optional: false` (Mandatory Hook)**: The agent emits an `EXECUTE_COMMAND: <command>` block, invokes the command immediately, and waits for completion before proceeding.
- **`optional: true` (Optional Hook)**: The agent displays the hook command and prompt to the user as a recommended follow-up action.
