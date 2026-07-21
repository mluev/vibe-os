# vibe-os

**vibe-os is a modular toolkit for improving AI-assisted software work.**

AI coding tools are capable, but the workflows around them are still young. Important context is lost between sessions. Reviews depend on one model's perspective. Repetitive steps stay manual. The wrong model consumes too much time or money. Useful lessons remain buried in transcripts.

vibe-os exists to improve that whole system: how people plan, prompt, delegate, execute, verify, learn, and ship with AI.

## What the project optimizes

Every vibe-os tool should make at least one meaningful dimension of AI-assisted software work better.

| Dimension | What improvement looks like |
|---|---|
| Quality | More correct, robust, maintainable outcomes |
| Speed | Less time and fewer turns from intent to verified result |
| Cost | Better model and context choices for the value produced |
| Autonomy | More work completed safely without unnecessary supervision |
| Context | The right information reaches the right model at the right time |
| Learning | Past work becomes reusable knowledge and better future behavior |
| Interoperability | Tools and models can cooperate instead of becoming isolated silos |
| Control | Users can understand and direct what the system reads, sends, and changes |

These dimensions can conflict. A tool that saves time by weakening verification is not an unconditional improvement. Good tools state their tradeoffs and evaluate the outcome that matters.

## What counts as a vibe-os tool

A **tool** is a user-facing contribution that improves an AI software workflow. The implementation form follows the problem. A tool may be:

- a skill that teaches an AI agent a repeatable workflow;
- an agent or command with a focused responsibility;
- a CLI or local service that performs deterministic work;
- a plugin, hook, or integration that connects existing tools;
- a reusable library shared by several workflows;
- an application when a dedicated interface materially improves the experience.

Skills will often be the smallest and most effective form, but vibe-os is not defined by a single packaging format or runtime.

## Capability families

Capability families organize related problems without prescribing a backlog or architecture.

| Family | Example directions |
|---|---|
| Decision support | Independent model opinions, plan critique, alternative approaches |
| Orchestration | Delegation, parallel work, handoffs, workflow automation |
| Context and memory | Context selection, durable knowledge, cross-session continuity |
| Session intelligence | Learn from transcripts, failures, repetition, and successful patterns |
| Quality and evaluation | Review, verification, regression detection, workflow benchmarking |
| Model and cost optimization | Model routing, token efficiency, latency and budget tradeoffs |
| Integrations | Connect AI tools, terminals, editors, repositories, and delivery systems |

The families are non-exclusive. A multi-model reviewer, for example, may combine decision support, orchestration, and evaluation.

## Architecture

vibe-os is format-neutral and modular:

- Each tool owns its workflow, dependencies, inputs, outputs, side effects, and evaluation method.
- Tools expose clear boundaries so they can be used independently and composed deliberately.
- Shared infrastructure is extracted only after multiple real tools need the same capability.
- There is no universal runtime, output schema, or installation mechanism at this stage.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the architectural boundaries and terminology.

## Session intelligence

The original foundation of vibe-os—analyzing local AI coding sessions and turning evidence into useful recommendations—remains an important capability family. Its source adapters, unified session model, privacy rules, recommendation contract, and proposed reference tools now live in [docs/session-intelligence.md](docs/session-intelligence.md).

Those contracts apply to session-intelligence tools. They are not requirements for every tool in vibe-os.

## Project status

vibe-os is currently in its foundation stage. The repository defines the mission, architecture, contribution standard, and the preserved design for session intelligence. It does not yet publish a stable installable toolkit.

The next implementation priority will be selected through evidence and explicit evaluation rather than being implied by the foundation documents.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) to propose a tool. Start with the workflow problem and intended improvement, then choose the implementation form that fits.

## Further reading

- [PHILOSOPHY.md](PHILOSOPHY.md) — product principles and capability map
- [ARCHITECTURE.md](ARCHITECTURE.md) — modular architecture and tool boundaries
- [CONTRIBUTING.md](CONTRIBUTING.md) — how to propose, build, and evaluate a tool
- [docs/session-intelligence.md](docs/session-intelligence.md) — preserved session-intelligence subsystem design
- [docs/roadmap.md](docs/roadmap.md) — foundation-first sequencing and open decisions
