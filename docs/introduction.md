# Introduction to Spec-Driven Development (SDD)

Spec-Driven Development (SDD) is a software engineering methodology that prioritizes structured specifications as executable instructions for AI coding agents. 

Rather than relying on ad-hoc prompts ("vibe coding"), SDD treats requirements and architecture documents as the primary source of truth, enforcing a rigorous, repeatable loop from feature description to final codebase validation.

```
┌─────────────────┐      ┌─────────────┐      ┌─────────────┐
│  Constitution   │ ───> │  Spec (MD)  │ ───> │  Plan (MD)  │
└─────────────────┘      └─────────────┘      └─────────────┘
                                                     │
                                                     ▼
┌─────────────────┐      ┌─────────────┐      ┌─────────────┐
│  Verification   │ <─── │  Codebase   │ <─── │ Tasks (MD)  │
└─────────────────┘      └─────────────┘      └─────────────┘
```

---

## 🔑 Core Pillars

### 1. Specification as Law
Specifications are stored directly in the repository as Markdown documents. These documents represent a contract of expected behavior. AI agents consume the specification file to drive implementation, reducing drift and misalignment.

### 2. Guardrails (The Constitution)
A project constitution (`constitution.md`) defines governing principles, architectural requirements, testing disciplines, and coding standards. This document binds all AI workflows, ensuring consistent technical decisions across features.

### 3. Step-by-Step Refinement
Rather than generating full features in a single prompt, SDD separates phases into logical checkpoints:
- **Specify**: Outline functional goals, user stories, and acceptance scenarios without specifying technical solutions.
- **Clarify**: Interactively question and refine functional boundaries before designing the system.
- **Plan**: Choose stack, design schemas, define API contracts, and outline the implementation blueprint.
- **Task Breakdown**: Decompose the plan into dependency-ordered, checkbox-style execution tasks.
- **Implement**: Systematically implement code task-by-task.
- **Converge**: Inspect the codebase to detect drift and capture remaining tasks.

---

## 📈 Why use SDD with AI Agents?

- **Reduced Hallucinations**: Agents follow explicit specifications instead of inventing features.
- **Predictable Outcomes**: Separation of functional specs from technical plans ensures product managers can audit requirements without reading code.
- **Traceability**: Implementation tasks map directly back to functional requirement IDs (`FR-###`) and success criteria (`SC-###`).
- **Autonomous Progress**: When tasks are clearly broken down, agents can execute long-running implementations without user intervention.
