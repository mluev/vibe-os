# Roadmap

This roadmap describes sequencing, not release dates or promises. vibe-os is being re-founded as a format-neutral toolkit for improving AI-assisted software work. The immediate goal is to establish a coherent base before committing to a flagship implementation.

## Current stage — foundation

**Goal:** Make the project broad enough for many kinds of AI workflow tools without replacing the old session-intelligence design with another premature universal architecture.

### Deliverables

- A clear mission centered on quality, speed, cost, autonomy, context, learning, interoperability, and user control.
- Format-neutral terminology for tools, capabilities, capability families, skills, and shared foundations.
- A light architecture based on explicit tool boundaries and earned shared infrastructure.
- A contribution process that works for skills, CLIs, agents, plugins, integrations, libraries, services, and applications.
- Session intelligence preserved as a dedicated subsystem rather than treated as the definition of vibe-os.
- Documentation that distinguishes designed concepts from implemented and released software.

### Exit criteria

- The core documents describe the same mission and terminology.
- No platform-wide rule requires tools to analyze sessions, emit recommendations, support global/project analysis scopes, or use a common kernel.
- Session-intelligence contracts and proposed tools remain documented and internally coherent.
- A contributor can propose a tool without first choosing a universal runtime or packaging format.

## Next stage — validate the portfolio

**Goal:** Select initial implementations based on their ability to prove the broader mission, not on the order in which ideas were documented.

Candidate tools should be compared using:

- importance and frequency of the workflow problem;
- expected improvement to one or more outcome dimensions;
- ability to evaluate the result credibly;
- distinct value created by vibe-os rather than an existing tool;
- feasibility, maintenance burden, privacy risk, and provider cost;
- usefulness as a reference for later contributors;
- opportunity to test composition without inventing broad infrastructure.

This stage intentionally does not name the next flagship tool. A brief and evaluation proposal should exist before implementation priority is fixed.

## Later horizons

These are directions, not version commitments.

### Prove multiple forms

Build high-quality tools in the forms their workflows require. Over time the repository should demonstrate that a skill, deterministic program, and deeper integration can coexist without pretending they share the same runtime.

### Extract proven shared foundations

When multiple tools repeat the same difficult work, extract and stabilize the overlap. Likely candidates may include evaluation utilities, context handling, provider adapters, orchestration primitives, or artifact exchange—but none is pre-approved as a universal layer.

### Improve distribution and discovery

Once real tools exist, make them easier to find, install, update, and compose. Packaging and metadata should follow evidence from those tools rather than precede them.

### Grow an accountable ecosystem

Develop compatibility guidance, quality expectations, evaluation records, and contribution examples that let users judge tools by outcomes rather than claims.

## Capability portfolio

The initial capability families are:

- decision support;
- orchestration;
- context and memory;
- session intelligence;
- quality and evaluation;
- model and cost optimization;
- integrations.

They are a map of possible work, not independent products or roadmap lanes. Proposals may span families, and new families should emerge from concrete tools.

Session intelligence is currently the most detailed design and remains available in [session-intelligence.md](session-intelligence.md). Its maturity as documentation does not automatically determine implementation priority.

## Open decisions

The following decisions stay open until implementation evidence makes them concrete:

- packaging and installation for different tool forms;
- repository layout once the first implementations arrive;
- whether common machine-readable metadata is useful;
- update and compatibility policies;
- shared evaluation infrastructure;
- provider and host integration abstractions;
- collaboration and team-distribution features;
- which tool becomes the first flagship implementation.

Deferring these decisions is intentional. The foundation defines durable boundaries while leaving implementation choices to real workflows.
