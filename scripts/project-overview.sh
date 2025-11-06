#!/bin/bash
# Project Overview Script - Generate comprehensive project analysis
# This script performs deep analysis and stores it in memory

set -euo pipefail

PROJECT_DIR="${PWD}"
PROJECT_NAME=$(basename "${PROJECT_DIR}")

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Generating project overview for ${PROJECT_NAME}..."

# Initialize overview data
OVERVIEW_FILE="${TMPDIR:-/tmp}/claude-memory-overview-${PROJECT_NAME}.json"

# 1. Analyze project structure
log "Analyzing project structure..."

TOTAL_FILES=$(find "${PROJECT_DIR}" -type f 2>/dev/null | wc -l | tr -d ' ')
TOTAL_DIRS=$(find "${PROJECT_DIR}" -type d 2>/dev/null | wc -l | tr -d ' ')

# Count files by type
TS_FILES=$(find "${PROJECT_DIR}" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
JS_FILES=$(find "${PROJECT_DIR}" -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l | tr -d ' ')
PY_FILES=$(find "${PROJECT_DIR}" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
GO_FILES=$(find "${PROJECT_DIR}" -name "*.go" 2>/dev/null | wc -l | tr -d ' ')
TEST_FILES=$(find "${PROJECT_DIR}" -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | wc -l | tr -d ' ')

# Detect primary language
if [[ "${TS_FILES}" -gt "${JS_FILES}" ]] && [[ "${TS_FILES}" -gt "${PY_FILES}" ]]; then
    PRIMARY_LANG="TypeScript"
elif [[ "${JS_FILES}" -gt "${PY_FILES}" ]]; then
    PRIMARY_LANG="JavaScript"
elif [[ "${PY_FILES}" -gt 0 ]]; then
    PRIMARY_LANG="Python"
elif [[ "${GO_FILES}" -gt 0 ]]; then
    PRIMARY_LANG="Go"
else
    PRIMARY_LANG="Unknown"
fi

# 2. Analyze git repository
log "Analyzing git history..."

if git rev-parse --git-dir > /dev/null 2>&1; then
    TOTAL_COMMITS=$(git rev-list --all --count 2>/dev/null || echo "0")
    CONTRIBUTORS=$(git log --format='%an' | sort -u | wc -l | tr -d ' ')
    BRANCHES=$(git branch -a | wc -l | tr -d ' ')
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    # Analyze commit patterns
    FEATURE_BRANCHES=$(git branch -a | grep -c "feature/" || echo "0")
    BUGFIX_BRANCHES=$(git branch -a | grep -c "bugfix/" || echo "0")
    
    # Recent activity
    COMMITS_LAST_WEEK=$(git log --since="1 week ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
    COMMITS_LAST_MONTH=$(git log --since="1 month ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
    
    # Get first commit date
    FIRST_COMMIT_DATE=$(git log --reverse --format="%ci" | head -1 || echo "unknown")
    
    IS_GIT_REPO="true"
else
    TOTAL_COMMITS="0"
    CONTRIBUTORS="0"
    BRANCHES="0"
    CURRENT_BRANCH="not-a-git-repo"
    FEATURE_BRANCHES="0"
    BUGFIX_BRANCHES="0"
    COMMITS_LAST_WEEK="0"
    COMMITS_LAST_MONTH="0"
    FIRST_COMMIT_DATE="unknown"
    IS_GIT_REPO="false"
fi

# 3. Detect frameworks and tools
log "Detecting frameworks and tools..."

FRAMEWORKS=""
TOOLS=""

if [[ -f "${PROJECT_DIR}/package.json" ]]; then
    TOOLS="${TOOLS}npm/node "
    
    # Detect React
    if grep -q "\"react\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
        FRAMEWORKS="${FRAMEWORKS}React "
    fi
    
    # Detect Next.js
    if grep -q "\"next\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
        FRAMEWORKS="${FRAMEWORKS}Next.js "
    fi
    
    # Detect Express
    if grep -q "\"express\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
        FRAMEWORKS="${FRAMEWORKS}Express "
    fi
    
    # Detect testing frameworks
    if grep -q "\"jest\"" "${PROJECT_DIR}/package.json" 2>/dev/null; then
        TOOLS="${TOOLS}Jest "
    fi
fi

if [[ -f "${PROJECT_DIR}/requirements.txt" ]] || [[ -f "${PROJECT_DIR}/setup.py" ]]; then
    TOOLS="${TOOLS}Python "
fi

if [[ -f "${PROJECT_DIR}/go.mod" ]]; then
    TOOLS="${TOOLS}Go "
fi

if [[ -f "${PROJECT_DIR}/Cargo.toml" ]]; then
    TOOLS="${TOOLS}Rust "
fi

# Detect Docker
if [[ -f "${PROJECT_DIR}/Dockerfile" ]] || [[ -f "${PROJECT_DIR}/docker-compose.yml" ]]; then
    TOOLS="${TOOLS}Docker "
fi

# Detect Kubernetes
if [[ -d "${PROJECT_DIR}/k8s" ]] || [[ -d "${PROJECT_DIR}/kubernetes" ]]; then
    TOOLS="${TOOLS}Kubernetes "
fi

# 4. Find CLAUDE.md files and documentation
log "Analyzing documentation..."

CLAUDE_MD_COUNT=$(find "${PROJECT_DIR}" -name "CLAUDE.md" -o -name "claude.md" 2>/dev/null | wc -l | tr -d ' ')
README_EXISTS="false"
if [[ -f "${PROJECT_DIR}/README.md" ]]; then
    README_EXISTS="true"
fi

DOCS_DIR_EXISTS="false"
if [[ -d "${PROJECT_DIR}/docs" ]]; then
    DOCS_DIR_EXISTS="true"
    DOCS_FILES=$(find "${PROJECT_DIR}/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
else
    DOCS_FILES="0"
fi

# 5. Build project overview summary
PROJECT_OVERVIEW=$(cat <<EOF
{
  "project_name": "${PROJECT_NAME}",
  "project_dir": "${PROJECT_DIR}",
  "structure": {
    "total_files": ${TOTAL_FILES},
    "total_directories": ${TOTAL_DIRS},
    "typescript_files": ${TS_FILES},
    "javascript_files": ${JS_FILES},
    "python_files": ${PY_FILES},
    "test_files": ${TEST_FILES},
    "primary_language": "${PRIMARY_LANG}"
  },
  "git": {
    "is_repo": ${IS_GIT_REPO},
    "total_commits": ${TOTAL_COMMITS},
    "contributors": ${CONTRIBUTORS},
    "branches": ${BRANCHES},
    "current_branch": "${CURRENT_BRANCH}",
    "feature_branches": ${FEATURE_BRANCHES},
    "bugfix_branches": ${BUGFIX_BRANCHES},
    "commits_last_week": ${COMMITS_LAST_WEEK},
    "commits_last_month": ${COMMITS_LAST_MONTH},
    "first_commit": "${FIRST_COMMIT_DATE}"
  },
  "tech_stack": {
    "frameworks": "${FRAMEWORKS}",
    "tools": "${TOOLS}"
  },
  "documentation": {
    "claude_md_files": ${CLAUDE_MD_COUNT},
    "readme_exists": ${README_EXISTS},
    "docs_directory": ${DOCS_DIR_EXISTS},
    "docs_files": ${DOCS_FILES}
  }
}
EOF
)

echo "${PROJECT_OVERVIEW}" > "${OVERVIEW_FILE}"

log "Project overview generated: ${OVERVIEW_FILE}"
log "Summary: ${PRIMARY_LANG} project with ${TOTAL_FILES} files, ${TOTAL_COMMITS} commits, ${CONTRIBUTORS} contributors"

exit 0
