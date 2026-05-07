# Architect

> Load this when proposing structural change: a new module, a new dependency, a new pattern, a change to data shapes, or anything that affects more than one part of the codebase.

## When to load

- Adding a new top-level module, package, or service.
- Introducing a new runtime dependency (library, framework, SDK).
- Changing a data model, schema, or API contract.
- Picking between two ways to do something where the choice will be hard to reverse.
- Replacing or refactoring a pattern used in many places.
- Anything you'd describe as "the right way to structure this."

## The questions

Answer these **before** writing the implementation. Write the answers down (PR description, design doc, or scratch comment) so they're reviewable.

### 1. What problem are we solving?

- What is the user-visible or system-visible outcome?
- What happens if we do nothing?
- Is this the actual problem, or a symptom of a different one?

### 2. What are the alternatives?

- List at least two. "Do nothing" is always one of them.
- For each: what does it cost (build, maintain, change later)? What does it buy?
- Why is the chosen one best *for this project*, not in the abstract?

### 3. What does it touch?

- Which files, modules, or services change?
- Which interfaces become public commitments (hard to change later)?
- Who else depends on what's changing?

### 4. How does it fail?

- What's the worst realistic failure mode?
- How will we notice (logs, alerts, user reports)?
- How do we recover (rollback, feature flag, manual fix)?

### 5. How do we get out of it?

- If this turns out to be wrong in 6 months, how hard is it to undo?
- A change is cheap if it's reversible. Expensive if it's not.

## Adding a dependency

Before adding a new library, ask:

- [ ] **Can we do without it?** Standard library, existing dependency, or 30 lines of our own code?
- [ ] **Is it maintained?** Last release, open issues, responsiveness to security reports.
- [ ] **License compatible** with this project's license and distribution model.
- [ ] **Size cost** acceptable. (Bundle size for client code, install/cold-start for server code.)
- [ ] **Transitive footprint** reasonable. A small library that pulls in 200 transitive deps is not a small library.
- [ ] **Security posture.** Any known critical CVEs? Has it had supply-chain incidents?
- [ ] **Replaces** something? If yes, remove the old thing in the same change.

## Patterns

Prefer:

- **Boring over clever.** The reader should understand the code without reading the author's blog.
- **Composition over inheritance.** Inheritance is a strong commitment; composition is cheap to change.
- **Pure functions where possible.** They're testable, parallelizable, and don't surprise you.
- **Explicit over implicit.** Magic is fun to write and miserable to debug.
- **Local reasoning.** A reader should be able to understand a function without reading the rest of the codebase.
- **Make illegal states unrepresentable.** If your types let you build an invalid object, your runtime checks will eventually be wrong.

Avoid:

- **Premature abstraction.** Three concrete uses before you abstract. One use is "code." Two is "coincidence." Three is "pattern."
- **Wrappers around wrappers.** Each layer should justify its existence.
- **Configuration that doesn't get used.** YAGNI applies to options, too.
- **"Generic" code with one caller.**

## Data and APIs

Anything you persist or expose externally is **hard to change later.** Treat it accordingly.

- Names matter. Renaming a column or an API field after launch costs more than picking the right name now.
- Optional fields stay optional forever. Required fields can become optional, but not the reverse.
- Versioning strategy decided **before** v1 ships, not after.
- Backwards compatibility window decided and documented.

## When to escalate to a human

- The choice locks in a vendor or pricing model.
- The choice changes how the team works (new language, new framework, new deploy target).
- The change is large enough that a wrong call costs more than a day to undo.
- You'd be the first person in this codebase to do it this way.

These are not failures of nerve — they're correct calls for input.
