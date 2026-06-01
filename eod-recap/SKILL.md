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

**Auth note:** Slack here is an interactively-authenticated MCP server. If a search returns an auth error, tell the user to run `/mcp` (or reconnect the Slack plugin) and retry — never embed a token.

## Extraction & classification

Read each sent message (with its thread context) and classify it. **Drop noise** — greetings, reactions, "thanks", "+1", scheduling pings, logistics with no follow-through. Keep only substantive items, each tagged:

- **`[deliverable]`** — something the user shipped, produced, or shared (a doc, prototype, PR, artifact, analysis). The thing exists or is about to.
- **`[action]`** — a to-do the user took on or said they'd do ("I'll follow up", "I'll pull the numbers", "let me draft that").
- **`[commitment]`** — a dated/scoped promise to a person or group ("PR open by June 30", "I'll have it to you Friday").
- **`[decision]`** — a call the user made or communicated that others now rely on.

For each kept item record: the tag, a one-line summary, the channel/DM it was sent in, and (if present) the named recipient and any date. Phrase summaries in the user's voice as record-keeping, not as quotes — synthesize, don't paste raw message text verbatim where avoidable.

### Redact performance-plan / checkpoint comms

Some sent messages carry **performance-review, checkpoint, or manager-feedback substance** (e.g. progress shared with a manager ahead of a review, self-assessment against a development plan). The fact that such a message was sent is fine to log, but its *contents* must not be written out — even in a local file.

When a kept item is performance/manager-review substance, collapse it to a single bracketed marker and drop the detail:

```
- [decision] [private — checkpoint comms] Shared a progress update with <manager> ahead of a checkpoint — #<channel>
```

Record only: that comms happened, the channel, and the recipient role. **No** workstream breakdowns, scores, manager quotes, or commitments verbatim. If unsure whether something qualifies, redact it. (Per the no-private-info rule — substance stays out of any written artifact, including local logs.)

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
- [action] <summary> — <recipient/channel> <due date if any>

## Deliverables communicated
- [deliverable] <summary> — <where shared>

## Commitments made
- [commitment] <summary> — <to whom> · <by when>

## Decisions communicated
- [decision] <summary> — <channel/context>

## Coverage
- Messages scanned: <n>  ·  Items kept: <n>  ·  Channels/DMs touched: <list>
```

Omit any section with no items rather than printing an empty heading.

## Feeding the Deliverables Log (flag, don't auto-write)

The Deliverables Log (`~/dev/deliverables/`) is a **polished evidence file** — every entry uses a core-five format (Problem / Solution / AI proficiency / Value / Links). Do **not** auto-append raw `[deliverable]` lines there; that pollutes the folder.

Instead, after writing the daily recap:
- If any `[deliverable]` item looks like it crossed a real ship threshold, list those as **"Deliverables-Log candidates"** in the closing summary.
- Offer: "Want me to draft a core-five Deliverables Log entry for any of these?" — and only write to `~/dev/deliverables/` if the user says yes, using the format in `~/dev/deliverables/README.md`.

## After writing the file

Print to the user:
1. The output file path.
2. The counts: messages scanned · items kept · channels touched.
3. The list of any Deliverables-Log candidates, with the offer to draft proper entries.
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
