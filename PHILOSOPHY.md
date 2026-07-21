# Philosophy

vibe-os exists to improve the practice of building software with AI. It is not a wrapper around one model, a catalog limited to skills, or a promise that more automation is always better. It is a place to develop tools that make AI-assisted work demonstrably more effective.

## Core principles

### 1. Optimize outcomes, not activity

More agents, prompts, tokens, automation, and generated code are not goals by themselves. A useful tool improves an outcome: correctness, speed, cost, autonomy, context quality, learning, interoperability, or user control.

Improvements must be considered as tradeoffs. Faster work that produces more regressions may be worse. A higher-cost model may be the efficient choice when it avoids an expensive failure. State which outcome a tool improves and what it may trade away.

### 2. Let the problem choose the form

The project is format-neutral. A workflow may need a skill, command, agent, CLI, plugin, hook, library, service, or application. Choose the smallest form that solves the real problem well.

Do not turn deterministic work into an LLM prompt merely because the surrounding workflow uses AI. Do not build an application when a short skill is sufficient. Conversely, do not force stateful orchestration or a rich interactive workflow into a skill when a proper program would be safer and clearer.

### 3. Make improvement measurable

Every tool should define what success looks like before implementation. The evidence may be quantitative—time, cost, pass rate, retries, failure rate—or qualitative when judgment is the real outcome. Evaluation should reflect the user's goal rather than an easy proxy.

Claims should match the evidence. A prototype can demonstrate feasibility; it cannot establish a universal productivity gain. A tool that cannot yet be measured should say what must be learned next.

### 4. Prefer depth over feature count

A narrow tool that reliably improves one important workflow is more valuable than a broad tool that performs many steps poorly. New features must earn their complexity.

Keep responsibilities coherent. When a tool accumulates unrelated jobs, split it into composable parts or make the handoff explicit.

### 5. Compose through clear boundaries

Tools should be independently understandable and useful where practical. Composition happens through documented inputs, outputs, artifacts, commands, or protocols—not through hidden assumptions about global state.

A tool may integrate deeply with a particular environment when that creates real value. The boundary should still be explicit so users understand the dependency and other tools can interoperate with it intentionally.

### 6. Keep users in control

AI workflows can read private context, call paid providers, execute commands, and change repositories. A tool should make material behavior visible: what it needs, what it sends outside the machine, what it may change, and where human approval belongs.

Control does not require interrupting every step. It requires predictable behavior, sensible defaults, and a clear way for users to choose their desired level of autonomy.

### 7. Treat context and privacy as product quality

Context is both fuel and liability. Too little produces weak answers; too much increases cost, latency, distraction, and exposure. Send the minimum context that preserves the required quality.

Secrets and private source material deserve deliberate handling. Tools that access sensitive data or external services must document that boundary and provide safeguards appropriate to their risk. Session-intelligence tools have stricter redaction requirements because transcripts routinely contain credentials and private text.

### 8. Stay vendor-neutral at the project level

No model or coding environment will remain best at every task. vibe-os should make it easier to benefit from different tools, compare them honestly, and move workflows between them.

Individual tools may target Claude Code, Codex, Cursor, or another environment when the integration depends on unique capabilities. Prefer portable concepts and isolate provider-specific behavior so one integration does not define the whole project.

### 9. Learn from real use

Design begins with a hypothesis and improves through use. Logs, evaluations, user feedback, failed runs, and session history can reveal where a workflow helps or harms. Turn that evidence into specific revisions rather than accumulating folklore.

The original session-analysis work embodies this principle, but historical session evidence is one learning source—not a prerequisite for every vibe-os tool.

### 10. Shared infrastructure must be earned

Do not design a universal runtime, schema, registry, or permission system before concrete tools require it. Start with explicit local contracts. When at least two tools repeat the same difficult work, extract a shared primitive and test it against both.

Shared infrastructure should reduce total complexity. If consumers must contort themselves around the abstraction, the abstraction is premature or scoped too broadly.

## Capability map

The following families describe the landscape. They overlap by design and do not imply roadmap priority.

### Decision support

Improve choices made before or during execution: independent model opinions, plan critique, risk analysis, alternative designs, and structured tradeoff comparison.

### Orchestration

Coordinate work across agents, tools, terminals, and stages. Useful directions include delegation, parallel execution, reliable waiting, result collection, handoffs, and recovery from partial failure.

### Context and memory

Deliver relevant information without flooding the model. This includes context selection, project knowledge, durable decisions, cross-session continuity, and routing information to the right participant.

### Session intelligence

Learn from recorded AI work: behavioral statistics, repeated patterns, prompt weaknesses, failure causes, undocumented knowledge, and workflows worth formalizing. Session-derived claims require evidence and privacy-aware handling. See [docs/session-intelligence.md](docs/session-intelligence.md).

### Quality and evaluation

Verify outputs and improve workflows through code review, tests, adversarial critique, regression detection, comparative evaluation, and benchmarks that reflect real user outcomes.

### Model and cost optimization

Choose models, context, and execution strategies based on capability, latency, and cost. The goal is value per task, not using the cheapest or strongest model indiscriminately.

### Integrations

Connect AI workflows to terminals, editors, repositories, browsers, issue trackers, CI systems, and delivery environments. Integrations should enable a workflow rather than exist only to increase the number of supported products.

## How the map evolves

Capability families are vocabulary, not organizational walls. A useful tool may span several. New families should be added when multiple concrete tools reveal a distinct problem area; they do not need to be predicted in advance.

The enduring test is simple: does the proposed work make AI-assisted software development meaningfully better, and can the project explain how it knows?
