# Roadmap

This document describes what ships in each version and why things are ordered the way they are. It is not a promise of dates — it's a sequencing rationale.

---

## v0 — The closed loop

**Goal:** Prove that the platform works end-to-end across at least two tools. A user installs v0, runs it against their sessions, gets at least one concrete session-backed recommendation, and approves it into a rule. The full loop closes at least once.

### What ships

**Kernel (complete)**
- Source adapter for Claude Code (`~/.claude/projects/`)
- Source adapter for Cursor (`~/.cursor/projects/.../agent-transcripts/`)
- Session loader: reads from both adapters, returns unified `Session` objects with a `source` field
- Filter library: `byDateRange`, `byProject`, `bySource`, `byModel`, `byToolUsed`, `byOutcome`, `containingText`
- Redaction layer: JWT, API key, `.env`, and username-in-path stripping
- Recommendation contract: schema validation, `source` field required in evidence citations
- Artifact router: `rule` and `note` types for `CLAUDE.md` and `.cursor/rules/` files; conflict and redundancy checking
- Skill registry: basic inter-skill discovery

**Seed skills (implemented)**
- `vibe-stats` — zero-LLM, proves the kernel, scope model, and multi-tool merging
- `vibe-repetition-detector` — proves the evidence-to-recommendation pipeline including cross-tool patterns
- `vibe-rule-creator` — closes the loop; turns repetition evidence into written rules in the right tool's config

**Infrastructure**
- Offline test runner using `fixtures/` JSONL files (one per supported tool)
- Scope selection: global by default, `--project <path>` flag for project scope
- Basic CLI or slash-command invocation (design finalized at implementation time)

### What does not ship in v0

- `vibe-token-optimizer`, `vibe-doc-extractor`, `vibe-prompt-engineer` — documented as briefs in `docs/seed-skills.md`, not yet implemented. The briefs are there so contributors can start immediately.
- Skill catalog / community registry integration
- Any web UI or dashboard
- Additional tool adapters beyond Claude Code and Cursor

### Why this order

`vibe-stats` → `vibe-repetition-detector` → `vibe-rule-creator` is the smallest closed loop possible: stats proves the data layer, repetition proves the analysis layer, rule-creator proves the write layer. Cursor support is in v0 — not deferred — because the adapter needs to be proven against real session data before other skills build on it. Deferring it would mean discovering adapter problems after multiple skills already depend on the interface.

---

## v1 — Full seed coverage

**Goal:** Every seed skill is implemented. A contributor reading `docs/seed-skills.md` can find a working reference for every pattern: stats-only, optional LLM, required LLM, two-step LLM pipeline, cross-tool comparison, project-scope-only, and secondary evidence emission.

### What ships

**Remaining seed skills**
- `vibe-token-optimizer` — optional LLM path; extends the artifact router with `CLAUDE.md` and `.cursor/rules/` trim recommendations
- `vibe-doc-extractor` — two-step LLM pipeline; extends the artifact router with `doc` type; project-scope only
- `vibe-prompt-engineer` — LLM classification + teaching output; `note` artifact type; cross-tool comparison as a feature

**Kernel extensions** (driven by the three new skills)
- Artifact router: `doc`, `slash-command`, `agent`, and `skill` types
- Redaction layer: any new patterns surfaced by real v0 usage

**Contribution polish**
- Skill brief template (a starter file for new skill authors)
- Fixture generator helper (makes it easier to create synthetic JSONL for both Claude Code and Cursor formats)
- `CONTRIBUTING.md` improvements based on v0 contributor feedback

**Documentation**
- Skill catalog page: an index of all available skills with one-line descriptions, sphere labels, scope and tool-support indicators
- Install / getting-started guide (finalized from v0 placeholder)

### Why this order

v1 completes the reference set. After v1, a contributor choosing any sphere from `PHILOSOPHY.md` can find at least one working skill demonstrating the relevant pattern — LLM or not, global or project, single-tool or cross-tool, analysis or synthesis.

---

## v2 — Platform breadth

**Goal:** The adapter model is proven and documented well enough that adding a third tool is something a contributor can do independently, without touching the kernel.

### What ships

**Adapter stability**
- The source adapter interface is finalized and versioned. Adapters for Claude Code and Cursor are the reference implementations.
- Adapter authoring guide in `CONTRIBUTING.md`: how to read a new tool's session format, what edge cases to handle, how to write fixtures.

**New tool adapters** (contributed or built — candidates at v2 planning time)
- Any other AI coding tool that stores local, readable session history
- Cross-tool pattern detection improvements as more adapters are available

**New directions**
- At least one new sphere contributed by the community (the expectation is that v1's contribution infrastructure produces this organically)

**Maintenance**
- Kernel API stability guarantees: v2 commits to not breaking existing skill interfaces without a deprecation path
- Versioning for the recommendation contract schema

### Why this order

The adapter interface should stabilize against real usage in Claude Code and Cursor before being documented as a public API. v0 and v1 are the proving ground. v2 is when we say "here's how to add your own tool."

---

## Open questions (not blocking any version)

These are design decisions that can be deferred until they become concrete problems:

- **Packaging:** pip package, npm package, raw clone with a setup script, or a slash command that installs the skills into the user's tool? Depends on how skill installation evolves in each tool.
- **Update model:** How do users get updated versions of seed skills once installed? No answer yet.
- **Skill catalog discovery:** A community registry of skills from other contributors would be valuable in v2+. Format (GitHub topic, hosted index, file in this repo) is TBD.
- **LLM cost attribution:** Skills that use LLM calls should report an estimated cost before running. The mechanism for this is not designed.
- **Cross-tool identity:** When a user has sessions in both Claude Code and Cursor for the same project, vibe-os merges them by project path. If the user has different usernames or home directories across tools, this matching may fail. Needs a real-world test.
