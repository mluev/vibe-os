# Peer Agents Tool Reference

Use cmux as the conversation transport. The terminal chat is the source of truth;
do not create a separate runner, manifest, or result artifact.

The patterns share one vocabulary with the skill: **opinion** (same question,
independent answers, compared), **fusion** (parallel work merged with
attribution), **validate/gate** (a peer sets criteria or reviews; the author never
grades itself), plus **plan**, **review**, and **delegate**. These are starting
points, not fixed procedures.

## Environment check (init)

Learn the machine once, then reuse it. The cache is
`~/.config/vibe-os/peer-agents-env.md`.

- **First use (cache absent):** probe availability in a single call, then write
  the cache:

  ```bash
  command -v codex claude cursor-agent cmux
  ```

  Determine the **coordinator** (the AI running this skill) and pick a **default
  peer whose model family differs** from it (e.g. a Claude coordinator defaults to
  Codex; a Codex coordinator defaults to Claude). Record which CLIs exist, whether
  cmux is present, the default peer, and the known-good read-only launch command
  per provider.

- **Later runs:** read the cache instead of re-probing. Re-probe only when a launch
  actually fails or the user asks (e.g. "peer-agents init").

- **Self-learning:** when an observed command or flag differs from what this
  reference documents, append it to the cache's **"launch overrides / quirks"**
  list so future launches use the known-good form. cmux builds vary — treat the
  installed binary as the source of truth over any doc.

Cache shape (human-editable markdown; create the directory if missing):

```markdown
# peer-agents environment (auto-discovered; edit freely)

cmux: available
coordinator: claude
default peer: codex        # different model family

providers:
- codex        ✓  read-only: codex --no-alt-screen -C PATH -s read-only -a never "<BRIEF>"
- claude       ✓  read-only: claude --add-dir PATH --permission-mode plan "<BRIEF>"
- cursor-agent ✓  read-only: cursor-agent --workspace PATH --plan --force --trust "<BRIEF>"

launch overrides / quirks:
- (append when an observed command/flag differs from references/tools.md)
```

## Fast launch

Optimize for the fewest calls. Launch each advisory peer in **one command** that
starts its CLI read-only, disables approval prompts, and passes the brief as the
CLI's positional prompt — so it submits at startup with no separate send, no Enter
keystroke, and no polling for a "ready" UI. Keep inspection out of the happy path.

```bash
# (optional) confirm control only if unsure you are inside cmux
cmux ping

# Peer 1 — fresh workspace, launched read-only + non-blocking, already briefed.
# Its initial surface runs the peer; new-workspace returns only the workspace id.
cmux new-workspace --cwd /abs/project \
  --command 'codex --no-alt-screen -C /abs/project -s read-only -a never "<BRIEF 1>"'
# → OK workspace:N

# One lookup to get peer 1's initial surface handle (call it surface:A):
cmux list-pane-surfaces --workspace workspace:N

# Peer 2 — right-split pane in the same workspace so both are visible at once.
# new-pane returns peer 2's surface handle directly (call it surface:B):
cmux new-pane --workspace workspace:N --type terminal --direction right
# → OK surface:B pane:P
cmux send --workspace workspace:N --surface surface:B \
  'cursor-agent --workspace /abs/project --plan --force --trust "<BRIEF 2>"'
cmux send-key --workspace workspace:N --surface surface:B enter

# Optional label (there is no per-tab rename; name the workspace):
cmux rename-workspace --workspace workspace:N -- "peers: short task"

# Read each answer — ALWAYS pass BOTH --workspace and --surface:
cmux read-screen --workspace workspace:N --surface surface:A --lines 200
cmux read-screen --workspace workspace:N --surface surface:B --scrollback --lines 2000

# Follow up in the same tab:
cmux send --workspace workspace:N --surface surface:A '<follow-up>'
cmux send-key --workspace workspace:N --surface surface:A enter
```

Rules that keep this fast and correct (installed cmux is the source of truth —
its docs and this file can lag the binary, so trust the binary):

- `new-workspace` accepts only `--cwd` and `--command`. There is **no `--name`**;
  name later with `rename-workspace --workspace X -- "name"`.
- `send`, `send-key`, and `read-screen` need **both** `--workspace` and
  `--surface`. A surface handle alone can error `"Surface is not a terminal"`.
- Prefer the **positional brief on the launch line** (`--command '<cli> … "<BRIEF>"'`).
  Fall back to `send` + `send-key enter` for the brief only when it is long or
  multi-line and awkward to shell-quote inside `--command`.
- `--command` on `new-workspace` is confirmed; on `new-pane` it is unverified, so
  peer 2 above launches via `send`. If your build accepts `new-pane … --command`,
  use it to save the two `send` calls.
- **Skip on the happy path:** `capabilities --json`, `identify --json`,
  `surface-health`, and `--help`. One `list-pane-surfaces` to grab peer 1's
  initial surface handle is fine; avoid *repeated* listing and inspection.
- If a flag is rejected, read the error's `Known flags:` line and adapt rather
  than retrying variants. `cmux trigger-flash --workspace X --surface Y` draws
  attention to a tab; `send-key … ctrl-c` interrupts. Keep tabs open by default.

## Non-blocking launch

Advisory peers must not stall on approval or trust prompts. Launch them read-only
with approvals disabled — this is **safe** because a read-only mode/sandbox lets
the peer inspect the repo and answer but cannot modify it, so auto-approve grants
nothing dangerous.

| provider | advisory: read-only + non-blocking | editing / delegate (confirm with user first) |
|---|---|---|
| Codex  | `codex --no-alt-screen -C PATH -s read-only -a never "<BRIEF>"` | `-s workspace-write -a on-failure` or `--full-auto` |
| Cursor | `cursor-agent --workspace PATH --plan --force --trust "<BRIEF>"` | `cursor-agent --workspace PATH --force --trust` (`--yolo`) |
| Claude | `claude --add-dir PATH --permission-mode plan "<BRIEF>"` | `--permission-mode dontAsk` or `--dangerously-skip-permissions` |

The levers that stop the blocking are Codex `-a never`, Cursor `--force` +
`--trust`, and Claude `--permission-mode plan`/`dontAsk`. For editing/delegate,
non-blocking means auto-approving writes — confirm with the user and prefer an
isolated worktree.

The exact JSON/text envelope returned by cmux can vary by version. Use the handles
actually returned by the installed CLI; do not invent IDs or rely on focus.

## Without cmux

cmux gives the best experience: visible tabs the user can watch, continue, and
take over, with the coordinator reading and steering each chat live. Prefer it,
and suggest installing it when it is missing.

If cmux is unavailable, run the peer non-interactively and capture stdout as the
answer:

```bash
codex exec -C /abs/project -s read-only "<BRIEF>"                 # add --json / -o FILE if useful
claude -p --permission-mode plan --add-dir /abs/project "<BRIEF>" # --output-format text|json
cursor-agent -p --mode plan "<BRIEF>"                            # runs in /abs/project (cd first) ; --output-format text|json
```

These are one-shot: there is no live chat to watch, and each follow-up is a new
invocation (continue with `--resume`/`--continue` or a saved session id). Run the
coordinator itself inside cmux to unlock the full interactive workflow above.

## Provider sessions

Prefer interactive sessions with the brief passed as the positional prompt: inside
cmux the coordinating AI reads and controls the terminal directly, so headless/
print modes (`-p`/`--print`, `codex exec`) are only for the no-cmux fallback above.

### Codex

Advisory (read-only, non-blocking, pre-briefed):

```bash
codex --no-alt-screen -C /abs/project -s read-only -a never "<BRIEF>"
```

Useful optional choices:

```bash
codex --no-alt-screen -C /abs/project -s read-only -a never -m <model> "<BRIEF>"
codex resume <session-id>
```

`-s read-only` keeps the filesystem read-only; `-a never` stops approval prompts;
`--no-alt-screen` keeps more of the conversation in cmux scrollback. Codex has no
interactive `--plan` switch, so express plan intent in the brief. For explicit
editing, escalate to `-s workspace-write -a on-failure` (or `--full-auto`).

### Claude Code

Advisory (read-only planning, non-blocking, pre-briefed):

```bash
claude --add-dir /abs/project --permission-mode plan "<BRIEF>"
```

Useful optional choices:

```bash
claude --add-dir /abs/project --permission-mode plan --model <model> "<BRIEF>"
claude --add-dir /absolute/sibling/path --permission-mode plan "<BRIEF>"
claude --resume <session-id>
```

`--permission-mode plan` reviews and plans without editing and without stalling on
prompts. For explicit editing, escalate to `--permission-mode dontAsk` or, only
when the user accepts full autonomy, `--dangerously-skip-permissions`. Avoid
`--print`, which removes the ongoing chat the user wants to watch.

### Cursor Agent

Advisory (read-only planning, non-blocking, pre-briefed):

```bash
cursor-agent --workspace /abs/project --plan --force --trust "<BRIEF>"
```

Useful optional choices:

```bash
cursor-agent --workspace /abs/project --mode ask --force --trust "<BRIEF>"
cursor-agent --workspace /abs/project --plan --force --trust --model <model> "<BRIEF>"
cursor-agent --workspace /abs/project --add-dir /absolute/sibling/path --plan --force --trust "<BRIEF>"
cursor-agent --resume <chat-id>
```

`--plan` (or `--mode ask`) stays read-only; `--force` auto-allows the peer's
read/tool calls; `--trust` skips the workspace-trust prompt. For explicit editing,
drop `--plan` and keep `--force --trust` (equivalently `--yolo`). Do not use
`--print` for the normal peer workflow.

## Prompt shape

Pass the brief as the CLI's positional prompt at launch (preferred) or send it
into the chat. Either way, adapt this shape rather than creating a brief file:

```text
You are the independent <role> for this task.

Objective: <specific question or contribution>
Project: <absolute path>
Relevant context: <paths, facts, sibling roots>
Deliverable: <what a useful answer looks like>
Constraints: <plan/read-only/editing intent, compatibility, scope>

Inspect the real project before concluding. Work independently and do not ask
another AI. Be decisive, surface uncertainty, and cite concrete evidence.
```

Do not send another peer's answer during the independent round. A later “critique
this answer” exchange is a new collaboration stage.

## Reading and continuing

The coordinating AI should interpret the chat like a human collaborator:

- If the peer is still using tools, wait and check again.
- If it asks a useful question, answer in the same tab when the available context
  is sufficient; otherwise bring the question to the user.
- If the answer is too broad, ask it to prioritize or cite evidence.
- If screen history is incomplete, ask the peer for a concise final summary in
  the same chat, then read that response.
- If authentication, quota, or model selection blocks the session, report the
  visible error instead of guessing.

There is no separate completion artifact. The peer's finished response and ready
input state are enough.

## Models and roles

Explicit user choices win. Otherwise prefer a provider whose underlying model
family complements the coordinator. Let the provider's normal default stand when
the user has not asked for a pinned comparison. Model catalogs change, so inspect
the live UI or CLI (`cursor-agent models` / `--list-models`, provider model
picker) instead of hard-coding IDs.

Good panels use complementary roles, for example an architecture critic and an
implementation planner. Several copies of the same generic prompt usually add
less value.

## Editing and worktrees

Advice and planning normally stay in the current checkout. When editing is
explicitly requested, decide whether peers should collaborate in the current
tree or use provider-native worktrees. A worktree starts from committed state and
may not include relevant dirty changes; surface that trade-off before isolation.

Use Claude's `--worktree` or Cursor's `--worktree` when appropriate. For Codex,
create or select the desired checkout before launching it. Integration remains a
separate normal Git decision, not part of peer consultation.

## Optional host rules

If the user asks for a memorable trigger, propose a small rule such as:

```text
When I say “ask peers,” use the peer-agents skill to open independent interactive
AI sessions in cmux. Keep their tabs open and synthesize their conversations here.
```

For automatic checkpoints, also specify provider/count limits and the context
that may be shared. Show an exact diff and obtain approval before changing
`CLAUDE.md`, `AGENTS.md`, or Cursor rules.
