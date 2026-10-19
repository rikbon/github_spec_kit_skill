#!/usr/bin/env bash
# Setup implementation plan artifact and output context JSON for /speckit-plan.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SPECS_DIR="$REPO_ROOT/specs"
SPECIFY_DIR="$REPO_ROOT/.specify"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")"

# Resolve active feature directory
FEATURE_REL=""
if [[ -f "$SPECIFY_DIR/feature.json" ]]; then
    FEATURE_REL="$(grep -o '"feature_directory"[[:space:]]*:[[:space:]]*"[^"]*"' "$SPECIFY_DIR/feature.json" | head -n1 | sed 's/.*"feature_directory"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || true)"
fi

if [[ -z "$FEATURE_REL" && -d "$SPECS_DIR" ]]; then
    LATEST_DIR="$(find "$SPECS_DIR" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
    if [[ -n "$LATEST_DIR" ]]; then
        FEATURE_REL="specs/$(basename "$LATEST_DIR")"
    fi
fi

if [[ -z "$FEATURE_REL" ]]; then
    echo '{"error": "No active feature directory found. Run /speckit-specify first."}' >&2
    exit 1
fi

if [[ "$FEATURE_REL" = /* ]]; then
    FEATURE_DIR="$FEATURE_REL"
else
    FEATURE_DIR="$REPO_ROOT/$FEATURE_REL"
fi

FEATURE_SPEC="$FEATURE_DIR/spec.md"
IMPL_PLAN="$FEATURE_DIR/plan.md"

# Resolve plan-template.md using resolution hierarchy
PLAN_TEMPLATE=""
for candidate in \
    "$SPECIFY_DIR/templates/overrides/plan-template.md" \
    "$SPECIFY_DIR/presets/templates/plan-template.md" \
    "$SPECIFY_DIR/extensions/templates/plan-template.md" \
    "$SPECIFY_DIR/templates/plan-template.md"; do
    if [[ -f "$candidate" ]]; then
        PLAN_TEMPLATE="$candidate"
        break
    fi
done

mkdir -p "$FEATURE_DIR"
if [[ ! -f "$IMPL_PLAN" && -n "$PLAN_TEMPLATE" ]]; then
    cp "$PLAN_TEMPLATE" "$IMPL_PLAN"
fi

cat <<EOF
{
  "FEATURE_DIR": "$FEATURE_DIR",
  "FEATURE_SPEC": "$FEATURE_SPEC",
  "IMPL_PLAN": "$IMPL_PLAN",
  "SPECS_DIR": "$SPECS_DIR",
  "BRANCH": "$BRANCH"
}
EOF
