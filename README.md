# vibe-os

Your AI conversations are evidence about how you actually work. Every message you send, every tool that runs, every file that gets read, every retry you force — all of it is recorded locally by your AI coding tools. Today that evidence sits on disk and rots. **vibe-os** turns it into reusable artifacts: rules, skills, slash commands, agents, and documentation — at both global and per-project scope.

## Supported tools

| Tool | Session location |
|---|---|
| Claude Code | `~/.claude/projects/<encoded-path>/*.jsonl` |
| Cursor | `~/.cursor/projects/<encoded-path>/agent-transcripts/*.jsonl` |

The kernel abstracts both formats behind a unified `Session` type. Skills work the same way regardless of source.

## The problem

When you work with AI coding tools every day, you develop patterns. You re-type the same context. You re-state the same constraints. You explain the same module for the fifth time because it was never documented. You hit the same failure mode in every debugging session. You build a workflow in your head that would take five minutes to formalize — but you never do.

None of this is visible. There's no mirror.

## The shape of the solution

A shared kernel parses and indexes your session history from any supported tool. A growing set of skills — each focused on one angle — analyzes that data and surfaces concrete, evidence-backed recommendations. Every recommendation shows you which sessions it came from, proposes a specific artifact, and waits for your approval before writing anything.

The kernel and the recommendation contract are stable. The skills are where the project grows — and where contributors come in.

## Operating scopes

Every skill in this project works at two scopes:

- **Global** — across all your projects and sessions. Useful for personal habits, prompting patterns, cross-project waste, and anything that lives in `~/.claude/` or equivalent global config.
- **Project** — restricted to one project's sessions. Useful for missing project docs, project-specific rules, and workflows that only make sense inside one codebase. Artifacts are written into that project's `CLAUDE.md`, `.cursor/rules/`, or `docs/`.

When you run a skill, you choose the scope. The default is whichever makes more sense for that skill's purpose.

## Seed skills

These skills ship with the project to demonstrate every layer of the platform:

| Skill | Sphere | What it does |
|---|---|---|
| `vibe-stats` | Insightful stats | Behavioral statistics that change how you work |
| `vibe-token-optimizer` | Token optimization | Finds token waste and recommends concrete trims |
| `vibe-repetition-detector` | Pattern extraction | Surfaces recurring prompts, instructions, and sequences |
| `vibe-rule-creator` | Rule creation | Turns evidence into draft `CLAUDE.md` / `.cursor/rules/` entries |
| `vibe-doc-extractor` | Documentation extraction | Finds undocumented modules you keep explaining in chat |
| `vibe-prompt-engineer` | Prompt engineering | Teaches concrete prompt improvements from your own history |

See [docs/seed-skills.md](docs/seed-skills.md) for design briefs on each.

## Directions of growth

The seed skills cover six spheres. There are many more. See [PHILOSOPHY.md](PHILOSOPHY.md) for the full map and the principles that guide what belongs in this project.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). The short version: pick a sphere, write a skill brief, use the kernel, follow the recommendation contract, support both scopes, provide offline-runnable fixtures.

## Further reading

- [PHILOSOPHY.md](PHILOSOPHY.md) — core beliefs and directions of growth
- [ARCHITECTURE.md](ARCHITECTURE.md) — kernel layers, recommendation contract, scope model, privacy rules
- [CONTRIBUTING.md](CONTRIBUTING.md) — how to add a skill
- [docs/seed-skills.md](docs/seed-skills.md) — design briefs for all seed skills
- [docs/roadmap.md](docs/roadmap.md) — what ships in each version
