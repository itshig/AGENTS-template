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
broken=0

# --- Reporting --------------------------------------------------------------
echo "Template-owned (--apply overwrites these):"
for f in ${TEMPLATE_FILES[@]+"${TEMPLATE_FILES[@]}"}; do
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

for d in ${TEMPLATE_DIRS[@]+"${TEMPLATE_DIRS[@]}"}; do
  [[ -d "$TEMPLATE_DIR/$d" ]] || continue
  if [[ ! -d "$TARGET/$d" ]]; then
    echo "  + MISSING   $d/"; drift=$((drift + 1)); continue
  fi
  # Compare only the files the template ships. Files the adopter authored in
  # here are theirs — they are listed separately as "unshipped", never counted
  # as drift, because --apply will not remove them and drift you cannot resolve
  # is drift nobody reads.
  dir_drift=0
  while IFS= read -r src; do
    rel="${src#"$TEMPLATE_DIR/$d/"}"
    if [[ ! -e "$TARGET/$d/$rel" ]]; then
      echo "  + MISSING   $d/$rel"; dir_drift=$((dir_drift + 1))
    elif ! cmp -s "$src" "$TARGET/$d/$rel"; then
      echo "  ~ DRIFTED   $d/$rel"; dir_drift=$((dir_drift + 1))
    fi
  done < <(find "$TEMPLATE_DIR/$d" -type f -name '*.md')
  if [[ $dir_drift -eq 0 ]]; then
    echo "  = in sync   $d/"
  else
    drift=$((drift + dir_drift))
  fi
done

for f in ${TEMPLATE_RULES[@]+"${TEMPLATE_RULES[@]}"}; do
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
for f in ${SEAM_RULES[@]+"${SEAM_RULES[@]}"}; do
  src="$TEMPLATE_DIR/.agents/rules/$f"; dst="$TARGET/.agents/rules/$f"
  [[ -e "$src" ]] || continue
  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    echo "  + MISSING   .agents/rules/$f  (will be seeded by --init)"; drift=$((drift + 1))
  elif [[ ! -e "$dst" ]]; then
    echo "  ! BROKEN    .agents/rules/$f — dangling symlink; --apply will not overwrite it"
    broken=$((broken + 1))
  elif cmp -s "$src" "$dst"; then
    echo "  ! UNFILLED  .agents/rules/$f  — identical to template; TODO seams not filled in"
    manual=$((manual + 1))
  else
    remaining=$(grep -c 'TODO when adopting' "$dst" 2>/dev/null || true)
    if [[ "${remaining:-0}" -gt 0 ]]; then
      echo "  ~ yours     .agents/rules/$f  ($remaining TODO seam(s) still unfilled)"
      manual=$((manual + 1))
    else
      echo "  ✓ yours     .agents/rules/$f"
    fi
  fi
done

unshipped=0
report_unshipped() {
  if [[ $unshipped -eq 0 ]]; then
    echo
    echo "Not shipped by the template (yours, or left over from an older version):"
  fi
  echo "  ? unshipped $1"
  unshipped=$((unshipped + 1))
}

# Directories the template mirrors: anything here it does not ship is unshipped.
for d in ${TEMPLATE_DIRS[@]+"${TEMPLATE_DIRS[@]}"}; do
  [[ -d "$TARGET/$d" ]] || continue
  while IFS= read -r dst; do
    rel="${dst#"$TARGET/$d/"}"
    [[ -e "$TEMPLATE_DIR/$d/$rel" ]] || report_unshipped "$d/$rel"
  done < <(find "$TARGET/$d" \( -type f -o -type l \) -name '*.md' 2>/dev/null)
done

# .agents/rules is not a mirrored directory — it holds template rules, seam
# files, and anything the adopter authored. A leftover here matters most:
# Antigravity loads every file in rules/ as an active rule, so a stale rule from
# an older template version keeps being injected into every session forever.
if [[ -d "$TARGET/.agents/rules" ]]; then
  while IFS= read -r dst; do
    # Match on the path relative to rules/, not the basename. A shipped rule is
    # always top-level, so a nested archive/dod.md correctly fails to match
    # dod.md and gets reported instead of hiding behind a name collision.
    rel="${dst#"$TARGET/.agents/rules/"}"
    known=0
    for k in ${TEMPLATE_RULES[@]+"${TEMPLATE_RULES[@]}"} ${SEAM_RULES[@]+"${SEAM_RULES[@]}"}; do
      [[ "$rel" == "$k" ]] && { known=1; break; }
    done
    [[ $known -eq 1 ]] || report_unshipped ".agents/rules/$rel"
  done < <(find "$TARGET/.agents/rules" \( -type f -o -type l \) -name '*.md' 2>/dev/null)
fi

[[ $unshipped -gt 0 ]] && echo "  → --apply will NOT touch these. Delete by hand if they are leftovers."

echo
echo "Root files (seeded on --init only):"
for f in ${INIT_ONLY[@]+"${INIT_ONLY[@]}"}; do
  # -L as well as -e: a dangling symlink is "present" as far as --init is
  # concerned (it will not clobber it), so the report must agree with --apply.
  if [[ -e "$TARGET/$f" ]]; then
    echo "  = present   $f"
  elif [[ -L "$TARGET/$f" ]]; then
    echo "  ! BROKEN    $f — dangling symlink; --init will not overwrite it"
    broken=$((broken + 1))
  else
    echo "  + MISSING   $f"; drift=$((drift + 1))
  fi
done

# --- Rules-file size check (Antigravity caps each at 12,000 chars) ----------
echo
echo "Rules-file size (Antigravity cap: 12000 bytes per file):"
oversize=0; near=0
while IFS= read -r f; do
  [[ -f "$f" ]] || continue
  chars=$(wc -c < "$f" | tr -d ' ')
  if [[ "$chars" -gt 12000 ]]; then
    printf "  ❌ %-30s %s — over cap, will be truncated\n" "${f#"$TARGET/"}" "$chars"
    oversize=$((oversize + 1))
  elif [[ "$chars" -gt 11000 ]]; then
    printf "  ⚠️  %-30s %s — approaching cap\n" "${f#"$TARGET/"}" "$chars"
    near=$((near + 1))
  fi
done < <( { [[ -e "$TARGET/AGENTS.md" ]] && echo "$TARGET/AGENTS.md"; \
            find "$TARGET/.agents/rules" \( -type f -o -type l \) -name '*.md' 2>/dev/null; } || true )
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
    # Non-zero when action is needed, so this can gate CI. 0 = nothing to do.
    [[ $broken -gt 0 ]] && echo "$broken file(s) are dangling symlinks — no tool can read them; --apply will not fix this."
    if [[ $drift -gt 0 || $oversize -gt 0 || $broken -gt 0 ]]; then exit 1; fi
    exit 0
    ;;

  --apply|--init)
    for f in ${TEMPLATE_FILES[@]+"${TEMPLATE_FILES[@]}"}; do
      [[ -e "$TEMPLATE_DIR/$f" ]] || continue
      mkdir -p "$TARGET/$(dirname "$f")"
      rm -f "$TARGET/$f"
      cp "$TEMPLATE_DIR/$f" "$TARGET/$f"
      echo "  synced  $f"
    done

    for d in ${TEMPLATE_DIRS[@]+"${TEMPLATE_DIRS[@]}"}; do
      [[ -e "$TEMPLATE_DIR/$d" ]] || continue
      mkdir -p "$TARGET/$d"
      # Copy the template's files, overwriting. Deliberately NON-destructive:
      # these directories are ones the template tells adopters to author into,
      # so anything not shipped by the template is assumed to be theirs. Removed
      # template files are reported by --check as "? unshipped", not deleted —
      # the filesystem cannot distinguish "template dropped this" from "they
      # wrote this", and guessing wrong destroys work.
      while IFS= read -r src; do
        rel="${src#"$TEMPLATE_DIR/$d/"}"
        dst="$TARGET/$d/$rel"
        mkdir -p "$(dirname "$dst")"
        rm -f "$dst"           # never write through a symlink
        cp "$src" "$dst"
      done < <(find "$TEMPLATE_DIR/$d" -type f -name '*.md')
      echo "  synced  $d/"
    done

    mkdir -p "$TARGET/.agents/rules"
    for f in ${TEMPLATE_RULES[@]+"${TEMPLATE_RULES[@]}"}; do
      [[ -e "$TEMPLATE_DIR/.agents/rules/$f" ]] || continue
      rm -f "$TARGET/.agents/rules/$f"
      cp "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f"
      echo "  synced  .agents/rules/$f"
    done

    for f in ${SEAM_RULES[@]+"${SEAM_RULES[@]}"}; do
      [[ -e "$TEMPLATE_DIR/.agents/rules/$f" ]] || continue
      if [[ -e "$TARGET/.agents/rules/$f" || -L "$TARGET/.agents/rules/$f" ]]; then
        cmp -s "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f" 2>/dev/null \
          || echo "  kept    .agents/rules/$f (yours — template differs, merge by hand if needed)"
      else
        rm -f "$TARGET/.agents/rules/$f"
        cp "$TEMPLATE_DIR/.agents/rules/$f" "$TARGET/.agents/rules/$f"
        echo "  seeded  .agents/rules/$f"
      fi
    done

    if [[ "$MODE" == "--init" ]]; then
      for f in ${INIT_ONLY[@]+"${INIT_ONLY[@]}"}; do
        [[ -e "$TEMPLATE_DIR/$f" ]] || continue
        if [[ -e "$TARGET/$f" || -L "$TARGET/$f" ]]; then
          echo "  kept    $f (already exists)"
        else
          mkdir -p "$TARGET/$(dirname "$f")"
          rm -f "$TARGET/$f"
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
