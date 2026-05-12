# claude-skills

Personal [Claude Code](https://claude.com/claude-code) skills for UXR/ReOps work at Miro.

## Positioning

This repo is **personal R&D space** for skills I use day-to-day. It **complements** team-distributed skill collections like [`miroapp-dev/uxr-skills`](https://github.com/miroapp-dev/uxr-skills) (Michael Schade's `customer-insights` and related) — it is **not a fork, alternative, or competitor**. Where workflows overlap, my skills hand off to the team skills via informational pointers rather than duplicating their logic. Skills here may be PR'd upstream once they've earned the keep across multiple real uses.

## Skills

- **[`research-docs`](./research-docs/)** — Generate UXR plan, interview guide, or insights one-pager. Bookends `customer-insights` (BEFORE + AFTER stages); never replicates transcript analysis or synthesis.
- **[`prototype-audit`](./prototype-audit/)** — Read-only safety check for prototype repos against the [design-team prototype playbook](https://github.com/miroapp-dev/prototype-playbook). Surfaces state plainly for non-technical users; never auto-fixes.
- **[`eow-summary`](./eow-summary/)** — Generate an end-of-week summary by scanning Claude Code transcripts, `~/dev/*` git activity, `~/dev/deliverables/` entries, and project memory. Produces a layered draft (personal log, team digest, AI Design Guild candidates) for editing before sharing.

## Install

Once the skills installer is configured:

```
npx skills add alirortb/claude-skills
```

Or clone and symlink each skill folder manually into `~/.claude/skills/`:

```
git clone https://github.com/alirortb/claude-skills.git ~/dev/claude-skills
ln -s ~/dev/claude-skills/research-docs ~/.claude/skills/research-docs
ln -s ~/dev/claude-skills/prototype-audit ~/.claude/skills/prototype-audit
ln -s ~/dev/claude-skills/eow-summary ~/.claude/skills/eow-summary
```

## Design principles

Common across every skill in this repo:

- **Non-intrusive.** No imposed folder structures. Writes to user's current directory unless told otherwise.
- **Reference, don't restate.** When team standards apply, link to the canonical source rather than re-stating rules. Single source of truth, doesn't rot if upstream evolves.
- **Drafts, not finals.** Output is a starting point for human review, always with surfaced assumptions.
- **Plain language.** Audience often includes non-technical researchers and designers.

## License

MIT — see [LICENSE](./LICENSE).
