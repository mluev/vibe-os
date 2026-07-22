---
name: peer-agents
description: Open fresh Claude Code, Codex, or Cursor sessions in visible cmux tabs and use them as independent colleagues — for a second opinion, planning, review, comparison, or delegated help. Use whenever the user wants an opinion from another AI, wants Codex/Cursor/Claude to check, review, or plan something, wants to compare model answers, wants several agents to plan or explore approaches in parallel, or wants to delegate bounded work to a peer session. Keep the sessions interactive so the coordinating AI can read their chats and ask follow-ups.
compatibility: macOS with cmux and at least one supported AI CLI (Claude Code, Codex, or Cursor Agent).
---

# Peer Agents

Bring another AI into the current work as a visible, independent colleague — not
an echo of the current session. The coordinator opens fresh AI chats in cmux,
gives each a useful role, reads their answers from the terminal, follows up when
needed, and returns its own judgment in the main chat.

## Why bring in peers

The useful question is not *which model is best* — it is *which role is missing*.
A second AI is worth the cost when its **separate line of reasoning** adds
something the current session cannot produce on its own:

- **Combine compute, don't pick one.** Two independent thought chains, merged
  with attribution, beat a single chain — one model's planning depth complements
  another's execution or breadth.
- **Break the echo chamber.** A fresh session with no exposure to the
  coordinator's reasoning won't rationalize the coordinator's mistakes.
- **Different model families fail differently.** A different family catches bugs,
  blind spots, and bad assumptions that the same family would repeat.
- **No self-grading.** Independent review and verification are only meaningful
  when the reviewer is not the author.
- **Cheap parallel exploration.** Several peers can chase alternative approaches
  at once, so you compare real options instead of imagining them.

This skill gives you the *ability* and the *reasons*. You write the actual
prompts and decide the use case.

Read [references/tools.md](references/tools.md) before launching peers. It is the
only operational reference.

## When it fires

Use this skill only when the user explicitly asks for another AI, or when an
installed workflow rule requests a peer checkpoint. It never launches peers on its
own. Natural triggers include:

- "get an opinion from another agent" / "ask another AI what it thinks"
- "check it with Codex" / "have Cursor review my work"
- "plan it across several agents" / "let a few agents explore approaches"
- "compare Claude vs Cursor on this" / "which approach do the others prefer"
- "delegate this to a peer" / "have another agent implement it"

Ordinary planning and review do not trigger it. An explicit request normally
authorizes opening the requested read-only or plan sessions. Ask before sending
unusually sensitive context, starting an expensive panel, substituting a
specifically requested provider or model, or giving a peer editing authority the
user did not request.

## Patterns

Starting points, not scripts — pick one, combine them, or invent your own. The
user's prompt and goal decide the shape.

- **opinion** — put the same question to one or two peers independently, then
  compare their answers side by side.
- **fusion** — peers work in parallel; the coordinator merges the results with
  attribution, calling out consensus versus divergence.
- **validate / gate** — a peer defines acceptance criteria up front or reviews
  the finished work. The author never validates its own output.
- **plan** — one or more peers produce alternative implementation or migration
  plans to compare against the coordinator's.
- **review** — a peer critiques a diff, plan, or artifact and cites concrete
  evidence from the real project.
- **delegate** — a peer implements a bounded task (see [Editing peers](#editing-peers)).

## Core principles

- **Role is not model.** Decide the missing contribution first — critic,
  alternative planner, reviewer, verifier, implementer — then choose a provider.
- **Independence is deliberate.** Do not feed parallel peers one another's answers
  in the first round, and do not preload the coordinator's full reasoning when the
  peer is meant to supply an outside view. A later "critique this answer" exchange
  is a separate stage.
- **Diversity means model-family diversity.** A different CLI running the same
  underlying model is not an independent perspective. Prefer a different family
  when the model is known; if the family is unknown, say so rather than claim
  diversity.
- **Select context, don't dump it.** Send the request, the relevant paths and
  facts, the constraints, and what a good answer looks like — not the whole
  transcript, a premature conclusion, or private material.
- **Authority follows intent.** Advisory peers launch read-only with approvals
  disabled — safe and non-blocking, since a read-only peer cannot modify the repo.
  Escalate to write access or auto-approved edits only for an explicit editing
  delegation; never merge, discard, clean, or commit another peer's work without a
  separate request.
- **Synthesis preserves provenance.** Attribute each contribution, keep valuable
  disagreement, and explain what you rejected. Do not vote, average, or
  concatenate blindly. The coordinator checks claims and owns the final call.

## Workflow

1. **Understand the work.** Inspect the relevant repository, sibling project, plan, or artifact before briefing peers. Give concrete paths and facts.
2. **Choose peers.** Honor explicit provider, model, count, role, and mode
   requests. Otherwise pick one complementary peer with a clear role. On the first
   run the skill does a quick environment check — which CLIs and cmux are installed
   and a default peer of a different model family — and caches it, so later runs are
   fast; see [references/tools.md](references/tools.md).
3. **Open visible sessions — fast and non-blocking.** Use cmux to create one
   workspace for the consultation with a terminal tab or pane per peer. Launch each
   advisory peer in a *single* command that starts its real interactive UI
   **read-only with approval prompts disabled** and passes the brief as the CLI's
   positional prompt, so it submits at startup — no separate send, no waiting for a
   "ready" screen, no stalling on permission or trust prompts. Keep inspection
   commands off the happy path. Do not hide a provider behind a worker process or
   redirect its chat to files — the user should be able to watch and take over
   every peer. See [references/tools.md](references/tools.md) for the exact flags.
4. **Brief each peer.** The brief carries its role and objective, the relevant
   paths, the requested deliverable, the constraints (including plan/read-only
   intent), a request to inspect the real project and surface uncertainty, and a
   note to work independently without spawning more agents. Tell each peer the
   distinct contribution it owns.
5. **Collaborate through the tab.** Read the screen to follow progress and extract
   the answer. When it is incomplete, ambiguous, or worth challenging, send a
   follow-up into the same tab. Use judgment, not a rigid completion protocol.
   Report authentication, quota, model, or tool errors plainly — never call a
   silent, failed, or blocked peer an agreement.
6. **Synthesize.** Return the coordinator's conclusion, each peer's attributed
   contribution (with provider/model when known), the important agreement and
   disagreement, the recommended next action, and any failure plus which tabs
   remain open. Leave sessions open for follow-up; close them only when asked.

cmux gives the best experience — visible tabs the user can watch, continue, and
take over. If it is inaccessible, say so, recommend running from inside cmux, and
offer the no-cmux fallback: run each peer non-interactively (print/exec mode) and
read its output directly, accepting the loss of a live chat. See the "Without
cmux" section in [references/tools.md](references/tools.md).

## Editing peers

If the user explicitly asks a peer to implement something, use the provider's
normal editing experience. Choose the current checkout for collaborative work or a
native worktree when isolation is useful — explain the choice when it affects
uncommitted changes or later integration. A worktree starts from committed state
and may omit relevant dirty changes; surface that trade-off. Do not merge,
discard, or clean another peer's work without a separate request.

## Workflow rules

Install automatic peer checkpoints only when requested. Inspect the target rule
file, show the exact proposed diff, and get approval before changing it. Keep the
rule explicit about when peers launch, which context may be shared, and that peer
sessions must not recursively invoke more peers. If the user wants a memorable
trigger, propose a small snippet — see the optional host rule in
[references/tools.md](references/tools.md).
