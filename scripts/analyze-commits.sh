#!/bin/bash
# Analyze Commits Hook - Track git commit patterns and context
# This script runs after git commit commands

set -euo pipefail

# Read and discard stdin (hook protocol requirement)
if [ ! -t 0 ]; then
    cat > /dev/null
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
SESSION_ID="${MEMORY_SESSION_ID:-unknown}"

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    cat <<EOF
{
  "continue": true
}
EOF
    exit 0
fi

# Get the most recent commit
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null || echo "")
COMMIT_DATE=$(git log -1 --pretty=format:"%ci" 2>/dev/null || echo "")
COMMIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

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

# Increment commit counter
COMMITS_COUNT=$((${MEMORY_COMMITS_COUNT:-0} + 1))

# Update environment file
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
    if grep -q "MEMORY_COMMITS_COUNT=" "${CLAUDE_ENV_FILE}" 2>/dev/null; then
        sed -i.bak "s/MEMORY_COMMITS_COUNT=.*/MEMORY_COMMITS_COUNT=${COMMITS_COUNT}/" "${CLAUDE_ENV_FILE}"
        rm -f "${CLAUDE_ENV_FILE}.bak"
    else
        echo "export MEMORY_COMMITS_COUNT=${COMMITS_COUNT}" >> "${CLAUDE_ENV_FILE}"
    fi
fi

# Build commit summary
COMMIT_SUMMARY="${COMMIT_MESSAGE} (${COMMIT_TYPE})"
if [[ -n "${TICKET_NUMBER}" ]]; then
    COMMIT_SUMMARY="${COMMIT_SUMMARY} - Ticket ${TICKET_NUMBER}"
fi
if [[ "${BREAKING_CHANGE}" == "true" ]]; then
    COMMIT_SUMMARY="⚠️ BREAKING: ${COMMIT_SUMMARY}"
fi

# Determine importance
IMPORTANCE="normal"
if [[ "${BREAKING_CHANGE}" == "true" ]] || [[ -n "${IMPORTANT_FILES_AFFECTED}" ]]; then
    IMPORTANCE="high"
fi

# Build detailed context for memory
BACKGROUND_CONTEXT="Commit ${COMMIT_HASH} on branch ${COMMIT_BRANCH}. Type: ${COMMIT_TYPE}. Files changed: ${FILES_COUNT}. Additions: ${ADDITIONS}, Deletions: ${DELETIONS}. Important files: ${IMPORTANT_FILES_AFFECTED}. Breaking change: ${BREAKING_CHANGE}. Author: ${COMMIT_AUTHOR}. Date: ${COMMIT_DATE}. Session: ${SESSION_ID}. This is commit #${COMMITS_COUNT} in this session."

# Output JSON with additionalContext
cat <<EOF
{
  "additionalContext": "💾 ${COMMIT_SUMMARY}. Store this commit in memory using memory__record with importance: ${IMPORTANCE}, background: '${BACKGROUND_CONTEXT}'",
  "continue": true
}
EOF

exit 0
