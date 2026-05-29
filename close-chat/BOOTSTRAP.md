# BOOTSTRAP.md — Closing a Claude chat outside Claude Code

Use this paste block when you're working in **Claude.ai web** or the **desktop app**, where there's no Claude Code, no `~/.claude/skills/`, no auto-loaded memory, and no filesystem write access. It gives a fresh chat the same closeout discipline as `/close-chat` in Claude Code, without depending on any of that infrastructure.

## How to use

1. Open a fresh Claude.ai chat (or paste at the end of an existing one).
2. Paste the block below as your message.
3. Fill in the placeholders at the bottom describing what the session covered.
4. Claude will produce a closing-chat checklist + drafts for whichever artifacts apply, which you copy back into your local memory / deliverables / TODOS / Git workflow yourself.

The block is self-contained — no links to external files, no assumed memory state.

---

## Paste block (everything below this line)

I'm closing out a working session with Anthony Li (Research Operations at Miro). He keeps a structured **closeout discipline** that normally runs inside Claude Code via the `/close-chat` skill, but we're in a chat that doesn't have access to his filesystem or memory. Your job is to produce the same closeout drafts so he can paste them into his local system himself.

**Audience + system context** (so the drafts use the right shape):

- Anthony's memory lives at `~/.claude/projects/-Users-anthonyli/memory/` (typed `project_*.md`, `feedback_*.md`, `reference_*.md` files indexed by `MEMORY.md`).
- His deliverables log lives at `~/dev/deliverables/` — every shipped prototype gets a `YYYY-MM_<slug>.md` entry using the **core-five** format: Problem · Solution · AI proficiency demonstrated · Value delivered · Links. Plus optional Risks · Future-proofing · Stakeholders.
- His main sandbox repo is `~/dev/research-team-sandbox/` which maintains `CHANGELOG.md`, `LORE.md` (a chronicle of *why we are here*), `VERSION` (semver, bump per PR), `TODOS.md` (RTS-N P2/P3 entries with file paths), and branch-name convention `<yourname>/<what-you-are-building>`.
- He prefers honest representations over flattering ones (e.g., showing real streak math with gaps, not collapsed counts).

**Plan / commitment context (paste-in if relevant):** If this session's work counts toward a personal plan with workstreams, checkpoints, or success criteria, paste that context inline in the "session covered" block at the bottom of this message — Claude won't have it otherwise, and step 8 below depends on it. If no such plan context applies, skip the paste and step 8 will say "no plan relevance." (This block intentionally stays generic so the paste-block file is safe to keep in a public repo.)

**The nine-item closeout checklist** — for each item, either produce the draft text or explicitly say "skipped — <reason>". Silence is not a pass.

1. **Project memory** — if a tracked project was touched, draft an update to its `project_*.md` reflecting current shipped state, real data points, parked work, and a key-files index. If a new project, draft a fresh memory file with a `MEMORY.md` index line.
2. **Deliverables log** — if a prototype/ReOps deliverable shipped, draft `YYYY-MM_<slug>.md` using the core-five format. AI-proficiency section should name specific Claude moves (skill invocations, math-checks, iteration patterns) — be concrete, not generic.
3. **LORE entry** — only if substantive (minor+ version bump, multi-module change, pivot moment). Use the format: dated header → **What happened** (specific dates/people/decisions) → **Why it mattered** (what changed about scope/audience/urgency) → **What it cost / opened** (tradeoffs honestly) → **Reference** (PRs, docs, threads). Otherwise: explicit "No LORE entry needed."
4. **TODOS.md** — `TODOS.md` is sandbox-specific (`~/dev/research-team-sandbox/`). For sandbox sessions: capture parked items as new `RTS-N` entries (P2/P3) with file paths + reasoning + who raised it, under a dated section header. For non-sandbox sessions (skills, standalone repos, Sheets work, etc.): park items in the project memory's own "Outstanding" / "Open threads" section instead and say "skipped — not a sandbox session" naming the file used.
5. **Git state** — report state per-repo when multiple were touched. For each: current branch + HEAD SHA, status (clean / uncommitted-changes / unpushed-commits / **no-git by design** is a valid status for intentionally local-only repos), parked branches, open PRs. Don't take actions; just enumerate what needs to happen locally.
6. **Open threads** — short list of unresolved items (PR reviews awaiting response, deferred follow-ups, external blockers).
7. **Task list** — note which items finished, which remain.
8. **Plan / commitment alignment** — if plan context was pasted in the session-covered block: for each deliverable/decision this session produced, tag which workstream/commitment it counts toward (primary/secondary tagging is fine when work counts toward two). Note days remaining to the next checkpoint(s) the user named, and flag any commitment that looks thin against the user's stated criteria. If a stakeholder meeting occurred: note whether actions/decisions were captured + the right people informed. If a chapter/course/training commitment is in scope: log progress (or explicit lack of it). If no plan context was pasted: say "skipped — no plan context provided" by name.
9. **Next move** — one concrete sentence describing the first thing Anthony should do when he picks up next session. Specific names, paths, numbers — not vague "continue the work." If no obvious next move, say so honestly: "Next move: none — this session was self-contained."

**Output format**: a single message structured as a 9-item bulleted recap (one line each, "step name — what was updated or skipped"), followed by the actual draft text for items that produced artifacts, each clearly headed so Anthony can copy each block straight into the right local file. End with the **Next move** line set apart visually so it stands out as the handoff into the next session.

**What NOT to do**:

- Don't write generic-AI-helper boilerplate ("I'd be happy to help!" etc.).
- Don't pretend to have access to his memory or files — describe what *he* should write.
- Don't fabricate open threads or RTS items that weren't real.
- Don't open a PR or push code in a draft — describe the git actions, leave them to him.

**This session covered:**

```
What was worked on: <ONE-LINE DESCRIPTION>
What shipped (if anything): <PR # / deploy / file URL — or "nothing shipped, just discussion">
Key decisions or pivots: <ANY DECISIONS WORTH CHRONICLING>
Real data points surfaced: <NUMBERS / NAMES / FACTS THAT CORRECT EARLIER ASSUMPTIONS>
Parked / deferred items: <ANYTHING POSTPONED OR LEFT OPEN>
Stakeholders / reviewers involved: <NAMES>
Plan / commitment context (if any): <paste workstreams, checkpoints, success criteria, OR write "none">
Which workstream(s) / commitments this session counts toward: <name them from the pasted plan, or "none">
```
