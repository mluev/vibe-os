# Peer Agents Tool Reference

Read this file only when setting up or running peer sessions. Prefer live `--help` output over these recipes when an installed version differs.

## Guide map

- [Choose the tool, model, and mode](#choose-the-tool-model-and-mode)
- [Claude Code](#claude-code), [Codex](#codex), and [Cursor Agent](#cursor-agent)
- [Worktrees for editing peers](#worktrees-for-editing-peers)
- [Completion and interruption](#completion-and-interruption)

## Preflight

Resolve installed commands without making model calls. Preserve the resolved cmux path because the app-bundled CLI may exist even when `cmux` is absent from `PATH`:

```bash
PEER_CMUX_BIN="$(command -v cmux 2>/dev/null || true)"
if [ -z "$PEER_CMUX_BIN" ] && [ -x /Applications/cmux.app/Contents/Resources/bin/cmux ]; then
  PEER_CMUX_BIN=/Applications/cmux.app/Contents/Resources/bin/cmux
fi
printf 'cmux=%s\n' "${PEER_CMUX_BIN:-missing}"
printf 'claude=%s\n' "$(command -v claude 2>/dev/null || printf missing)"
printf 'codex=%s\n' "$(command -v codex 2>/dev/null || printf missing)"
printf 'cursor=%s\n' "$(command -v agent 2>/dev/null || command -v cursor 2>/dev/null || printf missing)"
```

Capture this output and base availability claims on it. If `PEER_CMUX_BIN` is set, use `"$PEER_CMUX_BIN"` wherever the examples below show `cmux`; do not report cmux missing merely because it is not in `PATH`.

Inside a cmux-launched terminal, inspect caller context and access:

```bash
"$PEER_CMUX_BIN" capabilities --json
"$PEER_CMUX_BIN" identify --json
```

Use `CMUX_WORKSPACE_ID`, `CMUX_SURFACE_ID`, and `CMUX_SOCKET_PATH` before focused-window fallbacks. Never change focus merely to make automation succeed.

Model discovery is provider-specific:

```bash
agent models                    # Cursor account catalog; may require network/auth, no inference
claude --help                   # accepts aliases/full IDs; does not enumerate the account catalog
codex --help                    # accepts --model; does not enumerate the account catalog
```

Authentication or doctor commands may contact the provider; use them only when launch fails or the user requests setup.

## Choose the tool, model, and mode

Choose in this order: **role → authority → model family → CLI → exact model → effort/budget → session policy**. A CLI is a control surface, not a capability claim: Cursor can route several model families, and the same model family in two CLIs is not a diverse peer.

| Need | Claude Code | Codex | Cursor Agent |
|---|---|---|---|
| Explanation or advice | `--permission-mode plan` | `exec --sandbox read-only` | `--mode ask` |
| Alternative implementation plan | `--permission-mode plan` | `exec --sandbox read-only` with a plan deliverable | `--mode plan` |
| Repository review | plan mode with a review brief | `review` for a diff/commit, otherwise read-only `exec` | `--mode ask` with a review brief |
| Editing | `acceptEdits` inside an isolated worktree | `workspace-write` inside an isolated worktree | default agent mode inside an isolated worktree |
| Native worktree option | `--worktree [name]` | none; coordinator creates it | `--worktree [name] --worktree-base <ref>` |
| Structured capture | JSON or stream JSON; optional JSON Schema | JSONL plus last-message file; optional output schema | JSON or stream JSON |

Treat planning and access as separate choices. A strong model in an editing mode still has editing authority; a planning model in a read-only mode cannot safely be treated as an implementer. Verification commands that generate files, caches, snapshots, or formatter changes count as editing and belong in a worktree.

### Pick and verify the model

1. Honor an explicit model or family exactly. If unavailable, report that before substituting.
2. For an independent opinion, prefer a family different from the coordinator. Check the underlying model, not the CLI name.
3. For a controlled comparison, pin exact model IDs and relevant effort parameters. Disable optional fallbacks and reject silent `auto` substitution.
4. For ordinary advice where reproducibility is unimportant, the configured default or Cursor `auto` is acceptable. Record the actual returned model when available.
5. Use saved role-to-model preferences only as routing hints. Do not invent “best model” rankings; availability, price, context size, and behavior change.
6. Record `requested_model`, `actual_model`, `model_family`, effort parameters, and any fallback in the manifest. A fallback is a run fact, not the requested model.

Use a smaller/cheaper configured model only when the role is bounded and its success can be checked cheaply. Use a deeper model or higher effort for ambiguous architecture, adversarial critique, or synthesis where missed reasoning is costly. Context size is a requirement derived from the selected inputs, not a reason to send unrelated files.

### Choose session continuity

- Start fresh for independent advice, parallel comparisons, and first-pass reviews.
- Resume only to answer a blocker, request a correction, or continue an explicitly ongoing collaborator. Reusing a session also reuses its context and biases.
- Fork rather than resume when the original line of reasoning must remain intact; Claude supports `--fork-session` with resume. Otherwise create a new peer stage with a new brief.
- Ephemeral/no-persistence modes reduce retained local session state but prevent later continuation. Use them only when follow-up is unlikely or the user prefers it.
- Never use “continue latest” in unattended orchestration when an exact recorded session ID is available.

## Run artifacts

Choose a collision-resistant identifier and create a private run directory:

```bash
PEER_RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
PEER_RUN_DIR="$(mktemp -d "${TMPDIR:-/tmp}/peer-agents-${PEER_RUN_ID}.XXXXXX")"
chmod 700 "$PEER_RUN_DIR"
```

Write the batch `brief.md`, the role-specific `brief-<peer>.md` files, and `manifest.json` before launch. Prompts and results may contain private repository context; disclose the directory and do not copy it into the repository.

Use a unique completion token per peer. A terminal wrapper should always record the process exit code and signal completion, even on failure. Prefer `cmux wait-for <token> --timeout 30` in a loop so the coordinator can report progress rather than blocking silently.

## cmux batch workspace

Create one workspace for the batch from the caller's window, record the returned handle, then rename it. Do not use `select-workspace`, `focus-pane`, or `focus-panel` unless the user explicitly asks to watch it.

```bash
cmux --json new-workspace --cwd "$PROJECT_ROOT"
cmux rename-workspace --workspace workspace:<n> -- "peers: <short task>"
```

Create one terminal pane per peer when the layout remains readable; otherwise add terminal surfaces to the batch workspace. Always target the recorded workspace/pane explicitly.

```bash
cmux --json new-pane --workspace workspace:<n> --type terminal --direction right
cmux --json new-surface --workspace workspace:<n> --pane pane:<n> --type terminal
cmux rename-tab --workspace workspace:<n> --surface surface:<n> "<provider> · <role>"
cmux send --workspace workspace:<n> --surface surface:<n> -- "<shell command>\n"
```

Operational status belongs on the batch workspace:

```bash
cmux set-status peers running --workspace workspace:<n> --color '#ff9500'
cmux set-progress 0.5 --workspace workspace:<n> --label '1/2 peers complete'
cmux surface-health --workspace workspace:<n> --json
cmux read-screen --surface surface:<n> --scrollback --lines 200
cmux clear-status peers --workspace workspace:<n>
cmux clear-progress --workspace workspace:<n>
cmux trigger-flash --workspace workspace:<n> --surface surface:<n>
```

`read-screen` is for diagnosis only. Completion comes from exit status/result artifacts or a unique `wait-for` signal.

If cmux is missing or denies socket access, explain the loss of visibility and ask before running the same commands directly. Do not change cmux settings automatically.

## Claude Code

Fresh planning/review peer:

```bash
claude -p \
  --permission-mode plan \
  --disable-slash-commands \
  --model '<configured-model>' \
  --output-format json \
  < "$PEER_RUN_DIR/brief-claude.md" \
  > "$PEER_RUN_DIR/claude.raw.json"
```

Use the CLI default by omitting `--model`. Extract the final result and `session_id` from the JSON into `claude.md` and the manifest. `--disable-slash-commands` prevents skill recursion; the brief's leaf-peer instruction remains required.

Claude controls are orthogonal:

- `--permission-mode plan` prevents editing while allowing repository analysis. For a strict file-only consultation, additionally restrict `--tools` to the required read tools; do not grant shell access reflexively.
- `--permission-mode acceptEdits` authorizes edits, so run it only from the peer's isolated worktree. Do not use `bypassPermissions` or `--dangerously-skip-permissions`.
- `--effort low|medium|high|max` controls reasoning depth separately from the model. `--max-budget-usd` is a useful hard ceiling for unattended print-mode runs.
- `--fallback-model` changes reproducibility. Do not set it for controlled comparisons; if used for availability, record whether fallback occurred.
- `--json-schema` can enforce a review or plan result shape. Keep the human-readable `<peer>.md` artifact as well.

Claude's native `--worktree [name]` is convenient for a single Claude-only collaborator. Prefer coordinator-created worktrees for multi-provider batches so paths, branches, bases, and cleanup are uniform. Never combine both approaches for one peer.

Continue only for an intended follow-up:

```bash
claude -p --resume '<session-id>' --output-format json < follow-up.md
```

Add `--fork-session` when the follow-up should branch without modifying the original session. Use `--no-session-persistence` only for a deliberate one-shot run.

## Codex

Read-only fresh peer with no interactive approval deadlock:

```bash
codex -a never exec \
  --sandbox read-only \
  --cd "$PROJECT_ROOT" \
  --model '<configured-model>' \
  --json \
  --output-last-message "$PEER_RUN_DIR/codex.md" \
  - < "$PEER_RUN_DIR/brief-codex.md" \
  > "$PEER_RUN_DIR/codex.raw.jsonl"
```

Omit `--model` to use the configured default. Capture the thread/session identifier from JSONL when available. For editing, change `--cd` to the isolated worktree and use `--sandbox workspace-write`; keep approval policy `never` so denied operations fail visibly instead of waiting in an unattended terminal. Do not use the dangerous bypass flag.

Codex has no named plan mode: `--sandbox read-only` supplies the authority boundary and the peer brief supplies the planning deliverable. Use `--output-schema` when a machine-checked response contract matters. `--profile` can select a saved configuration, but an explicit user model still wins; record the resolved model from JSONL when exposed.

Use `codex review --uncommitted`, `--base <branch>`, or `--commit <sha>` only for those exact diff-oriented roles. Use read-only `exec` for architecture review, alternative plans, or custom evidence requirements. Codex has no native worktree flag, so editing peers always use a coordinator-created worktree.

Continue an intended follow-up with the recorded session:

```bash
codex exec resume '<session-id>' - < follow-up.md
```

Use `--ephemeral` for a deliberate one-shot run; it prevents later resume. Never use `--last` when several peers may have run concurrently.

## Cursor Agent

Use `agent` as the canonical CLI; some installations expose it through `cursor agent`.

Read-only fresh peer:

```bash
agent -p \
  --mode ask \
  --sandbox enabled \
  --trust \
  --workspace "$PROJECT_ROOT" \
  --model '<configured-model>' \
  --output-format json \
  < "$PEER_RUN_DIR/brief-cursor.md" \
  > "$PEER_RUN_DIR/cursor.raw.json"
```

Use `--mode plan` when the deliverable is explicitly a plan. Omit `--model` for Cursor's configured automatic selection, but record the actual returned model family when available.

Cursor print mode has access to editing and shell tools by default. Read-only authority therefore depends on `--mode ask` or `--mode plan`, not on `-p` alone:

- `ask` is best for explanations, critique, and review without a plan-shaped deliverable.
- `plan` is read-only and asks for an implementation plan.
- Editing uses the default agent mode, an isolated worktree, and `--sandbox enabled`. Do not use `--force`, `--yolo`, or disable the sandbox merely to avoid an approval; report a blocked action instead.

`agent models`/`--list-models` reads the account's available catalog and may require network/auth, though it does not run inference. Cursor model IDs may include quoted parameters such as context, effort, or fast mode. Pin the full string for comparisons; with `auto`, record the returned actual model and family.

Cursor's native `--worktree [name] --worktree-base <ref>` is suitable for a single Cursor-only collaborator. Prefer coordinator-created worktrees for cross-provider comparison, and point `--workspace` to the recorded path. Never request both native and coordinator worktree creation for one peer.

Resume only when follow-up is intended:

```bash
agent -p --resume '<chat-id>' --output-format json < follow-up.md
```

## Worktrees for editing peers

Use one branch, one worktree path, and one peer session per editing peer. Resolve and validate exact targets before creating anything:

```bash
PEER_REPO_ROOT="$(git rev-parse --show-toplevel)"
PEER_REPO_NAME="$(basename "$PEER_REPO_ROOT")"
PEER_BASE_SHA="$(git -C "$PEER_REPO_ROOT" rev-parse HEAD)"
PEER_WORKTREE_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/vibe-os/peer-agents/worktrees/$PEER_REPO_NAME/$PEER_RUN_ID"
PEER_NAME='<provider-role-slug>'
PEER_BRANCH="peer-agents/$PEER_RUN_ID/$PEER_NAME"
PEER_WORKTREE="$PEER_WORKTREE_ROOT/$PEER_NAME"
git -C "$PEER_REPO_ROOT" status --short
git -C "$PEER_REPO_ROOT" worktree list --porcelain
git -C "$PEER_REPO_ROOT" worktree add -b "$PEER_BRANCH" "$PEER_WORKTREE" "$PEER_BASE_SHA"
git -C "$PEER_WORKTREE" rev-parse --show-toplevel HEAD
```

If relevant state is dirty, stop before `git worktree add` and ask whether to use clean `HEAD` or an explicit snapshot. Never stash, commit, or copy the user's changes implicitly.

Manage the lifecycle explicitly:

1. Record the base SHA, branch, path, provider, and session ID before launch. All peers in a fair comparison start from the same approved base.
2. Run repository setup inside each worktree. Do not share writable build outputs, indexes, or dependency directories between concurrent peers unless the project explicitly supports it.
3. Constrain the peer's working directory to its worktree. Confirm the reported changed paths are inside that root.
4. After completion, capture `git status --short`, `git diff --stat`, the full diff or commit SHA, and verification output. A clean exit without these artifacts is not an implementation handoff.
5. Leave changes uncommitted unless the delegated deliverable requests a commit. A commit in the peer branch is allowed; merging, cherry-picking, pushing, or changing the user's branch is not.
6. Keep the worktree while comparison, correction, or follow-up is plausible. Report its exact path and branch in the synthesis.
7. Remove a worktree or branch only after a separate cleanup request and a fresh dirty-state check. Do not force removal, prune broadly, or delete a branch containing unintegrated work.

Use provider-native `--worktree` only when the provider owns the whole lifecycle and returns the exact path/base. Otherwise create it here and pass the path through Claude's working directory, Codex `--cd`, or Cursor `--workspace`.

## Completion and interruption

Wrap each terminal command so failure still produces a status and completion signal. Use a peer-specific token and explicit paths; do not interpolate untrusted prompt text into the shell command.

```bash
sh -lc '<provider command>; peer_exit=$?; printf "%s\n" "$peer_exit" > "<run-dir>/<peer>.exit"; cmux wait-for -S "<token>"; exit "$peer_exit"'
```

On cancellation, send the terminal interrupt key to the exact recorded surface, mark the peer `cancelled`, and preserve partial artifacts:

```bash
cmux send-key --surface surface:<n> ctrl-c
```

Never treat missing output as an empty opinion. Report `blocked`, `failed`, `cancelled`, or `timed out` with provider, model, exit status, and diagnostic location.

## Optional workflow rules

Install only when requested. Inspect the target, show an exact diff, validate its syntax and hunk counts without applying it, and obtain approval before writing. Prefer a short pointer over copying this skill into a rules file.

Portable explicit-trigger snippet for `CLAUDE.md` or `AGENTS.md`:

```markdown
When I explicitly ask to "ask a peer", "get another AI opinion", "compare with
Claude/Codex/Cursor", or "delegate to a peer", use the peer-agents skill. Do not
launch external peers proactively. Preserve provider attribution and ask before
expanding access, cost, or sensitive context.
```

Optional checkpoint snippet:

```markdown
At the configured workflow checkpoint, briefly ask whether an independent peer
would add value. Launch peer-agents only after confirmation and state the proposed
role, provider count, access level, and context boundary. A spawned peer must not
invoke peer-agents, spawn another AI, or delegate its task further.
```

Cursor project rule at `.cursor/rules/peer-agents.mdc`:

```markdown
---
description: Invoke independent external AI peers only on explicit request
alwaysApply: true
---
When the user explicitly asks for another AI opinion, model comparison, external
review, or delegated peer work, use the peer-agents skill. Never recurse from a
spawned peer session or launch automatically without a separately approved rule.
```

For personal defaults, use the host's documented global guidance location; for shared team behavior, prefer a repository rule. Avoid duplicate trigger blocks and preserve unrelated existing instructions.
