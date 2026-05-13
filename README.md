# claude-uxr-skills

Personal [Claude Code](https://claude.com/claude-code) skills for UXR/ReOps work at Miro.

## Positioning

This repo is **personal R&D space** for skills I use day-to-day. It **complements** team-distributed skill collections like [`miroapp-dev/uxr-skills`](https://github.com/miroapp-dev/uxr-skills) (Michael Schade's `customer-insights` and related) — it is **not a fork, alternative, or competitor**. Where workflows overlap, my skills hand off to the team skills via informational pointers rather than duplicating their logic. Skills here may be PR'd upstream once they've earned the keep across multiple real uses.

## Skills

- **[`research-docs`](./research-docs/)** — Generate UXR plan, interview guide, or insights one-pager. Bookends `customer-insights` (BEFORE + AFTER stages); never replicates transcript analysis or synthesis.
- **[`prototype-audit`](./prototype-audit/)** — Read-only safety check for prototype repos against the [design-team prototype playbook](https://github.com/miroapp-dev/prototype-playbook). Surfaces state plainly for non-technical users; never auto-fixes.
- **[`eow-summary`](./eow-summary/)** — Generate an end-of-week summary by scanning Claude Code transcripts, `~/dev/*` git activity, `~/dev/deliverables/` entries, and project memory. Produces a layered draft (personal log, team digest, AI Design Guild candidates) for editing before sharing.

## What `/prototype-audit` looks like

Run `/prototype-audit` in any prototype repo and get a plain-English report — no code knowledge required to act on it.

**A repo that needs attention** (real run against an internal prototype):

```
Prototype audit — RKO-prototype (main)

[FAIL] Branch: you're on the default branch (main). Per the playbook: never work directly on main — create a feature branch first.
[OK]   Sync: up to date with origin/main (0 behind, 0 ahead)
[OK]   Working tree: clean
[OK]   Conflicts: none
[WARN] CLAUDE.md: documented: main protection. Contradicted: merge conflicts (line 21 tells the agent to auto-resolve conflicts during rebase — the playbook says to surface conflicts and pair, never resolve blindly). Missing: force-push, self-merge.
[INFO] Last commit: 6 weeks ago by Mark Boyes-Smith

Summary: Blocking issue — you're on `main`. Tree is clean (no work to rescue), so the immediate fix is simply to spin up a feature branch before doing anything. Separately, CLAUDE.md contains a line that points the opposite way from the playbook on conflict handling — worth fixing on a future branch.

Next step: "Create a new branch called `<branch-name>` so I can start working safely."
```

**A clean repo, safe to push**:

```
Prototype audit — my-prototype (feature/onboarding-redesign)

[OK]   Branch: feature/onboarding-redesign (not default)
[OK]   Sync: up to date with origin/main (0 behind, 3 ahead)
[OK]   Working tree: clean
[OK]   Conflicts: none
[OK]   CLAUDE.md: documented: force-push, self-merge, main protection, conflicts.
[INFO] Last commit: 12 minutes ago by Anthony Li

Summary: All clear — safe to push and open a PR.

Next step: "Push my branch to GitHub" (then open a PR, but don't self-merge).
```

Severity markers: `[OK]` passes, `[WARN]` know-and-decide, `[FAIL]` blocking, `[INFO]` informational.

## Try `/prototype-audit` in 5 minutes

Got [Claude Code](https://claude.com/claude-code) installed? Run these in your terminal:

```
git clone https://github.com/alirortb/claude-uxr-skills.git ~/dev/claude-uxr-skills
mkdir -p ~/.claude/skills
ln -s ~/dev/claude-uxr-skills/prototype-audit ~/.claude/skills/prototype-audit
```

Then `cd` into any git repo and start Claude Code:

```
cd ~/path/to/your-repo && claude
```

Once it loads, type `/prototype-audit`. You'll get a plain-English report like the examples above.

No prototype repo handy? `cd` into the cloned `~/dev/claude-uxr-skills` itself — it's git-backed and works fine for a sanity check.

## Install (all skills)

Once the skills installer is configured:

```
npx skills add alirortb/claude-uxr-skills
```

Or clone and symlink each skill folder manually into `~/.claude/skills/`:

```
git clone https://github.com/alirortb/claude-uxr-skills.git ~/dev/claude-uxr-skills
ln -s ~/dev/claude-uxr-skills/research-docs ~/.claude/skills/research-docs
ln -s ~/dev/claude-uxr-skills/prototype-audit ~/.claude/skills/prototype-audit
ln -s ~/dev/claude-uxr-skills/eow-summary ~/.claude/skills/eow-summary
```

## Design principles

Common across every skill in this repo:

- **Non-intrusive.** No imposed folder structures. Writes to user's current directory unless told otherwise.
- **Reference, don't restate.** When team standards apply, link to the canonical source rather than re-stating rules. Single source of truth, doesn't rot if upstream evolves.
- **Drafts, not finals.** Output is a starting point for human review, always with surfaced assumptions.
- **Plain language.** Audience often includes non-technical researchers and designers.

## License

MIT — see [LICENSE](./LICENSE).
