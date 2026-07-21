---
name: peer-agents
description: Bring independent AI peers from fresh Claude Code, Codex, or Cursor sessions into the current workflow for advice, critique, alternative approaches, comparison, or bounded delegated work. Use whenever the user explicitly asks to ask another AI, get a second or outside opinion, compare model answers, have Claude/Codex/Cursor review or help, delegate work to a peer, or configure peer checkpoints. Do not launch peers proactively unless an installed user rule requests it.
compatibility: macOS with cmux and at least one supported peer CLI (Claude Code, Codex, or Cursor Agent); direct headless fallback is available with user approval.
---

# Peer Agents

Bring another AI into the work as an independent peer, not as an echo of the current session. The value comes from assigning the right role, preserving a separate line of reasoning, and returning useful disagreement with clear provenance.

The current session is the coordinator. It decides what perspective or contribution is missing, gives each peer only the context needed for that role, supervises the run, and makes the final judgment. A peer never becomes the uncredited source of the coordinator's answer.

Read [references/tools.md](references/tools.md) before setup or execution. It is the sole operational reference for choosing models and modes, operating cmux, Claude Code, Codex, and Cursor, managing worktrees and sessions, and installing workflow rules.

## Operating principles

1. **Role is not model.** Define the contribution first—critic, alternative planner, reviewer, implementer, verifier, researcher, or another bounded role—then choose a suitable model and tool.
2. **Independence is deliberate.** Fresh peers do not receive other peers' answers. Do not preload the coordinator's full reasoning when the peer is meant to supply an outside view.
3. **Diversity means model-family diversity.** A different CLI using the same underlying model is not an independent model perspective. Prefer a different family from the coordinator when the model is known.
4. **Context is selected, not dumped.** Send the request, relevant repository paths or artifacts, constraints, and success evidence. Do not send unrelated transcript history, secrets, or private material.
5. **Authority follows intent.** Advice is read-only. Editing requires an explicit delegation and an isolated worktree. Never merge, cherry-pick, commit to the user's branch, or delete a worktree unless separately requested.
6. **Synthesis preserves provenance.** Combine compatible insights, retain valuable disagreement, and explain rejected recommendations. Do not vote, average, or concatenate blindly.

## Activation

Activate only when the user explicitly requests another AI or when a user-installed workflow rule calls for this skill. Ordinary planning, implementation, or review does not trigger it automatically.

Treat the user's explicit request as consent for an ordinary configured read-only consultation. Confirm before launch when:

- the necessary context is sensitive or unexpectedly broad;
- editing authority is unclear;
- the requested panel materially exceeds saved cost or latency preferences;
- the requested provider is unavailable and substitution would change intent;
- cmux is unavailable and direct headless execution would reduce visibility.

## Load preferences

Use this precedence, with later discovery never overriding an earlier explicit choice:

1. Current user request: provider, model, count, role, access, and output instructions.
2. Project override at `<repo>/.vibe-os/peer-agents.yaml`, when present.
3. Global preferences at `~/.config/vibe-os/peer-agents.yaml`.
4. Safe defaults below.

Safe defaults:

- one peer;
- a provider and underlying model family different from the coordinator;
- fresh session;
- read-only access;
- one cmux workspace for the batch;
- synthesis with attributed findings;
- preserve the peer workspace when follow-up may be useful.

If the global file does not exist, perform first-run setup before the first launch:

1. Detect cmux and the supported CLIs without making a model call.
2. Discover locally advertised models where the CLI supports it.
3. Ask which providers to enable and whether each should use its CLI default or a named model. Do not infer these preferences merely because a provider was mentioned; a dry-run proposal must still surface the choices as explicit questions.
4. Explain that prompts and selected repository context are sent to those providers and may create charges.
5. State the effective precedence—explicit request, project override, global preferences, then safe defaults—so the user can predict which setting wins.
6. Show the proposed YAML and obtain approval before writing it. Store commands and preferences only—never credentials.

Use this minimal shape:

```yaml
version: 1
providers:
  claude: {enabled: true, command: claude, model: default}
  codex: {enabled: true, command: codex, model: default}
  cursor: {enabled: false, command: agent, model: default}
defaults:
  peers: 1
  cmux_layout: batch-workspace
  result_style: synthesis-with-attribution
```

Create a project override only when the user requests project-specific behavior. Never place credentials in either file.

## Define the engagement

Before launching, create one compact peer brief per peer with these fields:

```markdown
# Peer brief
Role: <the contribution this peer owns>
Objective: <the question or bounded task>
Context: <repository root and exact relevant paths/artifacts>
Deliverable: <what the peer must return or create>
Constraints: <scope, compatibility, cost, time, and prohibited actions>
Access: read-only | isolated-worktree
Independence: Work independently; do not seek or infer other peers' answers.
Success evidence: <how the coordinator can judge the result>

You are a leaf peer in an externally coordinated run. Do not invoke peer-agents,
spawn another AI, or delegate the task. Inspect the real project when useful.
If blocked, return `BLOCKED:` with the exact missing input or failed dependency.
Be decisive, identify uncertainty honestly, and report evidence and changed paths.
```

Adapt the wording to the role. Do not force every peer to solve the whole task when complementary roles would create more value.

## Select peers

Honor explicit provider, model, count, and role choices. Otherwise:

1. Identify the coordinator's underlying model family when possible.
2. Filter to enabled, installed, authenticated providers.
3. Use the tool reference to map the role and authority to the provider's real mode; never assume headless means read-only.
4. Prefer one peer from a different model family.
5. Use saved task-fit preferences when available; otherwise use the provider's configured default. For controlled comparisons, pin exact models and effort parameters instead of accepting `auto` or fallback.
6. Record requested and actual model identities. If no genuinely different family is available, disclose that and ask whether to use the best available same-family peer.

For multiple peers, run independent work in parallel when their write scopes cannot collide. Never expose one peer's result to another until all independent runs finish. A later critique or handoff is a new, explicit stage.

## Isolate authority

For read-only work, point the peer at the current repository and enforce the provider's read-only or planning mode.

For editing work:

1. Inspect repository status and determine the base revision.
2. Create one named worktree and branch per peer outside the main working tree.
3. If relevant changes are uncommitted, stop and ask whether to delegate from the clean base or create an explicit snapshot. Do not silently omit, stash, commit, or copy dirty state.
4. Restrict the peer to its worktree and stated task.
5. Preserve the worktree after completion and report its path, branch, changes, and verification. Integration belongs to a later user-approved action.

## Run and supervise

Create a unique run directory under `${TMPDIR:-/tmp}/peer-agents-<run-id>/`. Keep orchestration files outside the repository. Write:

- `brief.md` for the batch objective, shared context boundary, and common constraints;
- `brief-<peer>.md` for each peer;
- `<peer>.md` for the final response;
- `<peer>.raw.json` or `<peer>.raw.jsonl` when the CLI exposes structured events;
- `manifest.json` for provenance and lifecycle state.

The manifest records `run_id`, `objective`, `cmux_workspace`, and one entry per peer with `provider`, effective `model`, `requested_model`, `actual_model`, `model_family`, `role`, `access`, `session_id`, `worktree`, `status`, `result_path`, and `exit_code`. Use statuses `pending`, `running`, `complete`, `blocked`, `failed`, or `cancelled`.

Prefer a visible cmux batch workspace with one terminal per peer. Launch non-interactive CLI runs inside those terminals and capture their final messages to result files. Wait on process exit or explicit completion signals; terminal screen text is diagnostic evidence, not the completion protocol.

During long runs, provide concise progress updates. If a peer blocks, preserve its exact question and session identifier, ask the user only when the answer is material, then resume that peer when supported. A timeout, failed provider, or cancelled peer remains an attributed partial failure.

Do not close an ongoing collaborator workspace. For a one-shot consultation, offer cleanup after the results have been captured. When continuity is ambiguous, leave the workspace open.

## Synthesize in the main session

Read every successful result from its exact artifact path. Check important claims against the repository or available evidence rather than trusting confident prose.

Return:

1. **Conclusion** — the coordinator's best answer or recommended action.
2. **Attributed peer findings** — provider, model, role, and the distinct contribution from each peer.
3. **Consensus and divergence** — agreements, meaningful conflicts, and what was discarded with reasons.
4. **Next action** — what the coordinator recommends doing now.
5. **Run details** — failed or blocked peers, raw result paths, open cmux workspace, and any worktree/branch paths.

Keep the synthesis proportional to the task. Do not paste full raw responses unless the user asks; preserve them in the run directory and make their location clear.

## Workflow integration

When asked to make peer consultation easier or automatic, use the opt-in snippets in the tools reference. Distinguish:

- explicit phrase aliases that merely make invocation memorable;
- checkpoints that ask whether to consult a peer;
- automatic launch rules, which require especially clear provider, cost, context, and authority limits.

Inspect the target rule file, avoid duplicate or conflicting guidance, show a syntactically valid exact diff with correct hunk counts, and obtain approval before writing. Validate the proposed patch without applying it. Child peer briefs must retain the leaf-peer recursion guard even when workflow rules are installed.
Any installed checkpoint or automatic-launch rule must also say that spawned peers cannot invoke `peer-agents`, spawn another AI, or delegate further.
