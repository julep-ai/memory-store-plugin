#!/bin/bash
# Queue memory for later processing by Claude
# This bypasses the additionalContext visibility issue

set -euo pipefail

# Queue file location
QUEUE_FILE="${CLAUDE_PROJECT_DIR:-.}/.memory-queue.jsonl"

# JSON escape function
json_escape() {
    printf '%s' "$1" | \
        sed 's/\\/\\\\/g' | \
        sed 's/"/\\"/g' | \
        sed ':a;N;$!ba;s/\n/\\n/g' | \
        sed 's/\t/\\t/g' | \
        sed 's/\r/\\r/g'
}

# Parse arguments
MEMORY=""
BACKGROUND=""
IMPORTANCE="normal"

while [[ $# -gt 0 ]]; do
    case $1 in
        --memory)
            MEMORY="$2"
            shift 2
            ;;
        --background)
            BACKGROUND="$2"
            shift 2
            ;;
        --importance)
            IMPORTANCE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -z "${MEMORY}" ]]; then
    echo "Error: --memory required" >&2
    exit 1
fi

# Escape for JSON
MEMORY_ESC=$(json_escape "${MEMORY}")
BACKGROUND_ESC=$(json_escape "${BACKGROUND}")
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Append to queue
cat >> "${QUEUE_FILE}" <<EOF
{"memory":"${MEMORY_ESC}","background":"${BACKGROUND_ESC}","importance":"${IMPORTANCE}","queued_at":"${TIMESTAMP}"}
EOF

exit 0
