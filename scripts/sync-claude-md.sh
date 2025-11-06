#!/bin/bash
# Sync CLAUDE.md Hook - Synchronize CLAUDE.md files and anchor comments
# This script tracks and syncs CLAUDE.md files across the project

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
SPECIFIC_FILE="${1:-}"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Syncing CLAUDE.md files..."

# Find all CLAUDE.md files in project
if [[ -n "${SPECIFIC_FILE}" ]]; then
    CLAUDE_MD_FILES="${SPECIFIC_FILE}"
else
    CLAUDE_MD_FILES=$(find "${PROJECT_DIR}" -type f \( -name "CLAUDE.md" -o -name "claude.md" \) 2>/dev/null || echo "")
fi

if [[ -z "${CLAUDE_MD_FILES}" ]]; then
    log "No CLAUDE.md files found"
    exit 0
fi

TOTAL_FILES=$(echo "${CLAUDE_MD_FILES}" | wc -l | tr -d ' ')
log "Found ${TOTAL_FILES} CLAUDE.md file(s)"

# Process each CLAUDE.md file
while IFS= read -r CLAUDE_FILE; do
    if [[ -z "${CLAUDE_FILE}" ]]; then
        continue
    fi
    
    REL_PATH=$(realpath --relative-to="${PROJECT_DIR}" "${CLAUDE_FILE}" 2>/dev/null || echo "${CLAUDE_FILE}")
    log "Processing: ${REL_PATH}"
    
    # Extract anchor comments from CLAUDE.md
    ANCHORS=$(grep -oE '<!--\s*[A-Z0-9_-]+\s*-->' "${CLAUDE_FILE}" 2>/dev/null || echo "")
    ANCHOR_COUNT=$(echo "${ANCHORS}" | grep -c . || echo "0")
    
    log "  Found ${ANCHOR_COUNT} anchor comment(s)"
    
    # Parse sections from CLAUDE.md
    # Look for common section headers
    SECTIONS=$(grep -E '^#+\s+' "${CLAUDE_FILE}" 2>/dev/null | sed 's/^#+\s*//' || echo "")
    
    # Extract key information
    # 1. Project guidelines
    if grep -qiE '(guideline|convention|standard|pattern)' "${CLAUDE_FILE}"; then
        CONTAINS_GUIDELINES="true"
    else
        CONTAINS_GUIDELINES="false"
    fi
    
    # 2. Architecture documentation
    if grep -qiE '(architecture|structure|design|component)' "${CLAUDE_FILE}"; then
        CONTAINS_ARCHITECTURE="true"
    else
        CONTAINS_ARCHITECTURE="false"
    fi
    
    # 3. Business logic
    if grep -qiE '(business|workflow|process|logic)' "${CLAUDE_FILE}"; then
        CONTAINS_BUSINESS_LOGIC="true"
    else
        CONTAINS_BUSINESS_LOGIC="false"
    fi
    
    # Get last modified time
    if [[ -f "${CLAUDE_FILE}" ]]; then
        LAST_MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "${CLAUDE_FILE}" 2>/dev/null || stat -c "%y" "${CLAUDE_FILE}" 2>/dev/null || echo "unknown")
    else
        LAST_MODIFIED="unknown"
    fi
    
    # Get file size
    FILE_SIZE=$(wc -c < "${CLAUDE_FILE}" 2>/dev/null | tr -d ' ' || echo "0")
    LINE_COUNT=$(wc -l < "${CLAUDE_FILE}" 2>/dev/null | tr -d ' ' || echo "0")
    
    # Check git history for this file
    if git ls-files --error-unmatch "${CLAUDE_FILE}" > /dev/null 2>&1; then
        COMMIT_COUNT=$(git log --oneline "${CLAUDE_FILE}" 2>/dev/null | wc -l | tr -d ' ')
        LAST_COMMIT_MSG=$(git log -1 --pretty=format:"%s" "${CLAUDE_FILE}" 2>/dev/null || echo "")
        LAST_COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an" "${CLAUDE_FILE}" 2>/dev/null || echo "")
    else
        COMMIT_COUNT="0"
        LAST_COMMIT_MSG="Not committed"
        LAST_COMMIT_AUTHOR="unknown"
    fi
    
    # Build anchor index
    ANCHOR_LIST=""
    if [[ "${ANCHOR_COUNT}" -gt 0 ]]; then
        # Find files that reference these anchors
        while IFS= read -r ANCHOR; do
            if [[ -z "${ANCHOR}" ]]; then
                continue
            fi
            
            CLEAN_ANCHOR=$(echo "${ANCHOR}" | sed 's/[<>!-]//g' | tr -d ' ')
            
            # Search for references to this anchor in other files
            REFERENCES=$(grep -r "${ANCHOR}" "${PROJECT_DIR}" --exclude="*.md" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
            
            if [[ "${REFERENCES}" -gt 0 ]]; then
                ANCHOR_LIST="${ANCHOR_LIST}${CLEAN_ANCHOR} (${REFERENCES} refs), "
            else
                ANCHOR_LIST="${ANCHOR_LIST}${CLEAN_ANCHOR}, "
            fi
        done <<< "${ANCHORS}"
        
        ANCHOR_LIST=$(echo "${ANCHOR_LIST}" | sed 's/, $//')
    fi
    
    # Prepare memory record for this CLAUDE.md file
    MEMORY_TEXT="CLAUDE.md file: ${REL_PATH} with ${ANCHOR_COUNT} anchor comments"
    
    MEMORY_BACKGROUND=$(cat <<EOF
CLAUDE.md file at ${REL_PATH}
Size: ${FILE_SIZE} bytes, ${LINE_COUNT} lines
Last modified: ${LAST_MODIFIED}
Git commits: ${COMMIT_COUNT}
Last commit: ${LAST_COMMIT_MSG} by ${LAST_COMMIT_AUTHOR}
Contains guidelines: ${CONTAINS_GUIDELINES}
Contains architecture: ${CONTAINS_ARCHITECTURE}
Contains business logic: ${CONTAINS_BUSINESS_LOGIC}
Anchors: ${ANCHOR_LIST}
Sections: ${SECTIONS}
Session: ${SESSION_ID}
EOF
)
    
    MEMORY_PAYLOAD=$(cat <<EOF
{
  "memory": "${MEMORY_TEXT}",
  "background": "${MEMORY_BACKGROUND}",
  "importance": "high"
}
EOF
)
    
    log "  Synced: ${REL_PATH} (${ANCHOR_COUNT} anchors, ${LINE_COUNT} lines)"
    
done <<< "${CLAUDE_MD_FILES}"

log "CLAUDE.md sync complete"

exit 0
