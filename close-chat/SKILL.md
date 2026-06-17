---
name: close-chat
description: Closeout checklist for the end of a Claude Code session — syncs project memory, deliverables log, LORE, TODOS, git state, open threads, and task list so the next session (or a future reader) picks up cleanly. Use when user invokes "/close-chat", says "wrap up", "prepare to close (the) chat", "session wrap", "before I close", "let's close out", "end of session", or after shipping a substantive deliverable. Audience is the repo owner (a Research Ops practitioner); their memory + deliverables folder + sandbox repos are the targets to keep in sync.
---

# /close-chat — Session closeout

Run a structured closeout pass at the end of a Claude Code session so the persistent record (memory, deliverables, LORE, TODOS, git, tasks) reflects what just shipped, what's parked, and what's still open. Output is a short status report the user can scan before the chat is archived.

## When to use

- Explicit invocation: `/close-chat`
- User says (in order of strength): "close chat", "let's close out", "prepare to close", "wrap up", "session wrap", "end of session", "before I close"
- After shipping a substantive artifact (PR opened, deploy landed, major doc finalized) — even without an explicit phrase, surface the closeout prompt
- Do NOT auto-run for trivial sessions (single-question chats, doc-only commits, conversational exchanges)

## The nine-item checklist

Walk through each item in order. For each: act if applicable, or explicitly say "skipped — not relevant this session." Silence on a step is not a pass.

### 1. Project memory

If the session touched a tracked project (anything in `MEMORY.md` index), update the relevant `project_*.md`:

- Current shipped state (PR links, commit SHAs, version)
- Real data points if surfaced (e.g., concrete progress numbers like "3/3/7 complete" instead of stale "8 weeks")
- Parked work (local branches, deferred follow-ups)
- Key files index for fast orientation
- Update or rename the file if the project's identity shifted (route renames, scope changes); also update `MEMORY.md` index entry

If the session started a *new* project, write a fresh `project_*.md` and add a line to `MEMORY.md`.

### 2. Deliverables log

If the session shipped a prototype or ReOps deliverable, write `~/dev/deliverables/YYYY-MM_<slug>.md` using `~/dev/deliverables/TEMPLATE.md`. The "core five":

1. **Problem** — one sentence
2. **Solution** — what was built, how it works mechanically, the stack
3. **AI proficiency demonstrated** — specifically how Claude was used (be concrete: skill invocations, math-checks, iteration patterns, review handling)
4. **Value delivered** — who benefits, what changed, quantifiable where possible
5. **Links** — code paths, PR URLs, source data, related docs

Plus optional: Risks mitigated, Future-proofing, Stakeholders.

Skip if no shipped artifact (e.g., research/discussion session, debugging only).

### 3. LORE entry

If the session represents a **substantive change-set** in a project that maintains `LORE.md` (currently: `~/dev/research-team-sandbox/`):

- Minor or major version bump (not patch)
- Multi-module change
- Long-running PR landing
- Leadership-conversation moment, pivot, or shift in direction

…add a dated entry under the current era following the LORE.md entry shape (What happened · Why it mattered · What it cost / opened · Reference). Otherwise: say "No LORE entry needed" by name.

### 4. TODOS.md

`TODOS.md` belongs to the sandbox repo (`~/dev/research-team-sandbox/`) — the `RTS-N` numbering and dated section convention only apply to sandbox-touching sessions.

**For sandbox sessions:** Capture any parked or deferred items as new `RTS-N` entries with:

- ID + priority (P2/P3 — P2 = should fix before next iteration, P3 = nice-to-have)
- Concrete file paths + line numbers if applicable
- Why it's deferred (not blocking, needs team agreement, etc.)
- Who raised it (yourself / reviewer / Copilot / etc.)

Increment from the highest existing RTS-N. Group under a dated section header `## YYYY-MM-DD — Deferred from <source> (<reviewer>)`.

**For non-sandbox sessions** (skills, standalone repos, Google Sheets work, etc.): there is no shared TODOS file. Park deferred items in the project memory's own "Outstanding" / "Open threads" / similar section — that's the right home for project-specific deferrals. Say "skipped — not a sandbox session; X deferrals captured in `project_<slug>.md`'s Outstanding section instead" and name the file.

### 5. Git state

Report state per-repo when more than one repo was touched. For each:

- Current branch and HEAD commit SHA
- Status: clean / uncommitted-changes / unpushed-commits / **no-git by design** (valid status — some repos are intentionally local-only, e.g., Miro-internal content)
- Any parked local branches (committed work not yet pushed) — with brief explanation
- Open PRs touched in this session (URL + state: open/approved/merged)

If a session touched only one repo, report flatly without per-repo headers. If multiple, use a short bulleted list per repo so the reader can scan.

Do NOT push or open PRs unless the user explicitly asks (they may want to hold).

**Backup verification (off-machine safety).** For any repo whose *only* off-machine copy is its git remote, treat **unpushed commits as unbacked** — flag them as "⚠️ unbacked: sole off-machine copy is the remote," not the neutral "unpushed-commits." Flagging is the action; pushing stays the user's call (per the rule above). Separately, if this session created or edited personal / non-repo files that live outside git and rely on a cloud backup sync, add a one-line reminder to run that sync. If the session touched neither case, stay silent on backups — don't manufacture a line.

### 6. Open threads

A short list of what's not yet resolved:

- PR reviews awaiting response
- Follow-ups deferred to next session
- External blockers (team agreement needed, awaiting reviewer, awaiting data)
- Sessions parked mid-flight

### 7. Task list cleanup

- Use `TaskList` to read current state
- Mark stragglers `completed` if they actually completed
- Delete tasks that are no longer relevant (status: `deleted`)
- Leave open only what's genuinely carrying into a future session

### 8. Plan / commitment alignment

Read the user's plan-of-record from local memory (the user maintains a private file there describing workstreams, checkpoints, and success criteria — locate it via `MEMORY.md`) and tag the session against it. The plan substance is intentionally not inlined in this file so that this SKILL.md is safe to ship in a public repo; the runtime resolves it from local memory at use-time.

- **Workstream tag** — for any deliverable/decision this session produced, name which workstream/commitment from the plan it counts toward. Primary/secondary tagging is fine when work genuinely counts toward two — name both rather than forcing a single tag.
- **Checkpoint proximity** — days remaining to each upcoming checkpoint in the plan; flag any workstream that looks thin against the plan's targets.
- **Stakeholder-comms hygiene** — if the session involved a stakeholder meeting or decision: were actions/decisions captured? Were the right people informed? Apply this especially to workstreams the plan tracks for stakeholder communication.
- **Other-workstream progress** — note progress (or explicit lack of it) for any plan element the deliverables folder doesn't capture (e.g. course chapters, framework proposals).

Skip explicitly if the session was purely tactical (debug, doc fix) with no plan relevance — but say it by name.

### 9. Next move

One concrete sentence describing the **first thing the user should do** when they pick up next session. Not a vague "continue the work" — a specific action with the names + numbers + paths already filled in.

Good examples:
- "Tomorrow morning: update the campaign batch config → export the per-segment CSVs → fire the scheduled sends → post the final daily status update."
- "Next session: rebase `feature/example-branch` onto main after PR #NN merges, then push and open the follow-up PR."
- "First move: read the reviewer's reply in the team channel before touching the refactor — they flagged a decision that affects the approach."

If there's no obvious next move (session was self-contained, no follow-up work), say "Next move: none — this session was self-contained." Honest is better than fabricated.

## Output format

A single "Closing-chat checklist" message to the user, structured as a 9-item bulleted recap. Each bullet starts with the step name + a one-line summary of what was updated (or "skipped — <reason>"). End with the **Next move** line set apart visually so it stands out as the actionable handoff into the next session.

Example shape:

```
## Closing the chat

1. **Memory** — updated `project_<slug>.md` with shipped state, real numbers, parked work.
2. **Deliverables log** — wrote `2026-MM_<slug>.md` (75 lines, template followed).
3. **LORE** — added "<entry title>" under Era N; substantive (minor bump).
4. **TODOS** — captured RTS-N + RTS-N+1 as P3 follow-ups.
5. **Git + backup** — branch `<name>` at `<sha>`, pushed to PR #N (state: <state>); off-machine backup verified (or: ⚠️ N unpushed commits unbacked / run cloud sync for <files>).
6. **Open threads** — <bullet list>
7. **Tasks** — cleaned (N completed, M deleted, K still active for follow-up).
8. **Plan alignment** — counts toward <workstream>; <X> days to <next checkpoint>; stakeholder-comms <state>.
9. **Next move** — <one concrete sentence with names, paths, numbers>

---

Ready to archive when you are.
```

If any step is skipped, say so explicitly with reason.

## For Claude.ai web (not Claude Code)

A self-contained paste block lives in `BOOTSTRAP.md` alongside this file. Use it when working outside Claude Code (claude.ai, desktop app) where the memory + filesystem aren't directly accessible — paste the block into a fresh chat as the first message, then describe the session you're closing. The block recreates the checklist's expectations without depending on local files.

## What NOT to do

- Don't open a PR, push, or merge during closeout unless explicitly asked.
- Don't write to memory or deliverables files speculatively — only update what was actually touched or shipped in this session.
- Don't fabricate "Open threads" or follow-ups that weren't real items.
- Don't add `RTS-N` entries that aren't grounded in something specific that came up (no busywork).
- Don't claim "no LORE entry needed" — say it by name with reasoning, per the LORE upkeep rule in `CLAUDE.md`.
