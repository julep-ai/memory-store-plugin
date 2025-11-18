#!/bin/bash
# Pre-Commit Validation - Interactive checkpoint before committing
# This script runs before git commit to validate changes

set -euo pipefail

# Read and discard stdin (hook protocol requirement)
if [ ! -t 0 ]; then
    cat > /dev/null
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"

# Load session state from project-local file
SESSION_FILE="${PROJECT_DIR}/.claude-session"
if [[ -f "${SESSION_FILE}" ]]; then
    source "${SESSION_FILE}"
fi

SESSION_ID="${MEMORY_SESSION_ID:-unknown}"

# Log function
log() {
    echo "[Memory Plugin - Commit Validation] $1" >&2
}

log "Pre-commit validation starting..."

# Check if there are staged changes
if ! git diff --cached --quiet 2>/dev/null; then
    STAGED_FILES=$(git diff --cached --name-only)
    FILE_COUNT=$(echo "$STAGED_FILES" | wc -l | tr -d ' ')
    LINES_ADDED=$(git diff --cached --numstat | awk '{sum+=$1} END {print sum}' || echo "0")
    LINES_REMOVED=$(git diff --cached --numstat | awk '{sum+=$2} END {print sum}' || echo "0")
else
    log "No staged changes to validate"
    exit 0
fi

# Get session context
SESSION_GOALS=$(cat "${PROJECT_DIR}/.claude-session-goals" 2>/dev/null || echo "No specific goals set for this session")

# Check for large commits
IS_LARGE_COMMIT="false"
if [[ "${FILE_COUNT}" -gt 5 ]] || [[ "${LINES_ADDED}" -gt 300 ]]; then
    IS_LARGE_COMMIT="true"
fi

log "Commit size: ${FILE_COUNT} files, +${LINES_ADDED}/-${LINES_REMOVED} lines"

# Build validation summary
VALIDATION_SUMMARY=$(cat <<EOF

╔══════════════════════════════════════════════════════════╗
║           🔍 COMMIT VALIDATION CHECKPOINT                ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  About to commit: ${FILE_COUNT} files                          ║
║  Changes: +${LINES_ADDED} / -${LINES_REMOVED} lines                   ║
║  Session: ${SESSION_ID}                    ║
║                                                          ║
║  Session Goals:                                          ║
EOF
)

# Add goals with proper formatting
while IFS= read -r goal_line; do
    VALIDATION_SUMMARY="${VALIDATION_SUMMARY}
║    ${goal_line}"
done <<< "$SESSION_GOALS"

VALIDATION_SUMMARY="${VALIDATION_SUMMARY}
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  Files to be committed:                                  ║
║                                                          ║"

# Analyze each file
FILE_ANALYSIS=""
while IFS= read -r FILE; do
    [[ -z "$FILE" ]] && continue

    # Determine change type
    if git diff --cached --diff-filter=A --name-only | grep -q "^${FILE}$" 2>/dev/null; then
        CHANGE_TYPE="NEW"
    elif git diff --cached --diff-filter=D --name-only | grep -q "^${FILE}$" 2>/dev/null; then
        CHANGE_TYPE="DELETED"
    else
        CHANGE_TYPE="MODIFIED"
    fi

    # Detect pattern
    PATTERN=""
    [[ "$FILE" =~ test|spec ]] && PATTERN="(Test)"
    [[ "$FILE" =~ api|routes ]] && PATTERN="(API)"
    [[ "$FILE" =~ component|view ]] && PATTERN="(UI)"
    [[ "$FILE" =~ service ]] && PATTERN="(Service)"
    [[ "$FILE" =~ model|entity|schema ]] && PATTERN="(Data)"
    [[ "$FILE" =~ config|\.env ]] && PATTERN="(Config)"

    # Get line changes for this file
    FILE_STATS=$(git diff --cached --numstat "$FILE" 2>/dev/null || echo "0	0")
    FILE_ADDED=$(echo "$FILE_STATS" | awk '{print $1}')
    FILE_REMOVED=$(echo "$FILE_STATS" | awk '{print $2}')

    FILE_ANALYSIS="${FILE_ANALYSIS}
║  ✓ ${FILE} (${CHANGE_TYPE}) ${PATTERN}
║    └─ +${FILE_ADDED}/-${FILE_REMOVED}"
done <<< "$STAGED_FILES"

VALIDATION_SUMMARY="${VALIDATION_SUMMARY}${FILE_ANALYSIS}
║                                                          ║
╠══════════════════════════════════════════════════════════╣"

# Add warnings for large commits
if [[ "${IS_LARGE_COMMIT}" == "true" ]]; then
    VALIDATION_SUMMARY="${VALIDATION_SUMMARY}
║                                                          ║
║  ⚠️  LARGE COMMIT DETECTED                               ║
║     Please validate these changes match expectations     ║
║                                                          ║"
fi

# Check for potential issues
WARNINGS=""

# Check for token/secret patterns
if echo "$STAGED_FILES" | grep -E '\.(env|json)$' > /dev/null; then
    for FILE in $STAGED_FILES; do
        if git diff --cached "$FILE" | grep -iE '(token|password|secret|api_key|private).*=.*[a-zA-Z0-9]{20,}' > /dev/null 2>&1; then
            WARNINGS="${WARNINGS}
║  🔒 WARNING: Potential secret detected in ${FILE}       ║"
        fi
    done
fi

# Check for debug code
if git diff --cached | grep -E '(console\.log|debugger|pdb\.set_trace|binding\.pry)' > /dev/null 2>&1; then
    WARNINGS="${WARNINGS}
║  🐛 WARNING: Debug code detected (console.log, etc)     ║"
fi

if [[ -n "${WARNINGS}" ]]; then
    VALIDATION_SUMMARY="${VALIDATION_SUMMARY}${WARNINGS}
║                                                          ║"
fi

VALIDATION_SUMMARY="${VALIDATION_SUMMARY}
╠══════════════════════════════════════════════════════════╣
║  Validation Questions:                                   ║
║                                                          ║
║  1. Do all files match the session goals?                ║
║  2. Are there any mistakes or wrong approaches?          ║
║  3. Should any changes be corrected before commit?       ║
║  4. Is the commit message semantic and descriptive?      ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"

# Output validation summary
echo "${VALIDATION_SUMMARY}"

# Save validation summary for Claude to process
cat > "${PROJECT_DIR}/.claude-commit-validation.txt" <<EOF
${VALIDATION_SUMMARY}

Session: ${SESSION_ID}
Files: ${FILE_COUNT}
Changes: +${LINES_ADDED}/-${LINES_REMOVED}
Large Commit: ${IS_LARGE_COMMIT}
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

log "Validation complete. Review the changes above."

# Note: This doesn't block the commit, just provides information
# Claude Code can use this information to ask the user for validation

exit 0
