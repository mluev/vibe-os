# Architecture

This document defines the architectural boundaries of vibe-os. The project is currently documentation-first: these are constraints for future tools, not claims that a shared runtime or package already exists.

## Architectural position

vibe-os is a modular, format-neutral toolkit for AI-assisted software work.

- There is no required runtime shared by every tool.
- There is no universal output schema or installation format.
- A tool owns its workflow and selects the implementation form that fits it.
- Composition relies on explicit boundaries rather than inherited global behavior.
- Shared infrastructure is introduced only after concrete reuse proves its value.

This is deliberate. A terminal orchestrator, a transcript analyzer, and a review application have different needs. Forcing them through one kernel would create coupling without creating interoperability.

## Terminology

### Tool

A **tool** is a user-facing contribution that improves an AI-assisted software workflow. It is the primary unit discussed in proposals, documentation, evaluation, and releases.

A tool may be implemented as a skill, agent, command, CLI, plugin, hook, integration, library, local service, application, or a deliberate combination of these forms.

### Capability

A **capability** is what a tool enables a user or AI system to do. One tool may provide several closely related capabilities, but unrelated responsibilities should remain separate.

### Capability family

A **capability family** groups related problems, such as decision support or session intelligence. Families help navigation and discussion; they do not impose package boundaries, APIs, ownership, or roadmap order.

### Skill

A **skill** is one tool form: instructions and optional resources that teach an AI agent a repeatable workflow. Skills are expected to be common because they are lightweight, but they are not the architectural center of vibe-os.

### Shared foundation

A **shared foundation** is infrastructure used by multiple tools: for example, an adapter library, context selector, evaluation harness, or artifact protocol. It becomes shared only after real consumers establish a stable common need.

## The tool boundary

Every tool must make the following contract understandable in its design and user documentation. This is a documentation contract, not a required machine-readable manifest.

| Concern | Required answer |
|---|---|
| Outcome | What workflow problem does the tool solve, and which improvement dimension does it target? |
| Trigger | When should a user or agent invoke it? |
| Interface | What inputs does it accept and what outputs or effects does it produce? |
| Environment | Which operating systems, AI tools, models, or hosts does it require? |
| Dependencies | Which commands, services, credentials, repositories, or other tools must exist? |
| Data boundary | What information does it read, retain, or send to an external provider? |
| Side effects | What can it create, modify, execute, publish, or spend? |
| Failure behavior | How does it report partial results, unavailable dependencies, and interrupted work? |
| Evaluation | How will maintainers know that it improves the intended outcome? |

Different forms express this contract differently. A skill may document it in `SKILL.md`; a CLI may use its README and help output; a library may use API documentation and types. The information matters more than a uniform file layout.

## Choosing an implementation form

Use the smallest form that gives the workflow the reliability and experience it needs.

| Form | Good fit |
|---|---|
| Skill | Reasoning-heavy or tool-guided workflows that an existing AI host can execute |
| Agent or command | A focused delegated role or repeatable invocation inside a host |
| CLI | Deterministic automation, scripting, pipelines, and machine-readable I/O |
| Plugin, hook, or integration | Deep use of a host's lifecycle, UI, events, or permissions |
| Library | Reusable logic with multiple concrete consumers |
| Local service | Long-running coordination, state, scheduling, or inter-process access |
| Application | Workflows that materially benefit from a dedicated interactive interface |

Hybrid tools are valid. Keep the boundary between parts explicit—for example, a skill may guide judgment while a bundled CLI handles deterministic process management.

## Composition

Tools compose through documented interfaces such as:

- files or structured artifacts;
- standard input and output;
- command-line exit status;
- local APIs or sockets;
- host-defined skill, plugin, hook, or agent protocols.

Composition should preserve provenance and failure information. A tool that gathers results from several models, for example, should identify which provider produced each result and distinguish a failed consultation from an empty opinion.

Do not require unrelated tools to share internal state, a database, or a lifecycle. When a shared protocol becomes useful, document versioning and compatibility at the boundary rather than exposing implementation internals.

## Shared foundations

Shared foundations should emerge from repeated implementation pressure:

1. Build the first tool with a clear local boundary.
2. Observe a second tool needing substantially the same difficult capability.
3. Compare the actual requirements and extract only the stable overlap.
4. Test the shared component against both consumers.
5. Keep tool-specific policy in the tools rather than pushing it into the shared layer.

This rule applies to runtimes, registries, configuration systems, permission models, adapters, evaluation harnesses, and UI frameworks. Reuse is evidence for an abstraction; imagined reuse is not.

## Cross-cutting requirements

### Transparency and control

Material data access, external calls, cost, and workspace changes must be understandable before they surprise the user. Each tool chooses confirmation points appropriate to its risk and host environment; vibe-os does not define a platform-wide permission engine at this stage.

### Privacy and context

Tools should access and transmit only the context required for their outcome. Sensitive sources need safeguards proportional to their risk. External providers and retained data must be disclosed. Subsystems may impose stricter rules—for example, session intelligence requires redaction before user-authored transcript text is sent to a model.

### Portability and vendor integration

Project-level concepts should remain vendor-neutral. Provider-specific integrations are welcome when they create real value, but their behavior belongs behind a clear boundary. Supporting every provider is not required; documenting the supported environment is.

### Evaluation

Evaluation belongs to each tool because workflows have different success criteria. Prefer outcome measures over activity measures. Deterministic behavior should have automated tests; model-mediated behavior should use representative evaluations, human review, or both. Record important cost, latency, and quality tradeoffs.

## Session intelligence as a subsystem

Session intelligence is the first detailed subsystem design in vibe-os. It has its own shared kernel because several proposed tools consume the same local transcript sources and recommendation format.

Its unified `Session` model, source adapters, global/project analysis scopes, redaction layer, recommendation contract, artifact router, and reference skill briefs are documented in [docs/session-intelligence.md](docs/session-intelligence.md).

Those interfaces are public within that subsystem. They are not universal vibe-os interfaces. A terminal orchestrator or model-review tool does not need to load sessions or emit a session-backed recommendation unless its own workflow calls for it.

## Repository evolution

The repository should gain structure from implemented tools rather than from an empty taxonomy. Do not create one directory per capability family in advance. When the first tool of a form is added, document a minimal convention for that form; revise it when a second implementation exposes real differences.

Architecture decisions that affect only one tool stay with that tool. Decisions shared across tools belong here once they are proven. Detailed subsystem contracts belong in dedicated documents, as session intelligence does today.
