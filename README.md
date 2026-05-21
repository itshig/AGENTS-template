# AGENTS Template

Welcome to your **AGENTS Template**! This repository serves as a robust, standardized starting point for setting up AI-agent-friendly developer guidelines, constraints, personas, and workflows in any new software project.

By packaging these orchestration guidelines directly in your repository, you provide LLM-based coding assistants (such as Claude Code, Gemini, Cursor, Aider, and Antigravity) with precise, local context about your tech stack, security rules, and development lifecycle.

---

## 📂 Repository Structure

The core orchestration system resides within the `.agent/` directory:

```
.agent/
├── rules/        ← Checklists and security constraints for specific scopes of work
├── personas/     ← Role and voice presets for diverse agent pair-programming modes
└── workflows/    ← Multi-step, sequential procedures for recurring engineering tasks
```

### 🎯 Key Entry Points

1. **`AGENTS.md`** (Root): The primary orchestration and routing engine. This is the single source of truth that every AI agent reads first upon entering the repository.
2. **`CLAUDE.md` / `GEMINI.md`** (Root): Minimal, high-level pointer files configured to redirect specific agents straight to `AGENTS.md`.

---

## 🛠️ How to Adopt This Template

When bootstrapping a new project with this template, follow these adoption steps:

1. **Copy the Files**: Copy the `.agent/` directory, `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` to the root of your new project.
2. **Update the Orientation Table**: In [`AGENTS.md`](./AGENTS.md), fill out the **Section 2: Repository Orientation** block with your new project's:
   - One-sentence description
   - Tech stack (language, frameworks, database)
   - Entry points
   - CLI commands to run, test, and build the application
3. **Customize Dangerous Paths**: Review [`/rules/dangerous-paths.md`](./.agent/rules/dangerous-paths.md) and specify any critical file paths or operations unique to your repository that require explicit human sign-off.
4. **Tailor Core Rules**: Refine rules like `security.md`, `migrations.md`, and `validation.md` to match your target stack's architecture.

---

## 🤝 Rules, Personas, and Workflows

| Context Type | Purpose | Example File |
| :--- | :--- | :--- |
| **Rule** (`rules/`) | Restricts *what* the agent can and cannot do. Hard constraints. | [`dod.md`](./.agent/rules/dod.md) (Definition of Done) |
| **Persona** (`personas/`) | Influences *how* the agent thinks, communicates, and guides. | [`lead-engineer.md`](./.agent/personas/lead-engineer.md) |
| **Workflow** (`workflows/`) | Sequentially guides the agent through multi-stage tasks. | [`new-feature.md`](./.agent/workflows/new-feature.md) |

For detailed guidance on authoring new rules, personas, or workflows, please refer to the corresponding subdirectories inside the `.agent/` folder.

---

_Designed to elevate human-agent pair programming to its highest potential. Maintain your standards, automate the boilerplate, and build safely._
