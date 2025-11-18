#!/bin/bash
# Analyze Ownership - Track who owns what code based on commit patterns
# Fires after git commits to build ownership map

set -euo pipefail

# Read and discard stdin (hook protocol requirement)
if [ ! -t 0 ]; then
    cat > /dev/null
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"

# Only run if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo '{"continue": true}'
  exit 0
fi

# Get commit info
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_AUTHOR=$(git log -1 --format='%an' 2>/dev/null || echo "unknown")
COMMIT_EMAIL=$(git log -1 --format='%ae' 2>/dev/null || echo "unknown")
COMMIT_MESSAGE=$(git log -1 --format='%s' 2>/dev/null || echo "unknown")
COMMIT_TIME=$(git log -1 --format='%cd' --date=iso 2>/dev/null || echo "unknown")

# Get files changed in this commit
FILES_CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | tr '\n' '; ' || echo "")

# Analyze commit type (feat, fix, docs, etc.)
COMMIT_TYPE="unknown"
if [[ "${COMMIT_MESSAGE}" =~ ^feat:  ]]; then COMMIT_TYPE="feature"
elif [[ "${COMMIT_MESSAGE}" =~ ^fix:  ]]; then COMMIT_TYPE="bugfix"
elif [[ "${COMMIT_MESSAGE}" =~ ^docs:  ]]; then COMMIT_TYPE="documentation"
elif [[ "${COMMIT_MESSAGE}" =~ ^refactor:  ]]; then COMMIT_TYPE="refactor"
elif [[ "${COMMIT_MESSAGE}" =~ ^test:  ]]; then COMMIT_TYPE="test"
elif [[ "${COMMIT_MESSAGE}" =~ ^chore:  ]]; then COMMIT_TYPE="chore"
fi

# Count files by directory to identify area of work
AREA="general"
if [[ "${FILES_CHANGED}" =~ src/api/ ]] || [[ "${FILES_CHANGED}" =~ /api/ ]]; then
  AREA="backend-api"
elif [[ "${FILES_CHANGED}" =~ src/components/ ]] || [[ "${FILES_CHANGED}" =~ /frontend/ ]]; then
  AREA="frontend"
elif [[ "${FILES_CHANGED}" =~ test/ ]] || [[ "${FILES_CHANGED}" =~ spec/ ]]; then
  AREA="testing"
elif [[ "${FILES_CHANGED}" =~ docs/ ]] || [[ "${FILES_CHANGED}" =~ .md$ ]]; then
  AREA="documentation"
elif [[ "${FILES_CHANGED}" =~ scripts/ ]] || [[ "${FILES_CHANGED}" =~ bin/ ]]; then
  AREA="tooling"
fi

# Record ownership pattern (async)
{
  MEMORY_TEXT="Commit ${COMMIT_HASH} by ${COMMIT_AUTHOR} (${COMMIT_EMAIL}): ${COMMIT_TYPE} in ${AREA}. Files: ${FILES_CHANGED}. Message: ${COMMIT_MESSAGE}"

  BACKGROUND_TEXT="Ownership tracking for project ${PROJECT_DIR}. Author: ${COMMIT_AUTHOR}. Area: ${AREA}. Type: ${COMMIT_TYPE}. Time: ${COMMIT_TIME}. This builds knowledge of who owns which parts of the codebase."

  claude mcp call memory-store record \
    --memory "${MEMORY_TEXT}" \
    --background "${BACKGROUND_TEXT}" \
    --importance "normal" &
} 2>/dev/null

# For significant commits (feat/fix), track with higher importance
if [[ "${COMMIT_TYPE}" == "feature" ]] || [[ "${COMMIT_TYPE}" == "bugfix" ]]; then
  {
    MEMORY_TEXT="Significant commit: ${COMMIT_AUTHOR} added ${COMMIT_TYPE} in ${AREA}. This establishes ${COMMIT_AUTHOR} as knowledgeable about ${AREA}."

    BACKGROUND_TEXT="Expertise tracking. ${COMMIT_AUTHOR} demonstrates expertise in ${AREA} through ${COMMIT_TYPE} work."

    claude mcp call memory-store record \
      --memory "${MEMORY_TEXT}" \
      --background "${BACKGROUND_TEXT}" \
      --importance "high" &
  } 2>/dev/null
fi

# Non-blocking continuation
echo '{"continue": true}'
exit 0
