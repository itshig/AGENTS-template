#!/usr/bin/env bash
#
# adopt.sh — sync a repository to this AGENTS template, or report how far it has drifted.
#
#   ./adopt.sh <target-repo>            Report drift. Changes nothing. (default)
#   ./adopt.sh <target-repo> --apply    Copy template-owned files into the target.
#   ./adopt.sh <target-repo> --init     First-time adoption: also seed AGENTS.md and pointers.
#
# Three categories:
#   template-owned  overwritten by --apply (generic rules, personas, workflows, sub-agents)
#   seam files      seeded once, NEVER overwritten (they hold your project's commands
#                   and paths). --check tells you when the template's copy has moved.
#   root files      seeded once on --init (AGENTS.md and the tool pointers).

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"
MODE="${2:---check}"

if [[ -z "$TARGET" ]]; then
  # Print the header comment block, whatever length it is. Line ranges rot.
  awk 'NR>1 { if (/^#/) { sub(/^# ?/, ""); print } else { exit } }' "$0"
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

# Directories the template owns wholesale. Overwritten by --apply.
TEMPLATE_FILES=(
  ".agents/README.md"
  ".agents/RULES-INDEX.md"
)

TEMPLATE_DIRS=(
  ".agents/personas"
  ".agents/workflows"
  ".claude/agents"
)

# Generic rule files the template owns. Overwritten by --apply.
TEMPLATE_RULES=(
  "architect.md" "debugger.md" "docs.md" "dod.md" "migrations.md"
  "reviewer.md" "security.md" "test-writer.md"
)

# Rule files containing `TODO when adopting` seams. Seeded once, then owned by
# the project. NEVER overwritten — these hold project-specific commands, paths,
# and library choices. --check reports when the template's copy has moved so you
# can merge by hand.
SEAM_RULES=(
  "dangerous-paths.md" "design.md" "encryption.md"
  "logging.md" "stack.md" "validation.md"
)

# Root files seeded once on --init, then owned by the project.
INIT_ONLY=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
)

VERSION="$(cat "$TEMPLATE_DIR/VERSION" 2>/dev/null || echo "unknown")"
echo "template  $TEMPLATE_DIR (v$VERSION)"
echo "target    $TARGET"
echo "mode      $MODE"
echo

# --- Legacy directory check -------------------------------------------------
if [[ -d "$TARGET/.agent" ]]; then
  echo "⚠️  LEGACY: $TARGET/.agent/ exists (singular)."
  echo "   .agents/ is the current default. Antigravity still reads .agent/rules as a"
  echo "   deprecated fallback, so this is not broken — but it will stop being read"
  echo "   eventually, and nothing else in this toolchain looks there. Migrate with:"
  echo "     git -C \"$TARGET\" mv .agent .agents"
  echo "   Then re-run this script. Nothing below accounts for the old path."
  echo
fi

drift=0
manual=0

# --- Reporting --------------------------------------------------------------
echo "Template-owned (--apply overwrites these):"
for f in "${TEMPLATE_FILES[@]}"; do
  src="$TEMPLATE_DIR/$f"; dst="$TARGET/$f"
  [[ -e "$src" ]] || continue
  if [[ ! -e "$dst" ]]; then
    echo "  + MISSING   $f"; drift=$((drift + 1))
  elif cmp -s "$src" "$dst"; then
    echo "  = in sync   $f"
  else
    echo "  ~ DRIFTED   $f"; drift=$((drift + 1))
  fi
done

for d in "${TEMPLATE_DIRS[@]}"; do
  src="$TEMPLATE_DIR/$d"; dst="$TARGET/$d"
  [[ -e "$src" ]] || continue
  if [[ ! -e "$dst" ]]; then
    echo "  + MISSING   $d/"; drift=$((drift + 1))
  elif diff -rq -x '.DS_Store' "$src" "$dst" >/dev/null 2>&1; then
    echo "  = in sync   $d/"
  else
    echo "  ~ DRIFTED   $d/"
    diff -rq -x '.DS_Store' "$src" "$dst" 2>/dev/null | sed 's/^/      /' || true
    drift=$((drift + 1))
  fi
done

for f in "${TEMPLATE_RULES[@]}"; do
  src="$TEMPLATE_DIR/.agents/rules/$f"; dst="$TARGET/.agents/rules/$f"
  [[ -e "$src" ]] || continue
  if [[ ! -e "$dst" ]]; then
    echo "  + MISSING   .agents/rules/$f"; drift=$((drift + 1))
  elif cmp -s "$src" "$dst"; then
    echo "  = in sync   .agents/rules/$f"
  else
    echo "  ~ DRIFTED   .agents/rules/$f"; drift=$((drift + 1))
  fi
done

echo
echo "Seam files (yours — seeded once, never overwritten):"
for f in "${SEAM_RULES[@]}"; do
  src="$TEMPLATE_DIR/.agents/rules/$f"; dst="$TARGET/.agents/rules/$f"
  [[ -e "$src" ]] || continue
  if [[ ! -e "$dst" ]]; then
    echo "  + MISSING   .agents/rules/$f  (will be seeded by --init)"; drift=$((drift + 1))
  elif cmp -s "$src" "$dst"; then
    echo "  ! UNFILLED  .agents/rules/$f  — identical to template; TODO seams not filled in"
    manual=$((manual + 1))
  else
    remaining=$(grep -c 'TODO when adopting' "$dst" 2>/dev/null || echo 0)
    if [[ "$remaining" -gt 0 ]]; then
      echo "  ~ yours     .agents/rules/$f  ($remaining TODO seam(s) still unfilled)"
      manual=$((manual + 1))
    else
      echo "  ✓ yours     .agents/rules/$f"
    fi
  fi
done

echo
echo "Root files (seeded on --init only):"
for f in "${INIT_ONLY[@]}"; do
  if [[ -e "$TARGET/$f" ]]; then
    echo "  = present   $f"
  else
    echo "  + MISSING   $f"; drift=$((drift + 1))
  fi
done

# --- Rules-file size check (Antigravity caps each at 12,000 chars) ----------
echo
echo "Rules-file size (Antigravity cap: 12000 chars per file):"
oversize=0; near=0
for f in "$TARGET"/AGENTS.md "$TARGET"/.agents/rules/*.md; do
  [[ -f "$f" ]] || continue
  chars=$(wc -c < "$f" | tr -d ' ')
  if [[ "$chars" -gt 12000 ]]; then
    printf "  ❌ %-30s %s — over cap, will be truncated\n" "$(basename "$f")" "$chars"
    oversize=$((oversize + 1))
  elif [[ "$chars" -gt 10000 ]]; then
    printf "  ⚠️  %-30s %s — approaching cap\n" "$(basename "$f")" "$chars"
    near=$((near + 1))
  fi
done
if [[ $oversize -eq 0 && $near -eq 0 ]]; then
  echo "  ✅ all within cap"
fi

echo
case "$MODE" in
  --check)
    [[ $drift -eq 0 ]] && echo "✅ No drift in template-owned files." \
                       || echo "$drift template-owned item(s) out of sync — run --apply."
    [[ $manual -gt 0 ]] && echo "$manual seam file(s) need attention — see above. --apply will NOT touch these."
    [[ $oversize -gt 0 ]] && echo "$oversize file(s) over the 12000-char cap — trim before relying on Antigravity."
    exit 0
    ;;

  --apply|--init)
    for f in "${TEMPLATE_FILES[@]}"; do
      [[ -e "$TEMPLATE_DIR/$f" ]] || continue
      mkdir -p "$TARGET/$(dirname "$f")"
      cp "$TEMPLATE_DIR/$f" "$TARGET/$f"
      echo "  synced  $f"
    done

    for d in "${TEMPLATE_DIRS[@]}"; do
      [[ -e "$TEMPLATE_DIR/$d" ]] || continue
      mkdir -p "$TARGET/$d"
      # Mirror contents, dropping files the template has removed. No --delete on
      # the whole dir: rsync is not guaranteed present, so do it explicitly.
      find "$TARGET/$d" -type f -name '*.md' -delete 2>/dev/null || true
      find "$TEMPLATE_DIR/$d" -type f -name '*.md' -exec cp {} "$TARGET/$d/" \;
      echo "  synced  $d/"
    done

    mkdir -p "$TARGET/.agents/rules"
    for f in "${TEMPLATE_RULES[@]}"; do
      [[ -e "$TEMPLATE_DIR/.agents/rules/$f" ]] || continue
      cp "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f"
      echo "  synced  .agents/rules/$f"
    done

    for f in "${SEAM_RULES[@]}"; do
      [[ -e "$TEMPLATE_DIR/.agents/rules/$f" ]] || continue
      if [[ -e "$TARGET/.agents/rules/$f" ]]; then
        cmp -s "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f" \
          || echo "  kept    .agents/rules/$f (yours — template differs, merge by hand if needed)"
      else
        cp "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f"
        echo "  seeded  .agents/rules/$f"
      fi
    done

    if [[ "$MODE" == "--init" ]]; then
      for f in "${INIT_ONLY[@]}"; do
        [[ -e "$TEMPLATE_DIR/$f" ]] || continue
        if [[ -e "$TARGET/$f" ]]; then
          echo "  kept    $f (already exists)"
        else
          mkdir -p "$TARGET/$(dirname "$f")"
          cp "$TEMPLATE_DIR/$f" "$TARGET/$f"
          echo "  seeded  $f"
        fi
      done
      echo
      echo "Next: fill in every 'TODO when adopting' seam. Find them with:"
      echo "  grep -rn 'TODO when adopting' \"$TARGET/AGENTS.md\" \"$TARGET/.agents/rules/\""
    fi

    echo
    echo "✅ Done. Review with: git -C \"$TARGET\" diff"
    exit 0
    ;;

  *)
    echo "error: unknown mode '$MODE' (expected --check, --apply, or --init)" >&2
    exit 1
    ;;
esac
