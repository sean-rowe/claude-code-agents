#!/bin/bash
#
# State Migration Script
# Migrates .pipeline/state.json between major versions
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Error codes
readonly E_SUCCESS=0
readonly E_INVALID_ARGS=1
readonly E_MISSING_DEPENDENCY=2
readonly E_FILE_NOT_FOUND=3
readonly E_BACKUP_FAILED=4
readonly E_MIGRATION_FAILED=5

STATE_FILE="${1:-.pipeline/state.json}"
BACKUP_DIR=".pipeline/backups"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Pipeline State Migration Tool                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check dependencies
if ! command -v jq &>/dev/null; then
  echo -e "${RED}✗ Error: jq is required but not installed${NC}"
  echo "  Install: brew install jq (macOS) or apt-get install jq (Ubuntu)"
  exit $E_MISSING_DEPENDENCY
fi

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
  echo -e "${RED}✗ Error: State file not found: $STATE_FILE${NC}"
  echo "  Run: pipeline.sh init"
  exit $E_FILE_NOT_FOUND
fi

# Read current state version
CURRENT_VERSION=$(jq -r '.version // "0.0.0"' "$STATE_FILE" 2>/dev/null || echo "0.0.0")
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)

# Get pipeline version
PIPELINE_VERSION="1.0.0"
if [ -f "pipeline.sh" ]; then
  PIPELINE_VERSION=$(grep -oP '^readonly VERSION="\K[^"]+' pipeline.sh 2>/dev/null || echo "1.0.0")
fi
PIPELINE_MAJOR=$(echo "$PIPELINE_VERSION" | cut -d. -f1)

echo -e "${BLUE}Current State Version:${NC} v$CURRENT_VERSION"
echo -e "${BLUE}Pipeline Version:${NC} v$PIPELINE_VERSION"
echo ""

# Check if migration is needed
if [ "$CURRENT_MAJOR" = "$PIPELINE_MAJOR" ]; then
  echo -e "${GREEN}✓ No migration needed${NC}"
  echo "  State version v$CURRENT_VERSION is compatible with pipeline v$PIPELINE_VERSION"
  exit $E_SUCCESS
fi

# Create backup
echo -e "${YELLOW}Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/state-v${CURRENT_VERSION}-$(date +%Y%m%d-%H%M%S).json"

if ! cp "$STATE_FILE" "$BACKUP_FILE"; then
  echo -e "${RED}✗ Failed to create backup${NC}"
  exit $E_BACKUP_FAILED
fi
echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
echo ""

# Perform migration based on version
echo -e "${YELLOW}Migrating from v$CURRENT_VERSION to v$PIPELINE_VERSION...${NC}"
echo ""

case "$CURRENT_MAJOR" in
  0)
    # Migration from v0.x to v1.x
    echo "Migration: v0.x → v1.x"

    # Read current state
    STAGE=$(jq -r '.stage // "init"' "$STATE_FILE")
    EPIC_ID=$(jq -r '.epicId // ""' "$STATE_FILE")
    CURRENT_STORY=$(jq -r '.currentStory // ""' "$STATE_FILE")
    BRANCH=$(jq -r '.branch // ""' "$STATE_FILE")
    STORIES=$(jq -r '.stories // []' "$STATE_FILE")
    CREATED_AT=$(jq -r '.createdAt // ""' "$STATE_FILE")

    # Create new v1.0 state structure
    cat > "$STATE_FILE" <<EOF
{
  "stage": "$STAGE",
  "epicId": ${EPIC_ID:+\"$EPIC_ID\"},
  "currentStory": ${CURRENT_STORY:+\"$CURRENT_STORY\"},
  "branch": ${BRANCH:+\"$BRANCH\"},
  "stories": $STORIES,
  "createdAt": "${CREATED_AT:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}",
  "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "$PIPELINE_VERSION"
}
EOF

    # Validate JSON
    if ! jq '.' "$STATE_FILE" >/dev/null 2>&1; then
      echo -e "${RED}✗ Migration failed - invalid JSON generated${NC}"
      echo "  Restoring from backup..."
      cp "$BACKUP_FILE" "$STATE_FILE"
      exit $E_MIGRATION_FAILED
    fi

    echo -e "${GREEN}✓ Migration complete${NC}"
    echo "  • Added 'version' field: $PIPELINE_VERSION"
    echo "  • Added 'updatedAt' field"
    echo "  • Preserved all existing data"
    ;;

  *)
    echo -e "${RED}✗ Error: Unsupported migration path${NC}"
    echo "  Cannot migrate from v$CURRENT_VERSION to v$PIPELINE_VERSION"
    echo ""
    echo "Options:"
    echo "  1. Start fresh: rm -rf .pipeline && pipeline.sh init"
    echo "  2. Restore backup: cp $BACKUP_FILE $STATE_FILE"
    echo "  3. Downgrade pipeline: git checkout v$CURRENT_VERSION"
    exit $E_MIGRATION_FAILED
    ;;
esac

# Verify migrated state
echo ""
echo -e "${BLUE}Verifying migrated state...${NC}"

if jq -e '.version' "$STATE_FILE" >/dev/null 2>&1; then
  NEW_VERSION=$(jq -r '.version' "$STATE_FILE")
  echo -e "${GREEN}✓ State version: v$NEW_VERSION${NC}"
else
  echo -e "${RED}✗ Verification failed - missing version field${NC}"
  exit $E_MIGRATION_FAILED
fi

if jq -e '.stage' "$STATE_FILE" >/dev/null 2>&1; then
  STAGE=$(jq -r '.stage' "$STATE_FILE")
  echo -e "${GREEN}✓ Pipeline stage: $STAGE${NC}"
else
  echo -e "${RED}✗ Verification failed - missing stage field${NC}"
  exit $E_MIGRATION_FAILED
fi

if jq -e '.stories' "$STATE_FILE" >/dev/null 2>&1; then
  STORY_COUNT=$(jq -r '.stories | length' "$STATE_FILE")
  echo -e "${GREEN}✓ Stories preserved: $STORY_COUNT${NC}"
else
  echo -e "${RED}✗ Verification failed - missing stories field${NC}"
  exit $E_MIGRATION_FAILED
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Successful!                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Summary:"
echo "  Old version: v$CURRENT_VERSION"
echo "  New version: v$NEW_VERSION"
echo "  Backup: $BACKUP_FILE"
echo ""
echo "Next steps:"
echo "  1. Verify your pipeline works: pipeline.sh status"
echo "  2. If issues occur, restore backup:"
echo "     cp $BACKUP_FILE $STATE_FILE"
echo ""

exit $E_SUCCESS
