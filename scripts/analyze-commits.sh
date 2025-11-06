#!/bin/bash
# Analyze Commits Hook - Track git commit patterns and context
# This script runs after git commit commands

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
SESSION_FILE="${CLAUDE_MEMORY_SESSION_FILE:-}"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log "Not in a git repository, skipping commit analysis"
    exit 0
fi

log "Analyzing recent commit..."

# Get the most recent commit
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null || echo "")
COMMIT_DATE=$(git log -1 --pretty=format:"%ci" 2>/dev/null || echo "")
COMMIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

log "Commit: ${COMMIT_HASH} - ${COMMIT_MESSAGE}"

# Get files changed in this commit
FILES_CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || echo "")
FILES_COUNT=$(echo "${FILES_CHANGED}" | grep -c . || echo "0")

# Analyze commit message pattern (conventional commits)
COMMIT_TYPE="unknown"
if [[ "${COMMIT_MESSAGE}" =~ ^feat:.*$ ]]; then
    COMMIT_TYPE="feature"
elif [[ "${COMMIT_MESSAGE}" =~ ^fix:.*$ ]]; then
    COMMIT_TYPE="bugfix"
elif [[ "${COMMIT_MESSAGE}" =~ ^docs:.*$ ]]; then
    COMMIT_TYPE="documentation"
elif [[ "${COMMIT_MESSAGE}" =~ ^test:.*$ ]]; then
    COMMIT_TYPE="test"
elif [[ "${COMMIT_MESSAGE}" =~ ^refactor:.*$ ]]; then
    COMMIT_TYPE="refactoring"
elif [[ "${COMMIT_MESSAGE}" =~ ^chore:.*$ ]]; then
    COMMIT_TYPE="chore"
elif [[ "${COMMIT_MESSAGE}" =~ ^style:.*$ ]]; then
    COMMIT_TYPE="style"
fi

# Get diff stats
ADDITIONS=$(git show --stat HEAD | grep -E '^\s+\d+\s+file' | awk '{sum+=$4} END {print sum}' || echo "0")
DELETIONS=$(git show --stat HEAD | grep -E '^\s+\d+\s+file' | awk '{sum+=$6} END {print sum}' || echo "0")

# Detect if this commit affects important files
IMPORTANT_FILES_AFFECTED=""
if echo "${FILES_CHANGED}" | grep -qE "(package\.json|tsconfig\.json|\.env|docker|kubernetes|infrastructure)"; then
    IMPORTANT_FILES_AFFECTED="infrastructure/config files"
elif echo "${FILES_CHANGED}" | grep -qE "CLAUDE\.md"; then
    IMPORTANT_FILES_AFFECTED="documentation"
elif echo "${FILES_CHANGED}" | grep -qE "test"; then
    IMPORTANT_FILES_AFFECTED="tests"
fi

# Check for breaking changes
BREAKING_CHANGE="false"
if git log -1 --pretty=format:"%B" | grep -qE "(BREAKING CHANGE|BREAKING:)"; then
    BREAKING_CHANGE="true"
    log "⚠️  Breaking change detected!"
fi

# Get related ticket/issue number
TICKET_NUMBER=""
if [[ "${COMMIT_MESSAGE}" =~ \#([0-9]+) ]]; then
    TICKET_NUMBER="${BASH_REMATCH[1]}"
fi
if [[ "${COMMIT_BRANCH}" =~ /([A-Z]+-[0-9]+) ]]; then
    TICKET_NUMBER="${BASH_REMATCH[1]}"
fi

# Update session file
if [[ -f "${SESSION_FILE}" ]]; then
    jq --arg commit "${COMMIT_HASH}" --arg message "${COMMIT_MESSAGE}" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.commits_analyzed += [{"commit": $commit, "message": $message, "time": $time}]' \
        "${SESSION_FILE}" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "${SESSION_FILE}"
fi

# Prepare detailed commit context
COMMIT_CONTEXT=$(cat <<EOF
Commit ${COMMIT_HASH} on branch ${COMMIT_BRANCH}
Type: ${COMMIT_TYPE}
Files changed: ${FILES_COUNT}
Additions: ${ADDITIONS}, Deletions: ${DELETIONS}
Important files: ${IMPORTANT_FILES_AFFECTED}
Breaking change: ${BREAKING_CHANGE}
Ticket: ${TICKET_NUMBER}
Files: ${FILES_CHANGED}
EOF
)

# Prepare memory record
MEMORY_TEXT="Commit: ${COMMIT_MESSAGE} (${COMMIT_TYPE})"
if [[ -n "${TICKET_NUMBER}" ]]; then
    MEMORY_TEXT="${MEMORY_TEXT} - Ticket ${TICKET_NUMBER}"
fi

MEMORY_PAYLOAD=$(cat <<EOF
{
  "memory": "${MEMORY_TEXT}",
  "background": "${COMMIT_CONTEXT}. Session: ${SESSION_ID}. Author: ${COMMIT_AUTHOR}. Date: ${COMMIT_DATE}",
  "importance": "$(if [[ "${BREAKING_CHANGE}" == "true" ]] || [[ -n "${IMPORTANT_FILES_AFFECTED}" ]]; then echo "high"; else echo "normal"; fi)"
}
EOF
)

log "Commit analyzed: ${COMMIT_HASH}"
log "Type: ${COMMIT_TYPE}, Files: ${FILES_COUNT}, Breaking: ${BREAKING_CHANGE}"

# Analyze branching strategy (periodic check)
BRANCH_COUNT=$(git branch -a | wc -l | tr -d ' ')
ACTIVE_FEATURES=$(git branch -a | grep -c "feature/" || echo "0")
ACTIVE_BUGFIXES=$(git branch -a | grep -c "bugfix/" || echo "0")

if [[ "${BRANCH_COUNT}" -gt 5 ]]; then
    log "Detected ${ACTIVE_FEATURES} feature branches, ${ACTIVE_BUGFIXES} bugfix branches"
fi

exit 0
