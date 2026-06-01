---
name: eow-summary
description: Generate end-of-week summary by scanning Claude Code transcripts, ~/dev/* git activity, ~/dev/deliverables/ entries, and project memory across the current week's weekdays. Use when user invokes "/eow-summary", asks "what did I ship this week", "draft my weekly digest", "summarize this week's work", or when the Friday cron triggers it. Produces a single draft markdown file with three layered sections — personal log, team digest, AI Design Guild candidates — for the user to edit before sharing.
---

# EOW Summary

Generate a draft end-of-week summary by scanning four sources across the current week's weekdays. Output is one markdown file with three layered sections (personal log, team digest, Guild candidates) that the user reviews and edits before sharing.

## When to use

- Explicit invocation: `/eow-summary`
- User asks "what did I ship this week", "draft my weekly digest", "summarize this week's work"
- Friday-morning cron trigger
- User passes a custom range — honor it, but still drop Sat/Sun activity

## Time window

**Default: Monday 00:00 through Friday 23:59 of the current week, weekdays only.**

- If invoked Mon-Fri: window is this week's Monday through invocation time.
- If invoked Sat/Sun: window is the just-completed Mon-Fri.
- If user passes an explicit range: honor it but exclude Sat/Sun activity within the range.

Compute the Monday boundary on macOS zsh:
```
START=$(date -v-Mon +%Y-%m-%d)        # if today is Mon-Fri, the most recent Monday
END=$(date -v+Fri +%Y-%m-%d)          # this Friday
```
If today is Sat/Sun, adjust to the prior Mon-Fri.

Use ISO timestamps (`YYYY-MM-DD`) when passing to `git log --since`/`--until` and `find -newermt`.

## Sources to scan

Run these in parallel where independent.

### 1. Git activity in ~/dev/* (ground truth for shipped work)

For each git repo under `~/dev/*/`:
```
for d in ~/dev/*/; do
  [ -d "$d/.git" ] || continue
  git -C "$d" log --since="$START" --until="$END 23:59" \
    --pretty=format:'%h|%ad|%s' --date=short --no-merges --all
done
```
Drop any line whose date falls on Sat/Sun. Group by repo. Note branches active in the window via `git -C "$d" for-each-ref --sort=-committerdate refs/heads/`.

### 2. ~/dev/deliverables/ entries (polish signal)

```
find ~/dev/deliverables -name '*.md' -newermt "$START" ! -newermt "$END 23:59"
```
Anything new or modified here is a Guild-candidate by definition. Read each to extract the deliverable name and core five (Problem / Solution / AI proficiency / Value / Links).

### 3. Project memory

```
find ~/.claude/projects/-Users-anthonyli/memory -name 'project_*.md' \
  -newermt "$START" ! -newermt "$END 23:59"
```
Read each modified file. Surface status changes, decisions, new initiatives. Skip files that only had cosmetic edits.

### 4. Claude Code transcripts (last-resort context)

```
find ~/.claude/projects -maxdepth 2 -name '*.jsonl' \
  -newermt "$START" ! -newermt "$END 23:59"
```
Group by project subdirectory. Use sparingly — surface blockers, exploratory threads, and work that left no git/deliverables/memory trace. **Never paste raw transcript content.** Synthesize.

### 5. EOD recaps — Slack-communicated commitments (`~/dev/eod-recaps/`)

The companion `eod-recap` skill writes one dated file per day (`YYYY-MM-DD.md`) holding the action items, deliverables, commitments, and decisions the user **communicated in Slack** that day — already classified and noise-filtered. This is the only source that captures what the user *told people they'd do*; git, deliverables, and memory don't see Slack.

Filenames are ISO dates, so a lexical range over the window selects the right files:
```
for f in ~/dev/eod-recaps/*.md; do
  d=$(basename "$f" .md)
  [[ "$d" > "$START" || "$d" == "$START" ]] && [[ "$d" < "$END" || "$d" == "$END" ]] && echo "$f"
done
```
Drop any whose date is Sat/Sun. Pull the already-tagged items straight through — **don't re-derive them**. Feed `[commitment]` and still-open `[action]` items into the personal log and the team digest's commitments line; cross-check `[deliverable]` items against git + the deliverables folder before claiming something shipped.

- **Carry redaction forward verbatim.** Items already marked `[private — checkpoint comms]` stay collapsed — never expand them, even though the EOW output is also a draft.
- **Flag gaps.** If a weekday in the window has no eod-recap file, note it (e.g. "_No eod-recap for Tue 06-03 — Slack-communicated items not captured that day._") so the user knows the Slack layer is partial, not that nothing was said.

## Classification rubric

For each project cluster, classify the week's work:

- **Shipped** — merged commits + matching deliverables entry, OR clear "done" status in memory
- **In-progress** — commits but no deliverables entry yet, or memory marks it active
- **Blocked** — transcript, memory, or an eod-recap mentions an unresolved blocker
- **Exploratory** — Claude Code activity but no commits, deliverables, or memory updates
- **Committed** — an eod-recap holds an open `[commitment]`/`[action]` with no matching shipped artifact yet (something promised in Slack, still outstanding)

Source weighting when signals conflict: for **shipped work**, **git > deliverables > memory > transcripts**. For **what was communicated or committed**, the eod-recaps are authoritative — git/deliverables/memory can't see Slack, so don't down-rank a recap'd commitment just because there's no commit behind it yet.

## Output

Write to `~/dev/eow-summaries/YYYY-MM-DD.md` where `YYYY-MM-DD` is the Friday of the week being summarized.

- If `~/dev/eow-summaries/` doesn't exist, create it.
- If the file already exists for that date, append a `## Re-run at HH:MM` section rather than overwriting.
- **Always a draft.** Header must say so explicitly.

### File template

```markdown
# EOW Summary — <Mon date> through <Fri date> YYYY

_Draft generated <ISO timestamp>. Edit before sharing._

## 1. Personal log

Everything touched this week, by project. One bullet per project; sub-bullets for commits, decisions, blockers, dead-ends. This section is for your records — keep it complete.

- **<Project>** — <classification>
  - Commits: <hash short subjects>
  - Decisions: <one-liners>
  - Commitments: <open [commitment]/[action] items from eod-recaps — who it's to + by when>
  - Blockers: <if any>

## 2. Team digest

Scannable view for the immediate team. Skip exploratory work here.

**Shipped this week**
- <project> — <one-line outcome + link to deliverable or PR>

**Decisions**
- <one-line decision + rationale>

**Commitments outstanding** _(from eod-recaps — what I told people I'd do, not yet shipped)_
- <commitment> — to <whom> · <by when>

**Blocked / needs input**
- <project> — <what's blocking + what unblocks it>

## 3. Guild candidates

Anything that crossed a ship threshold this week — present in `~/dev/deliverables/` or marked shipped in memory — AND fits the AI Design Guild automation frame.

**Exclude Claude Code skills by default.** The Guild's canonical examples (UXR Budget Bot, UXR Tech Pulse, ReOps UXR Standup) are orchestration automations, not workflow tooling. A Claude Code skill qualifies only if it orchestrates external systems beyond Claude Code itself (e.g. wraps a Slack/Snowflake/Miro API call as part of its execution). Pure dev-workflow skills (audit, summary, doc-drafting) are logged in the personal log + team digest but not in this section. When excluded, add a one-line note at the top of the Guild section explaining why so the user can override on review.

Pre-format each candidate in Anthony's Format A bullet style (per `reference_ai_design_guild_summaries.md`):

- **<Automation name>**
  - Tools: <comma-separated stack>
  - Pathway: <trigger> → <step> → <step> → <output>
  - AI role: <what the LLM specifically does — or "None — pure workflow orchestration">
  - Replicability: <one sentence on what other use cases this pattern fits>
  - Metric: <concrete number with math shown>
  - Gain: <one sentence on the win>

If nothing crossed the threshold this week, write: _No Guild candidates this week._

## 4. Metrics

The numerical layer — for the user's own reference and performance audits. Computed from the eod-recap items' category tags + git/deliverables. See "Computing the metrics rollup" below.

**Coverage this week** _(items per category; a workstream at 0 is the signal)_
- <cat>: <n>  ·  <cat>: <n>  ·  … · Off-plan: <n>   _(Meta/checkpoint-comms excluded)_

**Deliverables** — shipped this week: <n>  ·  vs prior week: <n> (<Δ>)

**Commitments** — made this week: <n>  ·  shipped/closed: <n>  ·  **closure rate: <x>%**

**Open commitments** _(all-time, scanned across eod history)_ — <n> open, <n> overdue
- <commitment> · made <date> · age <d>d · <OVERDUE if past due> · to <whom>

**Shipped-vs-said** — <deliverables with a real git/deliverables artifact> / <total deliverable claims> = <x>%

_If `~/dev/eod-recaps/taxonomy.local.md` is absent or no eod-recap files fell in the window, note that and emit only the metrics derivable from git/deliverables._
```

## Computing the metrics rollup

- **Coverage** — tally the category tags on items in this week's eod-recap files. Carry the tags straight from the files; don't re-categorize. Exclude `Meta`/`[private — checkpoint comms]` items. Surface any category at 0.
- **Closure rate** — of `[commitment]` items logged *this week*, how many have a matching shipped artifact (a commit/PR in git or a deliverables entry) — best-effort match on project/topic. Ambiguous matches count as open, labeled "(unverified)".
- **Open commitments + aging** — scan **all** `~/dev/eod-recaps/YYYY-MM-DD.md` files (the daily files are the persistence — no separate ledger). For each `[commitment]` with no matching shipped artifact: age = window-end date − the date it was first logged; overdue = a stated due date now past. Only files named as ISO dates — skip `taxonomy.local.md` and anything else.
- **Shipped-vs-said** — `[deliverable]` items with a real artifact behind them (git/deliverables) ÷ all `[deliverable]` items this week.
- **Throughput** — deliverables shipped this week vs. the prior week's eow-summary metrics block (if present).

These are activity/coverage/follow-through signals, **not impact**. Git + the Deliverables Log remain the outcome evidence; the metrics complement them. Never present a raw count as if it were performance.

## Regenerate the living dashboard (multi-source HTML)

After the weekly markdown is written, refresh the **living operating dashboard** — a single, stable, overwritten HTML file that always reflects the latest cumulative picture, so it can be printed at any checkpoint without a one-off build.

- Path: `~/dev/eow-summaries/<dashboard>.html` (a fixed filename — overwrite it each run; it is NOT dated). **If the file already exists, reuse its CSS + component structure as the template** (refresh only the numbers/bars) so styling stays consistent and correct — don't re-derive the layout. If creating it fresh, match the deliverables share-HTML one-pagers (inline CSS, no JS, print-friendly). Note: bar fills must be `display:block` (a `<span>` fill inside a grid-item track is inline and renders nothing otherwise).
- **Multi-source, not Slack-only.** Compute its numbers from the reconciled rollup across the full eod-recap history *plus* git and the deliverables log to date — not just this week, not just Slack.
- **Two lenses, side by side: "Communicated" (from eod-recaps) and "Shipped" (git commits/PRs + deliverables entries).** Present them separately and surface the delta — don't merge fuzzy tags into one count. The gap between communicated and shipped is itself a finding.
- Include: category coverage (from the taxonomy tags), commitment closure (closed / open / overdue), and the weekly activity trend.
- **Local-only.** This file carries category/taxonomy substance; never push it to a public repo or `git init` the folder.
- Carry redaction forward — never expand `[private — checkpoint comms]` items into the dashboard.
- **Preserve human-curated sections verbatim.** If the dashboard has a manually-curated section (e.g. a "Collaboration & peer signal" section quoting other people), carry it through **unchanged** — never auto-generate, rewrite, or drop peer quotes. Attribution of others' words stays human-curated; the auto-run only refreshes the computed metrics (coverage, closure, trend), not the curated signal.

## After writing the file

1. Print to the user:
   - The output file path + that the living dashboard HTML was refreshed
   - A 3-line summary: # projects touched, # shipped, # Guild candidates
   - The metrics headline: coverage by category (flag any at 0), closure rate, open/overdue commitments
   - Reminder: "Draft — edit before sharing."

2. **Self-schedule next week's run** (works around the 7-day cron auto-expiration):
   - Use `CronCreate` with `recurring: false`, `durable: true`, prompt `"Friday EOW summary — invoke the eow-summary skill."`, and a cron expression pinned to next Friday at 8:57am local (e.g. `"57 8 <next-fri-dom> <next-fri-month> *"`).
   - Compute next Friday's date with `date -v+Fri -v+1w +'%d %m'` (zsh on macOS) and substitute the day-of-month and month.
   - Tell the user when the next run is scheduled.

## Rules

- **Draft, not final.** Header always says "Draft generated — edit before sharing."
- **No invented metrics.** Pull from project memory and deliverables entries. If a metric isn't recorded, write `Metric: TBD — pull from <source>`.
- **Category-agnostic skill.** Read categories from the user's local `~/dev/eod-recaps/taxonomy.local.md`; never hardcode a category scheme here. The metrics layer is coverage/follow-through, not impact — don't present a raw count as performance.
- **Honest about AI role.** When an automation is pure orchestration, say so (Format A house rule).
- **Weekday-only.** Drop Sat/Sun activity even if a calendar-week range is passed.
- **Source weighting.** Git is ground truth for what shipped; transcripts are last-resort context.
- **Don't paste raw transcript content** — synthesize, don't quote.
- **Read-only on sources.** Never modify git repos, deliverables files, or memory files.
- **One file per Friday.** Re-runs append, not overwrite.
- **Self-perpetuate the cron.** Always schedule next Friday before exiting.
