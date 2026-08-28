#!/usr/bin/env bash
#
# adopt.sh — sync a repository to this AGENTS template, or report how far it has drifted.
#
#   ./adopt.sh <target-repo>            Report drift. Changes nothing. (default)
#   ./adopt.sh <target-repo> --apply    Copy template-owned files into the target.
#   ./adopt.sh <target-repo> --init     First-time adoption: also seed AGENTS.md and pointers.
#
# Template-owned files are overwritten by --apply. Project-owned files are never
# touched: AGENTS.md (its section 2 is project-specific) and anything not listed below.

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"
MODE="${2:---check}"

if [[ -z "$TARGET" ]]; then
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "error: target '$TARGET' is not a directory" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$TARGET" == "$TEMPLATE_DIR" ]]; then
  echo "error: target is the template itself" >&2
  exit 1
fi

# Files the template owns and keeps in sync.
TEMPLATE_OWNED=(
  ".agents/README.md"
  ".agents/rules"
  ".agents/personas"
  ".agents/workflows"
  ".claude/agents"
)

# Files seeded once on --init, then owned by the project.
INIT_ONLY=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  ".cursorrules"
  ".github/copilot-instructions.md"
)

VERSION="$(cat "$TEMPLATE_DIR/VERSION" 2>/dev/null || echo "unknown")"
echo "template  $TEMPLATE_DIR (v$VERSION)"
echo "target    $TARGET"
echo "mode      $MODE"
echo

# --- Legacy directory check -------------------------------------------------
if [[ -d "$TARGET/.agent" ]]; then
  echo "⚠️  LEGACY: $TARGET/.agent/ exists (singular)."
  echo "   The convention is .agents/ (plural). Migrate with:"
  echo "     git -C \"$TARGET\" mv .agent .agents"
  echo "   Then re-run this script. Nothing below accounts for the old path."
  echo
fi

drift=0

report() {
  local rel="$1" src="$TEMPLATE_DIR/$1" dst="$TARGET/$1"

  if [[ ! -e "$src" ]]; then
    return
  fi

  if [[ ! -e "$dst" ]]; then
    echo "  + MISSING   $rel"
    drift=$((drift + 1))
    return
  fi

  if diff -rq "$src" "$dst" >/dev/null 2>&1; then
    echo "  = in sync   $rel"
  else
    echo "  ~ DRIFTED   $rel"
    diff -rq "$src" "$dst" 2>/dev/null | sed 's/^/      /' || true
    drift=$((drift + 1))
  fi
}

echo "Template-owned:"
for f in "${TEMPLATE_OWNED[@]}"; do report "$f"; done

echo
echo "Project-owned (seeded on --init only):"
for f in "${INIT_ONLY[@]}"; do
  if [[ -e "$TARGET/$f" ]]; then
    echo "  = present   $f"
  else
    echo "  + MISSING   $f"
    drift=$((drift + 1))
  fi
done

echo
case "$MODE" in
  --check)
    if [[ $drift -eq 0 ]]; then
      echo "✅ No drift."
    else
      echo "$drift item(s) out of sync. Re-run with --apply to fix template-owned files."
    fi
    ;;

  --apply|--init)
    for f in "${TEMPLATE_OWNED[@]}"; do
      [[ -e "$TEMPLATE_DIR/$f" ]] || continue
      mkdir -p "$TARGET/$(dirname "$f")"
      cp -R "$TEMPLATE_DIR/$f" "$TARGET/$(dirname "$f")/"
      echo "  copied  $f"
    done

    if [[ "$MODE" == "--init" ]]; then
      for f in "${INIT_ONLY[@]}"; do
        [[ -e "$TEMPLATE_DIR/$f" ]] || continue
        if [[ -e "$TARGET/$f" ]]; then
          echo "  kept    $f (already exists — not overwritten)"
        else
          mkdir -p "$TARGET/$(dirname "$f")"
          cp "$TEMPLATE_DIR/$f" "$TARGET/$f"
          echo "  seeded  $f"
        fi
      done
      echo
      echo "Next: fill in the TODO blocks in AGENTS.md §2, .agents/rules/stack.md,"
      echo "      .agents/rules/design.md, and .agents/rules/dangerous-paths.md."
    fi

    echo
    echo "✅ Done. Review with: git -C \"$TARGET\" diff"
    ;;

  *)
    echo "error: unknown mode '$MODE' (expected --check, --apply, or --init)" >&2
    exit 1
    ;;
esac
