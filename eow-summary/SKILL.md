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

## Classification rubric

For each project cluster, classify the week's work:

- **Shipped** — merged commits + matching deliverables entry, OR clear "done" status in memory
- **In-progress** — commits but no deliverables entry yet, or memory marks it active
- **Blocked** — transcript or memory mentions an unresolved blocker
- **Exploratory** — Claude Code activity but no commits, deliverables, or memory updates

Source weighting when signals conflict: **git > deliverables > memory > transcripts**.

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
  - Blockers: <if any>

## 2. Team digest

Scannable view for the immediate team. Skip exploratory work here.

**Shipped this week**
- <project> — <one-line outcome + link to deliverable or PR>

**Decisions**
- <one-line decision + rationale>

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
```

## After writing the file

1. Print to the user:
   - The output file path
   - A 3-line summary: # projects touched, # shipped, # Guild candidates
   - Reminder: "Draft — edit before sharing."

2. **Self-schedule next week's run** (works around the 7-day cron auto-expiration):
   - Use `CronCreate` with `recurring: false`, `durable: true`, prompt `"Friday EOW summary — invoke the eow-summary skill."`, and a cron expression pinned to next Friday at 8:57am local (e.g. `"57 8 <next-fri-dom> <next-fri-month> *"`).
   - Compute next Friday's date with `date -v+Fri -v+1w +'%d %m'` (zsh on macOS) and substitute the day-of-month and month.
   - Tell the user when the next run is scheduled.

## Rules

- **Draft, not final.** Header always says "Draft generated — edit before sharing."
- **No invented metrics.** Pull from project memory and deliverables entries. If a metric isn't recorded, write `Metric: TBD — pull from <source>`.
- **Honest about AI role.** When an automation is pure orchestration, say so (Format A house rule).
- **Weekday-only.** Drop Sat/Sun activity even if a calendar-week range is passed.
- **Source weighting.** Git is ground truth for what shipped; transcripts are last-resort context.
- **Don't paste raw transcript content** — synthesize, don't quote.
- **Read-only on sources.** Never modify git repos, deliverables files, or memory files.
- **One file per Friday.** Re-runs append, not overwrite.
- **Self-perpetuate the cron.** Always schedule next Friday before exiting.
