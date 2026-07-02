---
name: research-pack
description: Generate a UXR plan, interview guide, or insights one-pager. Complements your own transcript-analysis workflow (it does not analyze transcripts). Use when asked to "draft a research plan", "write an interview guide", "make a one-pager from these insights", or when starting/wrapping a UX study. Audience often includes non-technical researchers and designers — explain plainly.
---

# Research Pack (portable build)

Self-contained build — **no companion skills or command-line tools required**. Runs anywhere the skill is installed. Produces markdown (and, for the one-pager, a self-contained HTML page) you copy or download yourself.

UX research runs in four stages — **Plan → Conduct → Analyze → Share**. This skill owns the *documentation artifacts* for three of them:

- `plan` — **Plan** (plan + recruit)
- `guide` — **Conduct** (moderate + document)
- `one-pager` — **Share** (distill + report)

**Analyze** — deep transcript synthesis, quote extraction, theme-finding, verification — is deliberately **out of scope**. Do that in your own analysis step or tool, then bring the resulting insights back here for the one-pager. This skill never invents themes or re-extracts quotes; it offers only a lightweight confidence sanity-check (see `one-pager`).

## When to use

- "Draft a research plan for <study>"
- "Write an interview guide for <study>"
- "Make a one-pager from these insights"
- Starting a study (plan), preparing for sessions (guide), or wrapping (one-pager)

## Mode selection

If the intent is unambiguous, run the matching mode. If unclear, ask which of the three is wanted — don't guess.

## Operating principles

- **Non-intrusive.** Produce the artifact as markdown the user can copy or download. Don't assume a folder layout. If saving to files, use `<study-slug>-plan.md` / `-guide.md` / `-one-pager.md`.
- **No analysis duplication.** This skill doesn't synthesize transcripts. Bring insights you've already analyzed; the one-pager runs on those.
- **Surface your assumptions.** After generating any artifact, list every framing call made that wasn't directly stated in inputs — e.g., session length derived from participant-count math, research questions split from a single-line objective. The user owns acceptance, not the skill. Non-negotiable: a draft without flagged assumptions is incomplete.
- **Plain language.** Researchers and designers are the primary audience.
- **Drafts, not finals.** Output is a starting point. Always end with a "review and edit" prompt.

---

## Mode 1: `plan` (Plan)

Fill a standard research plan structure from a brief. Ask for what's missing rather than inventing.

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
- Tools (recruiting, recording, analysis, repository)
- Success criteria

### Output structure

```markdown
# <Project Title>

> **TL;DR** — <one line: what decision this informs>
> **Objective:** <top objective, ≤1 line> · **Method:** <e.g., 8× 1:1 interviews> · **Participants:** <n + segment> · **Timeline:** <target completion>

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
- **Script/Protocol:** see interview guide (ask for the interview guide once the plan is approved)

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

### Rules

- **TL;DR block is required, not optional.** It gives a skimming stakeholder the objective / method / n / timeline / decision in under 60 seconds without scrolling. Populate every field from the plan content below it — never leave a bracketed placeholder. It summarizes; it does not replace any section.
- **Sampling must be defensible, not convenient.** State the segmentation criteria that define the target sample — role, behavior thresholds, health/at-risk cut — not "whoever we can recruit." A reader should see *why* these participants can answer the objective.
- **Define the reporting plan before fielding, not after.** The Reporting section is not a placeholder — deliverables, audiences, and channels are decided up front, so the study is built toward a known shareout.

### Handoff footer (always append)

```markdown
---

## Next steps

1. Review this plan and get async stakeholder sign-off *before* fielding — collect comments by section, resolve them, confirm a lead has signed off.
2. When ready, ask for the interview guide.
3. When interviews are done, analyze your transcripts in your own analysis step/tool, then bring the top insights back for the one-pager. Use the context block below to brief that step.

### Context block for your analysis step

**Populate this block from the plan content above — do not leave bracketed placeholders. It should be paste-ready into your analysis step without further editing.**

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

## Mode 2: `guide` (Conduct)

Generate an interview guide from an existing plan. If no plan is provided, ask for the research questions and method directly.

### Required inputs

- The plan (or a path/paste of it), OR
- Research questions + method + session length

### Output structure

```markdown
# <Project Title> — Interview Guide

**Session length:** <e.g., 45 min>
**Method:** <e.g., remote 1:1 semi-structured>
**Recording:** <tool + consent reminder>

## 0. Intro & warm-up (5 min)
**Goal:** Build rapport, confirm consent, frame the session, set scope.

- Small talk *before* recording — where you're from, your role — to settle nerves
- Thank participant + confirm consent + recording
- Brief intro: who we are, what we're learning, no right answers
- **Scope line:** "We're here to learn about <X>; we won't go deep on <Y>." — keeps a talkative participant from consuming the session on tangents
- Warm-up (broad + safe): "Tell me about your role" / "How long have you been using <product>?"

## 1. <Section name — maps to research question 1> (~N min)
**Goal:** <one sentence on what this section unpacks>

- **Lead question:** ...
  - *Listen for: <themes, behaviors, signals to capture in real time>*
- **Probes:**
  - Why?
  - Can you walk me through the last time...?
  - *(If they mention X)* Tell me more about that — what triggered it?
  - *(If they don't)* How does X show up in your work, if at all?
- **(Segment-gated, optional):** <e.g., "For at-risk participants only: What made you start using <product> less?">

## 2. <Section name — maps to research question 2> (~N min)
**Goal:** ...

- **Lead question:** ...
  - *Listen for: ...*
- **Probes:** ...

<repeat per research question>

## N. Wrap-up (5 min)
**Goal:** Catch anything missed, close warmly, set next-step expectations.

- "Anything we didn't cover that we should have?"
- "What surprised you in this conversation?"
- Thank you + next steps + incentive logistics

---

## Post-session summary (5–10 min, immediately after)

The best time to reflect is the 5–10 minutes right after the session, while it's fresh — waiting loses the nuance. Default fields below; tune to match the study's actual research questions.

| Field | Entry |
| --- | --- |
| Overview | (2–3 sentence narrative of the session) |
| Participant + segment | name, role, company, team size; inferred new/existing |
| Classification confidence | Low / Medium / High — how sure are you of the segment? |
| Findings by research question | RQ1… RQ2… (organize by RQ, **not** chronologically) |
| Notable quotes | verbatim, attributed, chosen for evidentiary weight |
| Risk / churn signal | Low / Medium / High — gut read |
| Open threads | follow-ups, unresolved questions, product/eng routing items |

**Debrief prompts** (answer while it's fresh): What stood out? Anything unexpected? What might this mean?

---

## Moderation self-check

This guide was drafted against the [moderation rubric](#moderation-rubric) below. Before piloting, re-read each lead question and probe against the three rules:

- [ ] **Open, not closed** — no yes/no openers; questions start with who/what/when/how/why, "walk me through", "tell me about", "describe"
- [ ] **Neutral, not leading** — no "don't you think…", no embedded judgments, no validation-seeking phrasing
- [ ] **Past or present, not hypothetical** — anchored to a real event ("the last time you…") over a guess about the future ("would you…")

If any question fails a check, rewrite it using the DO patterns in the rubric below.
```

### Rules

- One section per research question; cap at 4-5 sections for a 45-min session. (Behind the guide, aim to have 5–10 prioritized key questions you must not leave without.)
- **Structure for a fluid conversation, not a rigid script.** Start broad and safe, then follow the thread of the participant's own story deeper. The section **Goal** lines keep you on track while you listen — you glance at the goal, you don't read questions verbatim.
- Lead questions must be **open** (no yes/no, no leading).
- Probes follow the "tell me about a time…" pattern over hypotheticals.
- Apply the moderation rubric below while drafting. Every lead question and probe must pass the three checks (open / neutral / past-or-present) before it lands in the output.
- Per-section **Goal** lines and ***Listen for:*** italicized cues are required, not optional.
- Use conditional probes (`*(If they mention X)* … *(If they don't)* …`) only when there's a real fork in the conversation. Don't force them in.
- **Under time pressure, protect coverage.** The section goals + timings are your coverage map — if you're running short, consciously drop lower-priority probes to preserve one lead question per research question, rather than rushing the final section.
- Tune the Post-session summary fields to the study's research questions; the default block is a starting point, not a fixed schema.

### Handoff footer (always append)

```markdown
---

## Next steps

1. Async peer review before fielding — share for comments, then pilot with one teammate to surface confusing wording. New moderators: complete moderation training first.
2. After interviews, analyze your transcripts in your own analysis step/tool.
3. When you have analyzed insights, ask for the one-pager to share findings.
```

---

## Mode 3: `one-pager` (Share)

Distill **user-provided** insights into the 3-card one-pager format. **Does not run synthesis.** If the user has raw transcripts and no insights, redirect them to synthesize first (in their own analysis step/tool) — do not attempt analysis here.

### Preflight check

Two questions before generating. Ask both; don't guess either.

**1. "What's the source of these insights?"**

- **(a) Output from your analysis step/tool** — already synthesized (and ideally cited/verified)
- **(b) Manual synthesis or notes** — accepted; the one-pager runs on what's provided
- **(c) Raw transcripts only** — **stop**. Direct the user to synthesize first, then come back with their top insights. Do not synthesize here.

**2. "Where does this one-pager need to land?"**

Ask by *outcome*, not by mechanism — the user picks by what they'll do next. Mark the recommendation inline.

- **(a) Just the markdown** *(Recommended — always works; paste it anywhere)* → produce `one-pager.md` and stop.
- **(b) A polished page to share or present** → produce the self-contained HTML one-pager; static, not editable in place.

Default to **(a)** if the user has no preference. Never silently choose a destination.

### Required inputs

- Study title
- 1-2 sentence summary (what + why the study ran)
- Author name + team
- 3-5 hashtags (study area, method, audience)
- 3 top insights, each with: short title + 3-5 sentence detail
- (Optional) Link to full report

### Output structure

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
- **Confidence gate.** Before an insight makes the top three, sanity-check its support against the rule of thumb: a point made by **1 participant is "interesting"; 3+ is a "trend."** Fewer than 3 supporting sources → label it **directional**, don't present it with false confidence. If the provided insights are all single-source, say so plainly rather than dressing them up.
- **Follow the story arc.** Order the one-pager so it reads objective → findings → implications, not a flat list. Each insight must make clear *what it means* (the implication for the product/team), not just *what was said*.
- **Trace every claim to evidence.** Each insight rests on a quote or observation from the source. Don't state a conclusion the provided insights don't support — no orphaned recommendations.
- **De-identify for broad sharing.** A one-pager is a broadly-shared artifact — use anonymized quotes and no raw PII (no last names, no un-consented recording links). Identifiable, raw session data stays with the core team; the fix for wider demand is more synthesized artifacts, not wider raw access.
- If quoting participants, preserve the source's citation format exactly, whatever it is. Do not re-extract, paraphrase, or recombine quotes from source material.

### Handoff footer (always append)

```markdown
---

## Where this came from

Insights synthesized via: <your analysis step/tool | manual synthesis>
```

---

## What this skill does NOT do

- Analyze transcripts → use your own analysis step/tool
- Extract or verify quotes, run contradiction/confidence checks → use your own analysis step/tool
- Push to any external tool (boards, repositories, etc.) → outputs are files (markdown + HTML) you place yourself
- Maintain a study folder structure → produce artifacts where the user wants them; don't impose layout
- Live moderation coaching / line-by-line critique of an existing guide → not in scope

If the user asks for any of the above, redirect to the appropriate tool rather than attempting it.

---

## Moderation rubric

Source: a UX research interview-moderation training. Used by `guide` mode while drafting questions and again at the end as a self-check appendix. Three rules + question-type cheatsheet + DO/DON'T pairs.

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

### DO / DON'T pairs

**Staying natural**

| DON'T | DO |
| --- | --- |
| "Let's start with question 1…" | "Tell me a bit about how you typically use <product>." |
| "Please list all the collaboration tools you use." | "What tools do you and your team typically use to collaborate?" |
| "Describe your perception of innovation." | "I'd love to hear how you define innovation in the context of your work." |

**Staying neutral**

| DON'T | DO |
| --- | --- |
| "Don't you think <product> is one of the best tools for this?" | "What tools come to mind when you think of this?" |
| "Did the translated content confuse you?" | "How well does the translated version work for you in your day-to-day tasks?" |
| "Do you agree that <feature> is useful for planning?" | "What features help you plan or move from ideas into action?" |

**Staying in the present or past**

| DON'T | DO |
| --- | --- |
| "Would you use <product> more if it were better translated?" | "Can you think of a time when a translation felt off or unclear?" |
| "What would you do if we added more templates?" | "How often have you looked for a template? Walk me through your process." |
| "How would you use <feature> in the future?" | "Tell me about the last time you did something like this. What made it work?" |

### How `guide` mode uses this rubric

- **While drafting:** every lead question and probe is checked against the three rules. If a draft question fails, rewrite using the DO patterns above before it lands in the output.
- **In the output:** the guide ends with a "Moderation self-check" appendix (see Mode 2 template) so the researcher can re-verify before piloting.
- **Don't restate the rubric inline in the guide output** — link back to this section via the appendix. Single source of truth.
