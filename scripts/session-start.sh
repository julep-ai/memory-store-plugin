#!/bin/bash
# Session Start Hook - Initialize session tracking and load context
# This script runs at the beginning of each Claude Code session

set -euo pipefail

# Get project directory (working directory when Claude Code starts)
PROJECT_DIR="${PWD}"
SESSION_ID="mem-$(date +%Y-%m-%d)-$(uuidgen | cut -d'-' -f1)"
SESSION_FILE="${TMPDIR:-/tmp}/claude-memory-session-${SESSION_ID}.json"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Session starting: ${SESSION_ID}"

# Initialize session metadata
cat > "${SESSION_FILE}" <<EOF
{
  "session_id": "${SESSION_ID}",
  "project_dir": "${PROJECT_DIR}",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files_tracked": [],
  "commits_analyzed": [],
  "context_stored": 0
}
EOF

# Export session ID for other scripts
export CLAUDE_MEMORY_SESSION_ID="${SESSION_ID}"
export CLAUDE_MEMORY_SESSION_FILE="${SESSION_FILE}"

# Get project name from directory
PROJECT_NAME=$(basename "${PROJECT_DIR}")

# Record session start in memory store using MCP
# Note: This would typically call the memory MCP server tools
# For now, we'll prepare the data structure

log "Capturing project state..."

# Get git info if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")
    
    log "Git branch: ${GIT_BRANCH}"
    log "Git commit: ${GIT_COMMIT}"
else
    GIT_BRANCH="not-a-git-repo"
    GIT_COMMIT="none"
    RECENT_COMMITS=""
fi

# Find CLAUDE.md files
CLAUDE_MD_FILES=$(find "${PROJECT_DIR}" -name "CLAUDE.md" -o -name "claude.md" 2>/dev/null || echo "")
CLAUDE_MD_COUNT=$(echo "${CLAUDE_MD_FILES}" | grep -c . || echo "0")

log "Found ${CLAUDE_MD_COUNT} CLAUDE.md file(s)"

# Count files in project
FILE_COUNT=$(find "${PROJECT_DIR}" -type f 2>/dev/null | wc -l | tr -d ' ')

# Prepare memory record payload
MEMORY_PAYLOAD=$(cat <<EOF
{
  "memory": "Development session started in project ${PROJECT_NAME} on branch ${GIT_BRANCH}",
  "background": "Session ${SESSION_ID} initialized. Project has ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files. Current commit: ${GIT_COMMIT}. Working directory: ${PROJECT_DIR}",
  "importance": "normal"
}
EOF
)

log "Session initialized. Ready to track development."
log "Session file: ${SESSION_FILE}"

# Load relevant context from memory store silently
# This queries memory_recall for recent work in this project
log "Loading relevant context from memory store..."

# Prepare context retrieval cues based on current project state
CONTEXT_CUES=$(cat <<EOF
["${PROJECT_NAME}", "${GIT_BRANCH}", "project patterns", "recent decisions", "team conventions"]
EOF
)

CONTEXT_BACKGROUND="Retrieving context for project ${PROJECT_NAME} on branch ${GIT_BRANCH}. Session ${SESSION_ID} starting. Recent work and patterns needed for contextual awareness."

# Silently retrieve context in background (output suppressed)
# This makes context available to Claude without showing it to the user
{
    # Check if MCP server is configured
    if [ -f "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" ]; then
        # Extract token from plugin.json if available
        MEMORY_TOKEN=$(grep -o 'token=[^"]*' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" 2>/dev/null | cut -d'=' -f2 || echo "")

        if [ -n "${MEMORY_TOKEN}" ]; then
            # Attempt to retrieve context using memory recall
            # Results stored in session file for Claude to access
            CONTEXT_RESULT=$(npx --yes mcp-remote "https://beta.memory.store/mcp/?token=${MEMORY_TOKEN}" << RECALL_EOF 2>/dev/null || echo "{}"
{
  "method": "tools/call",
  "params": {
    "name": "memory__recall",
    "arguments": {
      "cues": ${CONTEXT_CUES},
      "background": "${CONTEXT_BACKGROUND}",
      "k": 10
    }
  }
}
RECALL_EOF
)

            # Update session file with retrieved context
            if [ -n "${CONTEXT_RESULT}" ] && [ "${CONTEXT_RESULT}" != "{}" ]; then
                log "Context retrieved successfully (available for Claude)"
                # Store context in session file
                echo "${CONTEXT_RESULT}" > "${PROJECT_DIR}/.claude-memory-context-${SESSION_ID}.json"
            fi
        fi
    fi
} &>/dev/null &

# Actually store session start in memory using mcp__plugin_memory-store-tracker_memory__record
# This creates a permanent memory of the session
log "Recording session start in memory store..."

# Use Claude Code's MCP tool to record the memory
# This will be available to Claude directly via the tool
cat > "${PROJECT_DIR}/.claude-memory-record-request.json" <<RECORD_EOF
{
  "memory": "Development session started in project ${PROJECT_NAME} on branch ${GIT_BRANCH}",
  "background": "Session ${SESSION_ID} initialized at $(date -u +%Y-%m-%dT%H:%M:%SZ). Project has ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files. Current commit: ${GIT_COMMIT}. Working directory: ${PROJECT_DIR}. Recent commits: ${RECENT_COMMITS}",
  "importance": "normal",
  "start": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
RECORD_EOF

log "Session start recorded. Memory request prepared for Claude."

# Create a marker file to indicate plugin is active
echo "${SESSION_ID}" > "${PROJECT_DIR}/.claude-memory-session"

exit 0
