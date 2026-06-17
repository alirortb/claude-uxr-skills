#!/usr/bin/env bash
# Idempotent installer for claude-uxr-skills.
# Symlinks every skill folder (any dir containing a SKILL.md) into ~/.claude/skills/.
# Safe to re-run: replaces an existing symlink in place rather than nesting a link
# inside it (the bug that `ln -s` causes on re-run — see git history).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

installed=0
for skill_md in "$REPO_DIR"/*/SKILL.md; do
  [ -e "$skill_md" ] || continue                 # no skills found → skip cleanly
  skill_dir="$(dirname "$skill_md")"
  name="$(basename "$skill_dir")"
  link="$SKILLS_DIR/$name"

  if [ -L "$link" ]; then
    rm -f "$link"                                # existing symlink → remove the link only
  elif [ -e "$link" ]; then
    echo "skip: $link exists and is not a symlink — leaving it alone" >&2
    continue
  fi

  ln -s "$skill_dir" "$link"                     # link target now guaranteed absent
  echo "linked: $name -> $skill_dir"
  installed=$((installed + 1))
done

echo "done: $installed skill(s) linked into $SKILLS_DIR"
