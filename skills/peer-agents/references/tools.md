# Peer Agents Tool Reference

Use cmux as the conversation transport. The terminal chat is the source of truth;
do not create a separate runner, manifest, or result artifact.

The patterns share one vocabulary with the skill: **opinion** (same question,
independent answers, compared), **fusion** (parallel work merged with
attribution), **validate/gate** (a peer sets criteria or reviews; the author never
grades itself), plus **plan**, **review**, and **delegate**. These are starting
points, not fixed procedures.

## Minimal lifecycle

1. Check that the current process can control cmux:

   ```bash
   cmux ping
   cmux capabilities --json
   ```

   With the default `cmuxOnly` policy, these commands must run from a process
   started inside cmux.

2. Create and name the workspace in one call, in the project directory:

   ```bash
   cmux new-workspace --name "peers: short task" --cwd /absolute/project/path
   ```

   Read the returned workspace/surface handles. Use the initial terminal for the
   first peer and add a surface or split for each additional peer:

   ```bash
   cmux new-surface --type terminal --pane pane:N
   cmux new-pane --workspace workspace:N --direction right
   ```

   There is no per-tab rename command. Identify peers by naming the workspace, by
   the provider's own session title (e.g. `claude --name "peer reviewer"`), and if
   you need to draw attention to one:

   ```bash
   cmux trigger-flash --surface surface:N
   ```

3. Launch the provider interactively by sending its command, then Enter:

   ```bash
   cmux send --surface surface:N "codex --no-alt-screen -C /absolute/project/path"
   cmux send-key --surface surface:N enter
   ```

4. Read the screen until the AI UI is ready, then send the peer prompt and Enter:

   ```bash
   cmux read-screen --surface surface:N --lines 200
   cmux send --surface surface:N "<peer prompt>"
   cmux send-key --surface surface:N enter
   ```

5. Read the conversation, including scrollback when the answer is long:

   ```bash
   cmux read-screen --surface surface:N --lines 300
   cmux read-screen --surface surface:N --scrollback --lines 2000
   ```

   Use the same `send` plus `send-key enter` pair for follow-up questions (a
   trailing `\n` in the sent text also submits). Use `send-key ... ctrl-c` to
   interrupt only when needed. Keep tabs open by default.

The exact JSON/text envelope returned by cmux can vary by version. Use the handles
actually returned by the installed CLI; do not invent IDs or rely on focus.

## Provider sessions

Prefer interactive sessions. Headless/print modes are unnecessary because the
coordinating AI can read and control the terminal directly.

### Codex

Start a fresh interactive session:

```bash
codex --no-alt-screen -C /absolute/project/path
```

Useful optional choices:

```bash
codex --no-alt-screen -C /project -m <model>
codex --no-alt-screen -C /project -s read-only
codex resume <session-id>
```

Codex has no universal interactive `--plan` switch. State plan/read-only intent
in the prompt; add `-s read-only` only when stronger filesystem isolation helps.
`--no-alt-screen` keeps more of the conversation available in cmux scrollback.

### Claude Code

Start a fresh interactive session:

```bash
claude --name "peer role"
```

Useful optional choices:

```bash
claude --name "peer planner" --permission-mode plan
claude --model <model> --name "peer reviewer"
claude --add-dir /absolute/sibling/path
claude --worktree <name>
claude --resume <session-id>
```

Use plan mode when requested. For ordinary advice, a clear prompt is often
enough. Avoid `--print` because it removes the ongoing chat the user wants.

### Cursor Agent

Start a fresh interactive session:

```bash
agent --workspace /absolute/project/path
```

Useful optional choices:

```bash
agent --workspace /project --mode plan
agent --workspace /project --mode ask
agent --workspace /project --model <model>
agent --workspace /project --add-dir /absolute/sibling/path
agent --workspace /project --worktree <name>
agent --resume <chat-id>
```

Use the requested native mode. Do not use `--print` or structured output for the
normal peer workflow.

## Prompt shape

Send the brief directly into the AI chat. Adapt this shape rather than creating a
brief file:

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
the live UI or CLI (`agent models`, provider model picker) instead of hard-coding
IDs.

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
