# Philosophy

This document explains why the project exists, what it believes, and where it can go. If you're deciding whether a skill idea belongs here — or how to build one that does — start here.

## Core beliefs

### 1. Lived behavior beats imagined behavior

The best source of truth about how you work is how you actually work — not how you think you work or how you intend to work. Every skill in this project must ground its recommendations in evidence from real sessions. "You explained the auth module in 7 separate sessions over the last two weeks" is stronger than "you might want to document your modules."

Concretely: every recommendation must cite the sessions it came from. Skills that make claims without evidence are not in-scope for this project.

### 2. Extraction over invention

The goal is to surface and formalize what the user already does, not to prescribe new workflows from the outside. A skill that says "here's the workflow you've been running for the last three weeks" is more valuable than one that says "here's a workflow you should try."

This doesn't mean skills can't teach or suggest improvement — it means they should start from what's already there and build forward, not arrive with a theory disconnected from the user's actual history.

### 3. Suggest, never mutate

Skills never write files, create rules, or modify anything without explicit user approval. Every output is a draft. The user sees the evidence, sees the proposed artifact, and decides. A skill that silently edits `CLAUDE.md` is not in-scope — that's a violation of the user's ability to understand and trust the tool.

This principle applies even when the recommendation is obviously correct. The value of asking is not just safety — it's that the approval step is where the user learns something about their own workflow.

### 4. Privacy is a first-class constraint

Session files contain secrets: JWTs, API keys, database URLs, `.env` content, internal domain names. Redaction of sensitive content is mandatory before any data is passed to a language model. Skills that can complete their task without an LLM call should prefer that path. External API calls are opt-in, disclosed, and never the default.

This is not a legal disclaimer — it's an architectural commitment. The redaction layer lives in the kernel so that every skill inherits it automatically.

### 5. Opinionated about one thing

Each skill should do one job and do it well. A skill that detects repetition and creates rules and generates docs and coaches prompting is not a good skill — it's a bad product. Breadth is what the platform provides through composition; depth is what individual skills provide.

When you feel a skill growing into multiple jobs, that's a signal to split it or to have it output evidence for another skill to consume.

### 6. Two scopes, always

Every skill must answer the question: "does this work globally, per-project, or both?"

- **Global scope** addresses the user as a person: habits, style, patterns that span all their work.
- **Project scope** addresses a specific codebase: its missing docs, its rule set, its internal conventions.

Artifacts produced by global-scope analysis belong in global config locations (`~/.claude/CLAUDE.md`, `.cursor/rules/` global settings). Artifacts produced by project-scope analysis belong in the project itself (`CLAUDE.md` at the repo root, `.cursor/rules/` local to the project, `docs/`).

A skill that only works globally is fine. A skill that only works per-project is fine. A skill that doesn't account for scope at all is not in-scope for this project.

### 7. Tool-agnostic by design

vibe-os reads session data from wherever AI coding tools store it. Claude Code and Cursor are supported from v0. Any tool that stores conversation history in a local, readable format can be added as a source adapter. Skills are written against the kernel's typed `Session` model — they don't know or care which tool produced the data.

This matters for two reasons. First, most users don't use just one tool. Patterns that span Claude Code and Cursor sessions for the same project are more meaningful than patterns visible from either alone. Second, the AI tooling landscape is moving fast; anchoring the platform to one tool's format would give it an expiration date.

### 8. The platform is the point

The seed skills are examples. The kernel is what matters. A project that ships six skills and then stops is a collection of scripts. A project that ships a substrate that makes adding the seventh skill trivially easy — that's what this is trying to be.

This means: when a skill's implementation reveals something the kernel should provide, surface that as a kernel improvement rather than a one-off hack. The substrate grows from real skill needs.

### 9. The loop must close

Observation without action is noise. Action without observation is guesswork. The loop — sessions produce evidence → evidence produces recommendations → recommendations produce artifacts → artifacts improve future sessions → future sessions produce better evidence — is the unit of value here.

A skill that only displays a dashboard is half a skill. A skill that writes a rule without understanding where it came from is dangerous. The goal is always the closed loop: evidence leads to a specific proposed change, and that change feeds back into behavior.

---

## Directions of growth

This is a map of where the project can go. It is not a backlog. It is not a priority list. It is a set of open spheres, each of which can grow indefinitely. The seed skills are first-pass examples inside their respective spheres — they don't exhaust what's possible.

New directions can be proposed in issues. The only requirement is that a new direction must be grounded in session evidence and must produce artifacts that close a real loop.

---

### Insightful stats

Not "which model did you use the most" or a cost dump — your AI tool's built-in dashboard already shows those. Stats in vibe-os should change how you work. Useful signal includes:

- Where you spend the most turns vs. where you get the most value
- Which session shapes (long context, many retries, lots of file reads) correlate with success or failure
- Which files or topics consume the most context across your sessions
- Time-to-first-useful-output per task type, per tool
- Retry rates, abandonment rates, correction frequency
- Model-vs-task fit: which tasks benefit from a stronger model, which are fine with a smaller one
- Cross-tool comparison: are your Claude Code sessions more productive than your Cursor sessions for certain task types? Why?

The test for whether a stat belongs here: if you saw it, would you do something differently?

---

### Token optimization

Context has a cost — in dollars, in latency, and in quality (oversaturated context degrades responses). Skills in this sphere find waste and recommend concrete cuts:

- Files that get re-read repeatedly inside a single session without changing
- Tool call sequences that return the same or near-identical results multiple times
- Sessions where the context was large and the output was short — high input-to-output ratio with no evidence of reasoning benefit
- System prompt / skill content that loaded into context but was never referenced in any tool call or assistant message
- Tasks consistently run on a model larger than the task requires
- `CLAUDE.md` rules or `.cursor/rules/` entries that are always loaded but appear in no recent sessions' tool calls or responses

The output is never "use fewer tokens" in the abstract — it's always a specific thing to remove, collapse, or replace.

---

### Prompt engineering

Prompt engineering is a sphere in its own right and can grow in many directions: clarity, specificity, structure, constraints, role-setting, few-shot examples, decomposition, feedback-loop design. Skills in this sphere analyze how the user communicates with AI and teach improvements using before/after pairs drawn from the user's own history.

Anti-patterns to detect:
- Vague requests that produce a retry ("make it better", "fix it")
- Missing constraints that the user then has to add in the follow-up
- Conflicting instructions in a single message
- Repeated re-statement of context that belongs in a rule or skill
- Requests that try to do too many things in one turn

The output is concrete: here is a prompt you sent, here is why it likely produced the result it produced, here is a version that would have done better. The same analysis applies across both Claude Code and Cursor sessions.

---

### Pattern extraction

The foundation for several other spheres. Skills here detect recurring structures across sessions — from any supported tool:

- Repeated user prompts (near-identical messages across multiple sessions)
- Repeated inline instructions ("always use Composition API", "remember to handle errors")
- Recurring file/tool sequences (the same 5-step edit pattern across 20 sessions)
- Recurring problem statements ("the build is broken again")
- Latent workflows the user follows consistently without having named them
- Patterns that appear in both Claude Code and Cursor sessions — stronger evidence than either alone

This sphere mostly produces evidence for other skills — the repetition-detector feeds the rule-creator, the workflow-detector feeds the workflow-improvement skill.

---

### Workflow discovery and improvement

Users often have implicit workflows they've never articulated. They follow the same sequence of steps, skip the same step every time, or end every session with a manual cleanup that could be automated. Skills in this sphere:

- Give the implicit workflow a name and a formal description
- Identify which steps are always present, which are often skipped, and which are always the source of problems
- Suggest stages to add (e.g. "you always ship features but never write a test for the edge case you just discovered — here's where that step fits")
- Propose the right artifact for each stage (rule, slash command, agent, skill)

The output is a workflow brief: a named, stage-by-stage description of how the user actually does a type of task, with a recommendation for how to improve it.

---

### Rule creation

A focused single skill. It does not detect anything — it takes evidence produced by other skills and turns it into well-formed `CLAUDE.md` entries, `.cursor/rules/` files, or equivalent config for any supported tool, at global or project scope. It is the artifact router for the recommendation loop.

Good rules are specific, stable, and non-redundant. The rule-creator checks all three: it flags proposed rules that are too vague, that conflict with existing rules, or that duplicate something already in a skill or slash command.

This skill is a dependency for several other spheres — rules are the most common artifact the project produces.

---

### Documentation extraction

When a user explains the same module, API, or convention in chat repeatedly, the most likely cause is that it isn't documented in the project. Skills in this sphere:

- Detect repeated in-chat explanations of the same concept (across Claude Code sessions, Cursor sessions, or both)
- Identify the project location where a doc should exist but doesn't
- Draft the document from the conversation evidence (with user approval)
- Check existing docs for staleness against recent session mentions of the same concept

This sphere can grow into: doc structure auditing, doc quality improvement, ADR generation, README freshness, inline code comment detection, API surface documentation.

All artifacts here are project-scoped by nature — they live in the codebase.

---

### Slash command, agent, and skill generation

Different repetition shapes call for different artifact types:

- A repeated one-line prompt → a slash command (works in both Claude Code and Cursor)
- A repeated multi-turn workflow with consistent structure → a sub-agent definition
- A repeated context-plus-behavior combination → a skill

Skills in this sphere detect which shape the repetition takes and scaffold the right artifact. The goal is not just to generate a file — it's to identify the right primitive so the artifact is actually used.

---

### Skill discovery

The skill ecosystem is growing. A user facing a recurring problem might not know that a community skill already solves it. Skills in this sphere:

- Cross-reference recurring problem statements against known skill catalogs (`~/.claude/skills/`, community registries)
- Surface relevant skills with a brief explanation of how they match the user's specific evidence
- If no existing skill fits, recommend contributing one (and pre-populate the brief)

---

### Failure analysis and diagnostics

Sessions go badly. The context ran out. The model kept making the same mistake. The user gave up. Skills in this sphere cluster failed sessions by root cause:

- Missing context (the model didn't know something it needed to know)
- Permission gaps (the model couldn't take an action it needed to take)
- Ambiguous prompt (the user's request had multiple valid interpretations)
- Wrong model choice for the task complexity
- Tool unavailability (an MCP that should exist doesn't)

The output is a root cause with a specific fix: add this rule, grant this permission, install this MCP, switch to this model for this task type.

---

### Knowledge extraction

Sessions contain durable knowledge: decisions made, gotchas discovered, snippets that worked, constraints that can't be inferred from code alone. Skills in this sphere:

- Identify messages that contain durable insight (decisions, discovered constraints, working solutions to non-obvious problems)
- Propose where in the project that knowledge should live: a doc, a comment, an ADR, a CLAUDE.md note
- Draft the filing with user approval

The test: if a new collaborator (human or AI) needed to understand this project, is the knowledge in here the kind of thing they'd need? If yes, it should be filed.
