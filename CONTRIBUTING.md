# Contributing

vibe-os grows by solving concrete problems in AI-assisted software work. Contributions are not limited to skills: a tool may be a command, agent, CLI, plugin, integration, library, service, application, or a combination that fits the workflow.

This guide keeps proposals comparable without forcing every tool into one runtime or repository shape.

## Before you build

1. Read [PHILOSOPHY.md](PHILOSOPHY.md) and [ARCHITECTURE.md](ARCHITECTURE.md).
2. Search the repository for an existing tool or proposal that addresses the same workflow.
3. Identify the user problem and intended outcome before choosing an implementation form.
4. Check whether the idea belongs inside an existing tool, composes with one, or is coherent enough to stand alone.

A new capability family is not required before proposing a tool. Families describe the portfolio; they are not approval gates.

## Step 1: Write a tool brief

Start with a concise brief in an issue, proposal document, or PR description. It must answer:

- **Problem:** What repeatedly goes wrong, takes too long, costs too much, or produces weak results?
- **User and workflow:** Who encounters the problem, and at which point in AI-assisted software work?
- **Outcome:** Which dimensions improve—quality, speed, cost, autonomy, context, learning, interoperability, or control?
- **Success evidence:** What observation or evaluation would show that the tool helped?
- **Workflow:** What happens from invocation through completion, including important failure paths?
- **Form:** Why is this best implemented as a skill, command, CLI, plugin, library, service, application, or hybrid?
- **Interface:** What are the inputs, outputs, and material side effects?
- **Environment:** Which AI hosts, models, operating systems, and external commands or services are required?
- **Data boundary:** What does the tool read, retain, or send outside the machine?
- **Cost:** Can it create provider, compute, or infrastructure charges?
- **Alternatives:** What simpler approach or existing tool was considered, and why is it insufficient?

The brief should be detailed enough to reveal product and architecture problems before implementation, but it does not need a formal schema.

## Step 2: Choose the smallest suitable form

Let the workflow determine the artifact:

- Use a **skill** when an existing AI host can perform the workflow reliably from instructions and available tools.
- Use an **agent or command** for a focused role or repeatable host-native invocation.
- Use a **CLI** for deterministic automation, scripting, process control, or structured I/O.
- Use a **plugin, hook, or integration** when the value depends on a host's lifecycle, UI, events, or permissions.
- Use a **library** only when multiple concrete consumers need reusable logic.
- Use a **service or application** when persistent state, coordination, scheduling, or a dedicated interface is essential.

Hybrid designs are welcome when each part has a clear responsibility. Avoid adding a runtime, framework, or service only for hypothetical future reuse.

## Step 3: Document the tool boundary

The implementation must make these facts easy to find:

- when and how to invoke the tool;
- required dependencies and supported environments;
- accepted inputs and produced outputs;
- files, commands, network services, and providers it can access;
- possible mutations and costs;
- partial-failure and recovery behavior;
- how to uninstall, disable, or undo material changes when applicable.

Use the native documentation surface of the chosen form. For example, a skill uses `SKILL.md`, a CLI uses help output and a README, and a library uses types and API documentation. vibe-os does not currently require a universal manifest.

## Step 4: Build for explicit composition

Prefer stable, inspectable boundaries: files, structured output, standard streams, exit codes, local APIs, or host-native protocols. Preserve provenance when combining results from models or tools.

Do not make unrelated tools depend on hidden global state. If a shared component appears necessary, show at least two concrete consumers and explain the stable overlap. Tool-specific policy stays inside the tool.

## Step 5: Evaluate the intended outcome

Every contribution needs an evaluation appropriate to its behavior.

### Deterministic tools

- Test normal inputs, invalid inputs, missing dependencies, partial failure, and cleanup.
- Verify machine-readable output and exit behavior where applicable.
- Include offline fixtures when the tool parses external formats.

### Model-mediated tools

- Use realistic prompts and representative projects or synthetic fixtures.
- Compare against a meaningful baseline when claiming improvement.
- Include human review for outcomes that cannot be reduced to reliable assertions.
- Record quality alongside relevant latency, token, and cost tradeoffs.

### Integrations and applications

- Test supported host versions and degraded behavior when the host or service is unavailable.
- Verify that data access, external calls, and user-visible mutations match the documentation.

An evaluation can begin small, but it must test the claimed outcome rather than only proving that the tool runs.

## Step 6: Open a pull request

The PR should include:

- the tool brief or a link to it;
- the capability families it touches, for navigation only;
- the implemented form and why it fits;
- supported environments and known limitations;
- evaluation results and reproduction steps;
- data, cost, and side-effect disclosures;
- any shared infrastructure added and the concrete consumers that justify it.

## Contribution checklist

### Product

- [ ] Solves a specific AI-assisted software-work problem.
- [ ] States the intended outcome and important tradeoffs.
- [ ] Uses the smallest suitable implementation form.
- [ ] Does not duplicate an existing tool without a clear reason.

### Architecture

- [ ] Inputs, outputs, dependencies, and side effects are explicit.
- [ ] Provider-specific behavior is isolated and documented.
- [ ] Composition uses inspectable boundaries rather than hidden shared state.
- [ ] New shared infrastructure has more than one concrete consumer.

### Trust

- [ ] Sensitive data access and external calls are disclosed.
- [ ] Context sent to models or services is limited to what the workflow needs.
- [ ] Costs and workspace mutations are predictable.
- [ ] Failure does not silently present partial work as complete.

### Quality

- [ ] Evaluation exercises the claimed outcome.
- [ ] Important failure and degraded-mode scenarios are covered.
- [ ] Documentation matches the implemented behavior.
- [ ] Examples and fixtures contain no real secrets or private user data.

## Session-intelligence contributions

Tools that analyze recorded AI sessions follow additional subsystem contracts: unified source adapters, global/project analysis scopes, transcript redaction, evidence-backed recommendations, and the recommendation schema. These requirements are documented in [docs/session-intelligence.md](docs/session-intelligence.md).

They apply because of the data and composition needs of that subsystem, not because every vibe-os tool must analyze sessions.

## Code of conduct

Be specific, evidence-minded, and honest about uncertainty. Critique ideas and implementations without moralizing about the people behind them. Quality matters more than speed or feature count.
