---
name: prototype-audit
description: Pre-flight safety check for prototype repos against the design-team prototype playbook. Use when the user invokes "/prototype-audit", asks "is this safe to push/PR", "am I ready to share my work", "what state is my branch in", or before suggesting any risky git operation (push, merge, force-push) in a prototype repo. Audience is often non-technical product designers, so explain findings plainly.
---

# Prototype Audit

Run a read-only safety check on the current git repo against the design-team prototype playbook. Designed for product designers and other non-technical users — surface state plainly, never auto-fix.

## When to use

- Explicit invocation: `/prototype-audit`
- User asks "is this branch ready to push", "am I safe to PR", "what state is my work in"
- Before suggesting any risky git operation in a prototype repo (push, merge, force-push) — run this first

## What to check

Run these checks via Bash from the current working directory. Where independent, run in parallel.

### 1. Is this a git repo?
```
git rev-parse --is-inside-work-tree
```
If not "true", abort: "Not a git repo — the prototype playbook applies only to GitHub-backed work."

### 2. Detect default branch
```
git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's|^origin/||'
```
Fall back to `main` if the symbolic-ref isn't set.

### 3. Current branch
First check for detached HEAD:
```
git symbolic-ref -q HEAD
```
If exit code is non-zero, HEAD is detached (mid-rebase, mid-bisect, or a commit checked out directly). Flag **[WARN]**: "Detached HEAD — you're not on a branch. This usually means a rebase, bisect, or checkout of a specific commit is in progress. Resolve before pushing." Skip the default-branch comparison below.

Otherwise:
```
git rev-parse --abbrev-ref HEAD
```
If current branch == default branch, flag **[FAIL]**: "You're on the default branch. Per the playbook: never work directly on main. Create a feature branch first."

### 4. Sync vs. remote
First check that `origin` exists:
```
git remote get-url origin 2>/dev/null
```
If exit code is non-zero, flag **[WARN]**: "No `origin` remote — the playbook applies to GitHub-backed work. Add a remote before pushing or sharing." Skip the rest of this section.

Otherwise attempt to fetch:
```
git fetch origin --quiet
```
If the fetch fails (non-zero exit — network down, VPN required, auth missing), flag **[WARN]**: "Couldn't reach `origin` — sync state unknown. Check your network/VPN or auth, then re-run." Skip the rev-list comparison.

Otherwise:
```
git rev-list --left-right --count origin/<default>...HEAD
```
Output is `<behind> <ahead>`. Interpret:
- behind > 0 → **[WARN]**: "Your branch is N commits behind <default>. Per the playbook: stay current — merge latest <default> into your branch."
- ahead > 0 with no remote tracking branch → **[INFO]**: "N unpushed commits."
- both 0 → **[OK]**: "Up to date with origin/<default>."

### 5. Working tree state
```
git status --porcelain
```
- Empty output → **[OK]** "Working tree clean."
- Any output → **[WARN]** "Uncommitted changes in N files. Commit before pushing or sharing."

### 6. Merge conflicts
```
git diff --name-only --diff-filter=U
```
- Empty → **[OK]** "No unresolved conflicts."
- Any output → **[FAIL]** "Unresolved merge conflicts in N files. Per the playbook: don't resolve blindly — pair with someone or ask an admin."

### 7. CLAUDE.md guardrail coverage
- Check for `CLAUDE.md` at repo root.
- If absent → **[INFO]** "No CLAUDE.md at repo root. Consider adding one (template available in the team's internal prototype-playbook repo)."
- If present, **read the file** and judge each of the four playbook guardrails into one of three states:
  - **documented** — CLAUDE.md states the rule in a way that agrees with the playbook (e.g., "never force-push", "main is protected, work on a branch", "do not self-merge — wait for review", "do not blindly resolve conflicts — surface them").
  - **contradicted** — CLAUDE.md states something that points the opposite way from the playbook (e.g., instructs auto-resolving conflicts, allows force-push, allows self-merge, allows direct commits to main).
  - **not found** — neither documented nor contradicted; the rule is silent.

  The four guardrails to check:
  - **force-push** — playbook says never force-push.
  - **self-merge** — playbook says never merge your own PR.
  - **merge conflicts** — playbook says never blindly resolve; surface them and pair.
  - **main protection** — playbook says never work directly on `main`.

- Do not rely on keyword grep alone — keywords like "conflict" appear in unrelated contexts ("if your instinct conflicts with a guideline") and presence of a keyword does not mean the rule is documented in the playbook's direction. Read the surrounding sentence/paragraph and make the judgment.
- Report:
  - If any guardrail is **contradicted** → flag the overall CLAUDE.md line as **[WARN]** and list each guardrail's state.
  - Else if any is **not found** → **[INFO]** and list states.
  - Else (all documented) → **[OK]**.
  - Format: `CLAUDE.md: documented: <list>. Contradicted: <list>. Missing: <list>.` (omit sections with no entries).

### 8. Last commit recency (informational)
```
git log -1 --format='%ar by %an'
```
Always **[INFO]**. Use to spot stale branches.

## Output format

A compact, copy-pasteable report. No emojis. Use bracketed status markers.

```
Prototype audit — <repo-name> (<current-branch>)

[OK]   Branch: feature/foo (not default)
[OK]   Sync: up to date with origin/main
[WARN] Working tree: 3 uncommitted files
[OK]   Conflicts: none
[INFO] CLAUDE.md: documented: force-push. Missing: self-merge, main protection, conflicts.
[INFO] Last commit: 2 hours ago by Anthony Li

Summary: Branch is clean to push once you commit your local changes.
Next step: "Commit my changes with message: <describe what you did>", then "Push my branch to GitHub".
```

Status keys:
- `[OK]` — passes the check
- `[WARN]` — non-blocking, user should know and decide
- `[FAIL]` — blocking; do not proceed with risky git ops until resolved
- `[INFO]` — informational, no judgment

## Rules

- **Read-only.** Never run destructive commands as part of the audit (no checkouts, resets, force-pushes, stashes, branch deletes).
- **Never modify the working tree.**
- **Never auto-fix.** Surface findings. The user decides.
- **`git fetch` is allowed** — it only updates remote-tracking refs and does not touch local branches.
- **Plain language for designers.** When flagging WARN/FAIL, explain why it matters in one sentence (cite the playbook rule).
- **If a `[FAIL]` is present**, stop after reporting. Do not proceed with the user's original request (e.g., a push) until the FAIL is resolved.

## Recommended-next-step phrasing

Map the report's worst status to a suggested next step using the playbook's command phrasings:

| Worst finding | Recommended next step |
|---|---|
| `[FAIL]` on default branch | "Create a new branch called `<branch-name>` and move my changes onto it." |
| `[FAIL]` on conflicts | "Stop — pair with an admin to resolve the conflicts." |
| `[WARN]` behind default | "Merge latest main into my branch." |
| `[WARN]` uncommitted changes | "Commit my changes with message: [describe what you did]". |
| All `[OK]` | "Push my branch to GitHub" (and then open a PR, but don't self-merge). |
