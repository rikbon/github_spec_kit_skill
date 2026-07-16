# Contributing to Spec-Kit Skills

We welcome contributions to improve the Spec-Kit Multi-Agent Skill Suite. This guide outlines how to contribute new subcommands, create customized presets, and write extensions.

---

## Modifying the Skills

All skills are written in standard Markdown with YAML frontmatter.

### Frontmatter Conventions
Every skill must start with a valid frontmatter block:
```yaml
---
name: speckit-your-command
description: "A clear description of what the skill does"
argument-hint: "Guidance text displayed in the agent's input line"
compatibility: "List any setup assumptions"
user-invocable: true
disable-model-invocation: false
---
```

### Instruction Guidelines
- **Use Declarative Language**: Write instructions in the imperative style ("Load feature context", "Scan folder", "Raise error").
- **State Error Paths Clearly**: Define what the agent must do if files are missing or validation checks fail.
- **Maintain Token Efficiency**: Avoid verbose narratives. Use bulleted execution steps and checklists.

---

## Developing Extensions

Extensions add new commands or automated scripts.

1. **Define the manifest**: Create an `extension.yml` defining the ID, name, version, and the commands provided.
2. **Hook Into Events**: Register your script under key SDD events (e.g., `after_implement` or `before_plan`).
3. **Register commands**: Write your skill in your agent's skills folder (e.g., `.claude/skills/` or `.agents/skills/`) using the prefix `speckit-ext-[name]`.

---

## Testing Your Changes

Before submitting a Pull Request:
1. **Local verification**: Run the `./install-skills.sh --local` command inside a test repository and run your agent.
2. **Path checks**: Verify that all file system operations resolve using relative or absolute paths correctly.
3. **No Local Paths**: Ensure no hardcoded paths (e.g. `file:///Users/...` or `/home/...`) remain in documentation or template files.
