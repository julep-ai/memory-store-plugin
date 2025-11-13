#!/bin/bash
# Analyze Anchors - Automatic anchor comment tracking and analysis
# Fires after Write/Edit operations to detect anchor usage

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
FILE_PATH="${CLAUDE_TOOL_RESULT_PATH:-unknown}"

# Only process if file was actually written/edited
if [[ "${FILE_PATH}" == "unknown" ]] || [[ ! -f "${FILE_PATH}" ]]; then
  echo '{"continue": true}'
  exit 0
fi

# Check if file contains CLAUDE.md or anchor comments
HAS_ANCHORS=false
ANCHOR_COUNT=0
ANCHORS_FOUND=""

if [[ -f "${FILE_PATH}" ]]; then
  # Detect anchor comments: <!-- ANCHOR-NAME -->
  if grep -q '<!--.*-->' "${FILE_PATH}" 2>/dev/null; then
    HAS_ANCHORS=true
    ANCHOR_COUNT=$(grep -o '<!--[^>]*-->' "${FILE_PATH}" 2>/dev/null | wc -l | tr -d ' ')
    ANCHORS_FOUND=$(grep -o '<!--[^>]*-->' "${FILE_PATH}" 2>/dev/null | head -5 | tr '\n' '; ')
  fi
fi

# If anchors detected, analyze and record (async)
if [[ "${HAS_ANCHORS}" == "true" ]] && [[ ${ANCHOR_COUNT} -gt 0 ]]; then
  {
    # Prepare memory record
    MEMORY_TEXT="Anchor comments detected in ${FILE_PATH}: ${ANCHOR_COUNT} anchors found (${ANCHORS_FOUND}). Anchors help cross-reference documentation and code."
    BACKGROUND_TEXT="Anchor tracking in project ${PROJECT_DIR}. File: ${FILE_PATH}. Count: ${ANCHOR_COUNT}."

    # Record to memory store (async, non-blocking)
    claude mcp call memory-store record \
      --memory "${MEMORY_TEXT}" \
      --background "${BACKGROUND_TEXT}" \
      --importance "normal" &
  } 2>/dev/null
fi

# Check for anchor references in code files (<!-- ANCHOR --> references)
if [[ "${FILE_PATH}" =~ \.(ts|js|tsx|jsx|py|go|rs|java)$ ]]; then
  # Detect comment references to anchors
  if grep -q 'See.*<!--.*-->' "${FILE_PATH}" 2>/dev/null || \
     grep -q 'Ref:.*<!--.*-->' "${FILE_PATH}" 2>/dev/null; then
    {
      REFERENCES=$(grep -o 'See.*<!--[^>]*-->' "${FILE_PATH}" 2>/dev/null | head -3 | tr '\n' '; ')

      MEMORY_TEXT="Code references anchor comments in ${FILE_PATH}: ${REFERENCES}. This creates cross-references between code and documentation."
      BACKGROUND_TEXT="Anchor reference tracking. File: ${FILE_PATH}. References maintain documentation links."

      claude mcp call memory-store record \
        --memory "${MEMORY_TEXT}" \
        --background "${BACKGROUND_TEXT}" \
        --importance "normal" &
    } 2>/dev/null
  fi
fi

# Non-blocking continuation
echo '{"continue": true}'
exit 0
