---
name: research-docs
description: Generate UXR plan, interview guide, or insights one-pager — complements (does not duplicate) the team's customer-insights skill for transcript analysis. Use when user invokes "/research-docs", asks "draft a research plan", "write an interview guide", "make a one-pager from these insights", or is starting/wrapping a UX study. Audience often includes non-technical researchers and designers — explain plainly.
---

# Research Docs

Generate the documentation artifacts that **bookend** a UX research study:

- `plan` — BEFORE (plan + recruit)
- `guide` — DURING (conduct + document)
- `one-pager` — AFTER (synthesize + share)

This skill deliberately **stops short of transcript analysis and synthesis** — those are owned by the team's `customer-insights` skill (`github.com/miroapp-dev/uxr-skills`). Where the workflows meet, this skill prints a handoff pointer. It never replicates analysis logic, re-extracts quotes, or restates the team's quality rules.

## When to use

- Explicit invocation: `/research-docs`
- "Draft a research plan for <study>"
- "Write an interview guide for <study>"
- "Make a one-pager from these insights"
- User is starting a study (plan), preparing for sessions (guide), or wrapping (one-pager)

## Mode selection

If the user's intent is unambiguous from the request, run the matching mode. If unclear, ask which of the three they want — don't guess.

## Operating principles

- **Non-intrusive.** Don't impose a folder structure. Write to the current working directory unless the user specifies a path. Don't read from or write to folders owned by other skills.
- **No analysis duplication.** The synthesis step is owned by `customer-insights`. This skill never extracts quotes from transcripts, never runs verification passes, never invents themes.
- **Reference, don't restate.** When the team's quality rules apply (citation format, verbatim quotes, confidence flags), point at `github.com/miroapp-dev/uxr-skills` rather than re-stating them. Single source of truth.
- **Surface your assumptions.** After generating any artifact, list every framing call made that wasn't directly stated in inputs — e.g., session length derived from a participant-count math, research questions split from a single-line objective, defaults pulled from project memory. The user owns acceptance, not the skill. This is non-negotiable: a draft without flagged assumptions is incomplete.
- **Filename convention.** If writing into a study-named folder (e.g., `~/dev/<study-slug>/`), use bare names: `plan.md`, `guide.md`, `one-pager.md`. Otherwise prefix with the study slug: `<study-slug>-plan.md`. Avoids redundant doubled slugs in the common case.
- **Plain language.** Researchers and designers are the primary audience.
- **Drafts, not finals.** Output is a starting point. Always end with a "review and edit" prompt.

---

## Mode 1: `plan` (BEFORE)

Fill the Miro Research Plan template from a brief. Ask for what's missing rather than inventing.

### Required inputs (ask if absent)

- Project title
- One-paragraph summary (what + why)
- Primary stakeholder(s)
- Top objective (what decision will this inform?)
- Method (interviews, usability test, survey, diary study, etc.)
- Rough timeline / target completion

### Optional inputs

- Background / prior research
- Specific research questions
- Target users + recruitment criteria
- Tools (Great Question, Gong, Miro, etc.)
- Success criteria

### Output structure

Write to `<study-name>-plan.md` in the current directory (or path the user specifies).

```markdown
# <Project Title>

## Overview
- **Summary:** <1-2 sentences>
- **Background:** <prior research, motivation, what's known>
- **Stakeholders:** <names + roles>

## Objectives & Research Questions
- **Objectives:** <what decisions this informs>
- **Key Research Questions:**
  1. ...
  2. ...

## Methodology
- **Research Method(s):** <e.g., 1:1 interviews>
- **Description:** <why this method fits the objectives>
- **Script/Protocol:** see interview guide (run `/research-docs guide` after plan is approved)

## Participants
- **Target Users:** <segment, role, behavior criteria>
- **Recruitment Plan:** <source, screener, incentive>
- **Demographic Information:** <if relevant>

## Logistics
- **Timeline:** <phase → date>
- **Team & Roles:** <who does what>
- **Tools:** <recruitment, recording, analysis, repository>

## Success Criteria
<what does "done" look like — answered questions, decisions enabled>

## Risks & Limitations
<sample size, recruiting risk, timeline risk, scope creep>

## Reporting
- **Deliverables:** <one-pager, full report, readout>
- **Sharing Plan:** <channels, audiences, dates>

## Appendix
<links to prior studies, related docs>
```

### Handoff footer (always append)

```markdown
---

## Next steps

1. Review and edit this plan with stakeholders.
2. When ready to draft the interview guide: run `/research-docs guide`.
3. When interviews are complete and you have transcripts: run `/customer-insights` (team skill — `github.com/miroapp-dev/uxr-skills`) for analysis. Use the context block below as input.

### Context block for `/customer-insights`

**Populate this block from the plan content above — do not leave bracketed placeholders. It must be paste-ready into `/customer-insights` without further editing.**

```
PROJECT CONTEXT
<populated from Overview → Background>

USER GOAL
<populated from Objectives>

BUSINESS GOAL
<populated from Overview → Summary, business motivation>

PRODUCT CONTEXT
<populated from Background>

PARTICIPANT OVERVIEW
<populated from Participants section>
```
```

---

## Mode 2: `guide` (DURING)

Generate an interview guide from an existing plan. If no plan is provided, ask for the research questions and method directly.

### Required inputs

- Path to the plan file, OR
- Research questions + method + session length

### Output structure

Write to `<study-name>-guide.md`.

```markdown
# <Project Title> — Interview Guide

**Session length:** <e.g., 45 min>
**Method:** <e.g., remote 1:1 semi-structured>
**Recording:** <tool + consent reminder>

## 0. Intro & warm-up (5 min)
- Thank participant + confirm consent + recording
- Brief intro: who we are, what we're learning, no right answers
- Warm-up: "Tell me about your role" / equivalent

## 1. <Section name — maps to research question 1> (~N min)
- **Lead question:** ...
- **Probes:**
  - Why?
  - Can you walk me through the last time...?
  - What was hard about that?

## 2. <Section name — maps to research question 2> (~N min)
- **Lead question:** ...
- **Probes:** ...

<repeat per research question>

## N. Wrap-up (5 min)
- "Anything we didn't cover that we should have?"
- "What surprised you in this conversation?"
- Thank you + next steps + incentive logistics

---

## Moderation self-check

This guide was drafted against the [moderation rubric](#moderation-rubric-uxr-101--june-2025) below. Before piloting, re-read each lead question and probe against the three rules:

- [ ] **Open, not closed** — no yes/no openers; questions start with who/what/when/how/why, "walk me through", "tell me about", "describe"
- [ ] **Neutral, not leading** — no "don't you think…", no embedded judgments, no validation-seeking phrasing
- [ ] **Past or present, not hypothetical** — anchored to a real event ("the last time you…") over a guess about the future ("would you…")

If any question fails a check, rewrite it using the DO patterns in the rubric below.
```

### Rules

- One section per research question; cap at 4-5 sections for a 45-min session.
- Lead questions must be **open** (no yes/no, no leading).
- Probes follow the "tell me about a time…" pattern over hypotheticals.
- Apply the moderation rubric below while drafting. Every lead question and probe must pass the three checks (open / neutral / past-or-present) before it lands in the output.

### Handoff footer (always append)

```markdown
---

## Next steps

1. Pilot this guide with one teammate before real sessions — surface confusing wording.
2. After interviews, analyze with `/customer-insights` (team skill — `github.com/miroapp-dev/uxr-skills`).
3. When you have analyzed insights, run `/research-docs one-pager` to share findings.
```

---

## Mode 3: `one-pager` (AFTER)

Distill **user-provided** insights into the 3-card one-pager format. **Does not run synthesis.** If the user has raw transcripts and no insights, redirect them to `/customer-insights` first — do not attempt analysis here.

### Preflight check

Ask: "What's the source of these insights?"

- **(a) `customer-insights` output** — recommended; team-standard, already verified and cited
- **(b) Manual synthesis or other tool** — accepted; the one-pager runs on what's provided
- **(c) Raw transcripts only** — **stop**. Direct user to run `/customer-insights` first. Do not synthesize here.

### Required inputs

- Study title
- 1-2 sentence summary (what + why the study ran)
- Author name + team
- 3-5 hashtags (study area, method, audience)
- 3 top insights, each with: short title + 3-5 sentence detail
- (Optional) Link to full report

### Output structure

Write to `<study-name>-one-pager.md`.

```markdown
# <Study Title>

<1-2 sentences on what this study is and why you ran it>

**Author:** <Name, Team>
**Tags:** #<tag1> #<tag2> #<tag3> #<tag4>

---

## 01 — <Top insight 1 title>
<3-5 sentences. Detail one singular insight. Do not bundle multiple insights.>

## 02 — <Top insight 2 title>
<3-5 sentences.>

## 03 — <Top insight 3 title>
<3-5 sentences.>

---

[Full report →](<link>)
```

### Rules

- Exactly **three** insights. If the user has more, ask them to pick the top three before generating.
- Each insight is **singular** — not a roll-up of multiple points.
- If quoting participants, preserve the source's citation format exactly. For `customer-insights` output, that means `[P02/Name ~14:30]` style — see the team skill repo for the canonical rules.
- Do not re-extract, paraphrase, or recombine quotes from source material.

### Handoff footer (always append)

```markdown
---

## Where this came from

Insights synthesized via: <(a) customer-insights | (b) manual / other tool>
Quote conventions follow: `github.com/miroapp-dev/uxr-skills` (if applicable)
```

---

## What this skill does NOT do

- Analyze transcripts → use `/customer-insights`
- Extract or verify quotes → use `/customer-insights`
- Run contradiction or confidence checks → use `/customer-insights`
- Push to Miro / Great Question / Gong → manual paste, or future MCP integration
- Maintain a study folder structure → write where the user is; don't impose layout
- Live moderation coaching / line-by-line critique of an existing guide → not in scope today. If demand emerges, split into a `/moderation-coach` skill rather than adding a fourth mode here.

If the user asks for any of the above, redirect to the appropriate skill or tool rather than attempting it.

---

## Moderation rubric (UXR 101 — June 2025)

Source: UXR 101 *How to moderate interviews* training, June 2025. Used by `guide` mode while drafting questions and again at the end as a self-check appendix. Three rules + question-type cheatsheet + canonical DO/DON'T pairs.

### The three rules

1. **Stay natural** — relaxed dialogue, like talking to a colleague over coffee. People open up when it feels casual; you get more honest stories and they forget they're being interviewed.
2. **Stay neutral** — your reactions, opinions, and phrasing can steer responses. Neutral phrasing protects the data from bias and surfaces what users actually think (not what they think you want to hear).
3. **Stay in the present or past** — past behavior is the best predictor of future behavior. People guess badly about hypothetical futures; real events surface real needs, habits, and pain points.

### Open vs. closed questions

| Open (interviews, qual) | Closed (surveys, quant) |
| --- | --- |
| who / what / when / how / why | yes/no |
| walk me through | do you / did you / does this |
| tell me about | will you / can you |
| describe / explain | |

Lead questions in an interview guide should be **open**. Closed questions are fine as targeted follow-up probes for clarification or quantification — not as section openers.

### Canonical DO / DON'T pairs

**Staying natural**

| DON'T | DO |
| --- | --- |
| "Let's start with question 1…" | "Tell me a bit about how you typically use Miro." |
| "Please list all the collaboration tools you use." | "What tools do you and your team typically use to collaborate?" |
| "Describe your perception of innovation." | "I'd love to hear how you define innovation in the context of your work." |

**Staying neutral**

| DON'T | DO |
| --- | --- |
| "Don't you think Miro is one of the best innovation tools?" | "What tools come to mind when you think of innovation?" |
| "Did the translated content confuse you?" | "How well does the translated version work for you in your day-to-day tasks?" |
| "Do you agree that Tables & Timelines are useful for planning?" | "What features help you plan or move from ideas into action?" |

**Staying in the present or past**

| DON'T | DO |
| --- | --- |
| "Would you use Miro more if the language was better translated?" | "Can you think of a time when a translation in Miro felt off or unclear?" |
| "What would you do if we added more localized templates?" | "How often have you looked for a template in your language? Walk me through your process." |
| "How would you use the Innovation Workspace in the future?" | "Tell me about the last time you did something innovative in Miro. What made it work?" |

### How `guide` mode uses this rubric

- **While drafting:** every lead question and probe is checked against the three rules. If a draft question fails, rewrite using the DO patterns above before it lands in the output.
- **In the output:** the guide ends with a "Moderation self-check" appendix (see Mode 2 template) so the researcher can re-verify before piloting.
- **Don't restate the rubric inline in the guide output** — link back to this section via the appendix. Single source of truth.
