#!/usr/bin/env bash
# Setup tasks generation context and output JSON for /speckit-tasks.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SPECS_DIR="$REPO_ROOT/specs"
SPECIFY_DIR="$REPO_ROOT/.specify"

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

# Resolve tasks-template.md using resolution hierarchy
TASKS_TEMPLATE=""
for candidate in \
    "$SPECIFY_DIR/templates/overrides/tasks-template.md" \
    "$SPECIFY_DIR/presets/templates/tasks-template.md" \
    "$SPECIFY_DIR/extensions/templates/tasks-template.md" \
    "$SPECIFY_DIR/templates/tasks-template.md"; do
    if [[ -f "$candidate" ]]; then
        TASKS_TEMPLATE="$candidate"
        break
    fi
done

DOCS=()
for doc in "spec.md" "plan.md" "research.md" "data-model.md" "quickstart.md"; do
    if [[ -f "$FEATURE_DIR/$doc" ]]; then
        DOCS+=("\"$doc\"")
    fi
done
if [[ -d "$FEATURE_DIR/contracts" ]]; then
    DOCS+=("\"contracts/\"")
fi
if [[ -d "$FEATURE_DIR/checklists" ]]; then
    DOCS+=("\"checklists/\"")
fi

AVAILABLE_DOCS_JSON="$(IFS=,; echo "${DOCS[*]}")"

cat <<EOF
{
  "FEATURE_DIR": "$FEATURE_DIR",
  "TASKS_TEMPLATE": "$TASKS_TEMPLATE",
  "AVAILABLE_DOCS": [${AVAILABLE_DOCS_JSON}]
}
EOF
