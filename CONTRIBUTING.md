# Contributing

This project grows by adding skills. A skill is a focused piece of analysis — evidence in, recommendation out — that lives in one of the [directions of growth](PHILOSOPHY.md#directions-of-growth) described in the philosophy doc. This guide explains how to propose, build, and submit a skill.

---

## Before you build

**Read the philosophy.** Every skill must be evidence-driven, suggest rather than mutate, support both scopes, handle sessions from all supported tools uniformly, and conform to the recommendation contract. If any of those constraints feel wrong for your idea, raise that in an issue before writing code.

**Check what already exists.** Browse `skills/` to make sure you're not duplicating an existing skill. If a similar skill exists but doesn't cover your use case, consider extending it rather than creating a new one — or open an issue to discuss the boundary.

**Identify your sphere.** Locate the [directions of growth](PHILOSOPHY.md#directions-of-growth) section and find the sphere your skill belongs in. If your idea doesn't fit any existing sphere, that's interesting — open an issue with a proposal for a new direction before starting.

---

## Step 1: Write a skill brief

Before writing any code, write a one-page skill brief. This is a short document (can be a GitHub issue, a PR description, or a markdown file) that answers:

- **What does this skill observe?** Which session fields, message patterns, tool calls, or file references does it look at?
- **Which tools does it support?** Can it analyze Claude Code sessions, Cursor sessions, or both? If only one — why?
- **What does it recommend?** What artifact type does it propose (`rule`, `slash-command`, `doc`, `agent`, `skill`, `stat`, `note`)?
- **What does the evidence look like?** Give a concrete example of a session excerpt that would trigger a recommendation.
- **What is the proposed artifact?** Give a concrete example of what the output would look like.
- **Which scopes does it support?** Global, project, or both? If only one — why?
- **Does it need an LLM call?** If yes, at which step, and what is passed to the model?

The brief exists to catch design problems early. A skill that doesn't have a brief is not ready for review.

---

## Step 2: Create the skill directory

```
skills/
└── <your-skill-name>/
    ├── SKILL.md
    ├── references/      (optional)
    ├── scripts/         (optional)
    └── fixtures/
        ├── claude-code-example.jsonl   (synthetic Claude Code session)
        └── cursor-example.jsonl        (synthetic Cursor session, if applicable)
```

Naming conventions:
- All lowercase, hyphen-separated: `vibe-doc-extractor`, not `DocExtractor`
- Name describes what it does: `vibe-rule-creator`, not `vibe-rule-finder`
- Use the `vibe-` prefix for consistency with the seed skills (optional but recommended for discoverability)

---

## Step 3: Write `SKILL.md`

`SKILL.md` is both the skill's documentation and its operational instructions.

### Required frontmatter

```yaml
---
name: your-skill-name
description: >
  One concise paragraph describing what this skill does and when to invoke it.
  Be specific about trigger conditions. Mention the scope(s) and supported tools.
---
```

### Required body sections

**`## Scope`**
Which scopes this skill supports and what changes between global and project scope. If a scope is not supported, explain why.

**`## Tool support`**
Which AI tools' sessions this skill analyzes (Claude Code, Cursor, or both). If only one — explain why. Skills that can support both should support both.

**`## Evidence spec`**
What the skill looks for. Be specific enough that a developer can write the filter logic directly from this section.

**`## Output spec`**
What recommendations the skill produces. Include an example recommendation in the [recommendation contract](ARCHITECTURE.md#recommendation-contract) schema.

**`## Kernel usage`**
Which substrate layers the skill uses:
- Source adapters (specify which tools)
- Session loader (always)
- Filter library (which filters)
- Redaction layer (yes/no — required if any LLM calls are made)
- Artifact router (always — never write directly)
- Skill registry (optional)

**`## LLM usage`** (required)
If the skill calls a language model: which step, what input is passed (post-redaction), what the model is asked to do. If the skill does not call a model, state that explicitly — it's useful information.

**`## External calls`** (required if applicable)
Any network calls, their purpose, what data is sent, and how the user opts in. Omit this section if there are none.

---

## Step 4: Provide fixtures

Every skill must include at least one synthetic JSONL session file in `fixtures/` that exercises its core detection logic. Skills that support multiple tools should include a fixture for each.

Fixtures must:
- Be valid JSONL (one event object per line).
- Contain no real user data — fabricate realistic-looking but fictional sessions.
- Use the correct event schema for the tool they represent (Claude Code or Cursor).
- Cover the positive case (the pattern the skill is looking for is present).
- Ideally also cover a negative case (pattern is absent, skill correctly returns no recommendation).

---

## Step 5: Verify against the checklist

**Philosophy compliance**
- [ ] Every recommendation cites at least one session in `evidence[]`
- [ ] `excerpt` in each evidence item is post-redaction text
- [ ] The skill never writes to disk — it produces a recommendation for the artifact router
- [ ] The skill does not call a language model with un-redacted user text
- [ ] The skill supports global scope, project scope, or both — and SKILL.md states which
- [ ] The skill does not assume sessions come from a single specific tool

**Recommendation contract**
- [ ] Every output conforms to the schema in [ARCHITECTURE.md](ARCHITECTURE.md#recommendation-contract)
- [ ] `evidence[]` includes the `source` field for each citation
- [ ] `confidence` reflects real signal strength
- [ ] `proposedArtifact.type` is one of the valid types
- [ ] The skill returns an empty list when no pattern is found

**SKILL.md completeness**
- [ ] Frontmatter has `name` and `description`
- [ ] `## Scope` section present
- [ ] `## Tool support` section present
- [ ] `## Evidence spec` specific enough to implement from
- [ ] `## Output spec` with a concrete example
- [ ] `## Kernel usage` present
- [ ] `## LLM usage` present (even if "none")

**Fixtures**
- [ ] At least one fixture JSONL in `fixtures/`
- [ ] Fixture covers the positive detection case
- [ ] Fixture contains no real user data
- [ ] Fixture uses the correct schema for the tool it represents

**Kernel discipline**
- [ ] Skill does not open JSONL files directly
- [ ] Skill uses the filter library
- [ ] Skill uses the redaction layer before any LLM call
- [ ] Skill does not hard-code tool-specific paths

---

## Step 6: Open a pull request

PR description should include:
- Link to or inline copy of the skill brief
- Summary of any design decisions that differed from the brief
- Which seed skill this is most similar to, and how it differs
- Whether any new kernel functionality was needed (and if so, whether a separate PR adds it)

---

## Adding a source adapter (new tool support)

To add support for a new AI tool's session format:

1. Write a source adapter in `adapters/<tool-name>.js` (or equivalent) that exports `readSessions(scope: Scope) → Session[]`.
2. The adapter is responsible for: finding the tool's session files, parsing the raw format, and mapping events to the kernel's `Session` and `Event` types.
3. Provide at least one fixture JSONL file in `adapters/fixtures/<tool-name>/` showing the raw format.
4. Update `ARCHITECTURE.md` to document the new tool's session location and any format quirks.
5. Existing skills should work without modification — the adapter handles all translation.

---

## Proposing a new sphere

Open an issue before writing anything. Include:
- A plain-language description of the sphere
- Why it belongs in this project (which [core beliefs](PHILOSOPHY.md#core-beliefs) does it embody?)
- A sketch of what one or two skills in this sphere would do
- What artifact types they would produce

New spheres are welcome. The bar: grounded in session evidence, closes a real loop, produces artifacts that improve future sessions.

---

## Code of conduct

Be specific. Be evidence-driven. Don't moralize. When in doubt, look at how the seed skills handle the same situation.
