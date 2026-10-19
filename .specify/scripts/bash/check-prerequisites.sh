#!/usr/bin/env bash
# Check prerequisites and resolve active Spec-Kit feature paths.
# Supports: --json, --paths-only, --require-tasks, --include-tasks

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SPECS_DIR="$REPO_ROOT/specs"
SPECIFY_DIR="$REPO_ROOT/.specify"

REQUIRE_TASKS="false"
INCLUDE_TASKS="false"
PATHS_ONLY="false"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --json|-Json)
            ;;
        --paths-only|-PathsOnly)
            PATHS_ONLY="true"
            ;;
        --require-tasks)
            REQUIRE_TASKS="true"
            ;;
        --include-tasks)
            INCLUDE_TASKS="true"
            ;;
        *)
            ;;
    esac
    shift
done

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
TASKS="$FEATURE_DIR/tasks.md"

if [[ "$PATHS_ONLY" == "true" ]]; then
    cat <<EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "FEATURE_DIR": "$FEATURE_DIR",
  "FEATURE_SPEC": "$FEATURE_SPEC",
  "IMPL_PLAN": "$IMPL_PLAN",
  "TASKS": "$TASKS"
}
EOF
    exit 0
fi

if [[ ! -f "$FEATURE_SPEC" ]]; then
    echo "{\"error\": \"Missing spec.md in $FEATURE_DIR. Run /speckit-specify first.\"}" >&2
    exit 1
fi

if [[ "$REQUIRE_TASKS" == "true" && ! -f "$TASKS" ]]; then
    echo "{\"error\": \"Missing tasks.md in $FEATURE_DIR. Run /speckit-tasks first.\"}" >&2
    exit 1
fi

# Collect available docs under FEATURE_DIR
DOCS=()
for doc in "spec.md" "plan.md" "research.md" "data-model.md" "quickstart.md"; do
    if [[ -f "$FEATURE_DIR/$doc" ]]; then
        DOCS+=("\"$doc\"")
    fi
done
if [[ "$INCLUDE_TASKS" == "true" && -f "$TASKS" ]]; then
    DOCS+=("\"tasks.md\"")
fi
if [[ -d "$FEATURE_DIR/contracts" ]]; then
    DOCS+=("\"contracts/\"")
fi
if [[ -d "$FEATURE_DIR/checklists" ]]; then
    DOCS+=("\"checklists/\"")
fi

AVAILABLE_DOCS_JSON="$(IFS=,; echo "${DOCS[*]}")"

cat <<EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "FEATURE_DIR": "$FEATURE_DIR",
  "FEATURE_SPEC": "$FEATURE_SPEC",
  "IMPL_PLAN": "$IMPL_PLAN",
  "TASKS": "$TASKS",
  "AVAILABLE_DOCS": [${AVAILABLE_DOCS_JSON}]
}
EOF
