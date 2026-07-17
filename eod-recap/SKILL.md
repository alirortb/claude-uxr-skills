---
name: eod-recap
description: Generate an end-of-day recap of action items, deliverables, and commitments from the Slack messages you SENT today. Use when user invokes "/eod-recap", asks "what did I commit to today", "recap my Slack", "what action items did I send", or at end of day. Searches Slack for your own sent messages, extracts the substantive items, and writes a dated daily log to ~/dev/eod-recaps/. Flags deliverable-worthy items and offers to draft a proper Deliverables Log entry. Daily sibling of eow-summary, which rolls these up weekly.
---

# EOD Recap

Generate a draft end-of-day recap by scanning the Slack messages **the user sent today**, extracting action items / deliverables / commitments / decisions, and writing a dated daily log. This is the daily, Slack-scoped sibling of `eow-summary` — the weekly summary can roll these daily files up rather than re-scanning everything.

## When to use

- Explicit invocation: `/eod-recap`
- User asks "what did I commit to today", "recap my Slack", "what did I tell people I'd do", "what action items did I send out"
- End of a working day, before closing out

## Scope — what this captures

**Only messages the user SENT.** This is a record of what *they* communicated and committed to — not an inbox digest.

Resolve the sender at runtime — do not hardcode an id. The `slack_search_public_and_private` tool states the current logged-in user's `user_id` in its own description (e.g. "Current logged in user's user_id is U…"); read it from there, or call `slack_search_users` with the user's own name/email. Filter every search on `from:<@THAT_ID>`.

Include public channels, private channels, DMs, and group DMs (the default channel set). The goal is a complete picture of every commitment the user made today, wherever they made it.

## Time window

**Default: today, 00:00 through now (local time).**

```
TODAY=$(date +%Y-%m-%d)
```

- If the user passes an explicit date, honor it (`on:YYYY-MM-DD`).
- If invoked late at night for "today", still use the current calendar date.
- If invoked the morning after for "yesterday", use `date -v-1d +%Y-%m-%d`.

## How to pull the messages

Use `mcp__slack__slack_search_public_and_private` with the `from:` + `on:` modifiers:

```
query: "from:<@YOUR_ID> on:YYYY-MM-DD"
sort:  "timestamp"
sort_dir: "asc"
```

- Page through results with the returned `cursor` until exhausted — do not stop at the first 20. The user may have sent many messages.
- `include_context: true` is useful: the surrounding thread tells you *what* a commitment was in response to, which sharpens the extracted item.
- If `0 results`, try a semantic phrasing or widen to `after:<yesterday>` to confirm the filter is right before reporting an empty day.

**Completeness self-check (the search under-pulls — catch it).** The `from:` sweep sometimes returns far fewer messages than were actually sent, especially **1:1 DMs**, which have silently dropped whole deliveries (a real miss: a "15/15 booked" recruitment delivery in a DM never made it into a recap that logged only 3 messages, then read as an overdue commitment a week later). Guard against it:
- After paging to exhaustion, sanity-check the count. On any normal working day a single scanned message is a red flag; **fewer than ~8 kept-or-scanned on a day the user clearly worked is "probably incomplete," not "a quiet day."** When it looks thin, re-run the sweep with a semantic phrasing and with `sort:timestamp sort_dir:asc`, and run the supplemental sweep below before concluding.
- **Supplemental targeted sweep — always run it, don't rely on the `from:` pull alone.** Recruitment/participant-ops deliveries are high-value, live in DMs and participant-coordination channels, and leave **no git footprint** (so the weekly rollup can't recover them if the daily misses them). After the primary pull, run a few extra `from:<@self> on:YYYY-MM-DD` searches seeded with fulfillment keywords to force those threads to surface:
  - `from:<@self> on:DATE (booked OR invites OR "reached out" OR reachout OR screener OR participants OR recruited OR "pulled" OR study)`
  - and a bare DM-only pass (`channel_types="im"`) with the same date, since DMs are the most-dropped surface.
  Merge and dedupe against the primary results by timestamp. If the supplemental sweep surfaces messages the primary pull missed, note in Metrics that the primary sweep under-returned (so the pattern is visible, not silently patched).

**Auth note:** Slack here is an interactively-authenticated MCP server. If a search returns an auth error, tell the user to run `/mcp` (or reconnect the Slack plugin) and retry — never embed a token.

## Extraction & classification

Read each sent message (with its thread context) and classify it. **Drop noise** — greetings, reactions, "thanks", "+1", scheduling pings, logistics with no follow-through. Keep only substantive items, each tagged:

- **`[deliverable]`** — something the user shipped, produced, or shared (a doc, prototype, PR, artifact, analysis). The thing exists or is about to.
- **`[action]`** — a to-do the user took on or said they'd do ("I'll follow up", "I'll pull the numbers", "let me draft that").
- **`[commitment]`** — a dated/scoped promise to a person or group ("PR open by June 30", "I'll have it to you Friday").
- **`[decision]`** — a call the user made or communicated that others now rely on.

For each kept item record: the tag, a one-line summary, the channel/DM it was sent in, and (if present) the named recipient and any date. Phrase summaries in the user's voice as record-keeping, not as quotes — synthesize, don't paste raw message text verbatim where avoidable.

**Never drop recruitment / participant-ops deliveries — they are no-git and un-recoverable later.** Most deliverables have a git/deliverables-folder trail the weekly rollup can lean on; recruitment and participant coordination do not. If the daily misses them, the evidence is gone. So treat these as **must-capture**, even when they arrive as a short 1:1 DM that would otherwise look like logistics:
- **Fulfillment signals = a `[deliverable]`** (the recruitment work landed): "X/Y booked", "list pulled", "invites/emails sent", "screener live", "study #NNNNN set up", "reached out to <participants>", "recruited <n>".
- **A fulfillment message that satisfies a prior promise is also a commitment-closer** — say so explicitly (e.g. "closes the Mon reachout commitment") so the weekly rollup can match it to the open commitment instead of aging it into a false "overdue." A recruitment/participant delivery leaves no artifact for the weekly reconciliation to find, so if the daily doesn't note the closure, nothing else will.
- These are almost always the Own-Research-Ops workstream — tag per `taxonomy.local.md`, don't let their brevity push them to off-plan.

### Redact performance-plan / checkpoint comms

Some sent messages carry **performance-review, checkpoint, or manager-feedback substance** (e.g. progress shared with a manager ahead of a review, self-assessment against a development plan). The fact that such a message was sent is fine to log, but its *contents* must not be written out — even in a local file.

When a kept item is performance/manager-review substance, collapse it to a single bracketed marker and drop the detail:

```
- [decision] [private — checkpoint comms] Shared a progress update with <manager> ahead of a checkpoint — #<channel>
```

Record only: that comms happened, the channel, and the recipient role. **No** workstream breakdowns, scores, manager quotes, or commitments verbatim. If unsure whether something qualifies, redact it. (Per the no-private-info rule — substance stays out of any written artifact, including local logs.)

## Categorize items (the metrics layer)

Tag each kept item with **one primary category** so the daily and weekly views can show coverage as numbers, not just a list.

Read the user's category taxonomy from `~/dev/eod-recaps/taxonomy.local.md` (a local, never-committed file). It defines the category tags, what each one counts toward, and the tagging rules — **follow that file's rules exactly**, including its guidance on which items are off-plan or excluded from coverage. Prepend the chosen tag to each item in parentheses, e.g. `- [deliverable] (<cat>) <summary> — <where>`.

- If a single item is genuinely ambiguous, tag your best guess with a trailing `?` (e.g. `(<cat>?)`) so the weekly rollup can surface it for confirmation.
- **If `taxonomy.local.md` is absent, degrade gracefully:** tag each item by its project/initiative name instead, and note in the Metrics block that workstream coverage is unavailable until the taxonomy file exists. Never invent or hardcode a category scheme in this skill.

These category tags are the only place categories live in output — this skill stays category-agnostic by design.

## Output

Write to `~/dev/eod-recaps/YYYY-MM-DD.md`.

- Create `~/dev/eod-recaps/` if it doesn't exist.
- If the file already exists for that date (re-run), append a `## Re-run at HH:MM` section rather than overwriting.
- **Always a draft.** Header says so.
- **Local-only.** This folder is never pushed to a public repo (per the no-private-info rule — it contains internal commitments and named recipients). Do not `git init` or push it anywhere public.

### File template

```markdown
# EOD Recap — <weekday> YYYY-MM-DD

_Draft generated <ISO timestamp> from Slack messages sent by the user today. Edit before relying on it._

## Action items
- [action] (<cat>) <summary> — <recipient/channel> <due date if any>

## Deliverables communicated
- [deliverable] (<cat>) <summary> — <where shared>

## Commitments made
- [commitment] (<cat>) <summary> — <to whom> · <by when>

## Decisions communicated
- [decision] (<cat>) <summary> — <channel/context>

## Metrics
- Coverage (by category): <cat>:<n> … · Off-plan:<n> · Meta(excluded):<n>
- Deliverables shipped today: <n>
- Commitments made today: <n> (with a due date: <n>)
- Messages scanned: <n> · Items kept: <n> · Channels/DMs touched: <list>
```

Omit any section with no items rather than printing an empty heading. The `## Metrics` block always renders (it's the numerical layer). Keep the daily metrics to *today's snapshot* — closure rate, aging, and shipped-vs-said are computed at the weekly rollup (`eow-summary`), which reads across the full eod-recap history.

## Feeding the Deliverables Log (flag, don't auto-write)

The Deliverables Log (`~/dev/deliverables/`) is a **polished evidence file** — every entry uses a core-five format (Problem / Solution / AI proficiency / Value / Links). Do **not** auto-append raw `[deliverable]` lines there; that pollutes the folder.

Instead, after writing the daily recap:
- **Dedup pre-check (label, don't gate).** Before listing candidates, scan the existing log — `ls ~/dev/deliverables/*.md` plus the README index — for entries on the same project, person, or artifact. Tag each candidate **"likely new"** or **"possibly overlaps `<existing-file>` — confirm distinct vs duplicate."** This is a label for a human call, *not* a filter: an item can overlap an existing entry and still be a genuinely distinct deliverable (e.g. a study *vehicle* vs. the *audience pull* that feeds it), so surface the overlap — never auto-skip it.
- If any `[deliverable]` item looks like it crossed a real ship threshold, list those as **"Deliverables-Log candidates"** in the closing summary, each carrying its dedup label.
- Offer: "Want me to draft a core-five Deliverables Log entry for any of these?" — and only write to `~/dev/deliverables/` if the user says yes, using the format in `~/dev/deliverables/README.md`.

**Keep the daily flag lightweight — the batch safety net lives elsewhere.** You don't have to push hard on every borderline item here: the **monthly promotion pass** in `/eow-summary` (first eow-summary of each month) sweeps the last ~4 weeks of recaps and re-offers any ship-threshold deliverable that never got promoted, so nothing is lost by deferring a marginal call. Surface the clear ones daily; let the monthly pass catch the rest. (Same human-confirmed T1→T2 gate either way — see `~/dev/deliverables/README.md` → "Tiers & promotion cadence".)

## After writing the file

Print to the user:
1. The output file path.
2. The Metrics snapshot: category coverage, deliverables shipped, commitments made, messages scanned · items kept · channels touched. Call out any workstream sitting at 0 — that imbalance is the signal worth seeing.
3. The list of any Deliverables-Log candidates (each tagged likely-new vs. possibly-already-logged), with the offer to draft proper entries.
4. Reminder: "Draft — edit before relying on it."

## Rules

- **Sent messages only.** `from:<@self>` on every search (resolved at runtime — see Scope). This is the user's own record, not an inbox.
- **Read-only.** Never send, edit, or react to Slack messages. Never modify the Deliverables Log without explicit confirmation.
- **Drop noise.** Greetings, thanks, +1s, pure logistics — out. Keep commitments and outputs.
- **Synthesize, don't dump.** Don't paste raw message bodies wholesale; summarize in the user's voice.
- **Local-only output.** `~/dev/eod-recaps/` stays off any public repo.
- **Draft, not final.** Header always says so.
- **One file per day.** Re-runs append a timestamped section.
- **Don't invent commitments.** If a message is ambiguous, leave it out rather than fabricate a due date or recipient.
