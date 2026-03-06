#!/bin/bash
# Self-deploy script for NanoClaw
# Called by the IPC deploy handler after the bot pushes config changes.
# Pulls latest, builds, rebuilds container, restarts service, and health-checks.
# On failure, auto-rolls back to the previous commit.
#
# Usage: ./scripts/self-deploy.sh [branch]
# Default branch: main

set -euo pipefail

BRANCH="${1:-main}"
REPO_DIR="/Volumes/SM-EXT/Development/nanoclaw"
LOG_FILE="/tmp/nanoclaw-deploy.log"
HEALTH_TIMEOUT=30  # seconds to wait for healthy startup

log() { echo "[deploy] $(date '+%H:%M:%S') $*" | tee -a "$LOG_FILE"; }

cd "$REPO_DIR"

# Save current commit for rollback
PREV_COMMIT=$(git rev-parse HEAD)
log "Starting self-deploy from branch: $BRANCH (rollback target: ${PREV_COMMIT:0:8})"

# Truncate the log so health check greps fresh output
: > /tmp/nanoclaw.log

# 1. Pull latest changes
log "Pulling latest from origin/$BRANCH..."
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

# 2. Install deps if package-lock changed
if git diff "$PREV_COMMIT" --name-only 2>/dev/null | grep -q 'package-lock.json'; then
  log "package-lock.json changed, running npm install..."
  npm install --production=false
fi

# 3. Build TypeScript
log "Building TypeScript..."
npm run build

# 4. Delete stale agent-runner-src copies (critical!)
log "Clearing stale agent-runner-src copies..."
rm -rf data/sessions/*/agent-runner-src

# 5. Rebuild container image
log "Pruning Docker build cache..."
docker builder prune --all -f >/dev/null 2>&1

log "Rebuilding container image..."
docker build --no-cache -t nanoclaw-agent:latest container/ 2>&1 | tail -3

# 6. Kill running agent containers
RUNNING=$(docker ps -q --filter ancestor=nanoclaw-agent:latest 2>/dev/null || true)
if [ -n "$RUNNING" ]; then
  log "Stopping running agent containers..."
  docker kill $RUNNING >/dev/null 2>&1 || true
fi

# 7. Clear sessions so fresh containers get new config
log "Clearing sessions..."
sqlite3 store/messages.db "DELETE FROM sessions;" 2>/dev/null || true

# 8. Restart NanoClaw service
log "Restarting NanoClaw service..."
launchctl kickstart -k "gui/$(id -u)/com.nanoclaw"

# 9. Health check — wait for the service to start and Discord to connect
log "Waiting for health check (${HEALTH_TIMEOUT}s timeout)..."
STARTED=false
for i in $(seq 1 "$HEALTH_TIMEOUT"); do
  if grep -q "NanoClaw running" /tmp/nanoclaw.log 2>/dev/null; then
    STARTED=true
    break
  fi
  sleep 1
done

if [ "$STARTED" = true ]; then
  log "Deploy successful! NanoClaw is running."
  exit 0
else
  log "DEPLOY FAILED — health check timed out. Rolling back to ${PREV_COMMIT:0:8}..."
  git reset --hard "$PREV_COMMIT"
  npm run build
  rm -rf data/sessions/*/agent-runner-src
  docker builder prune --all -f >/dev/null 2>&1
  docker build --no-cache -t nanoclaw-agent:latest container/ 2>&1 | tail -3
  docker kill $(docker ps -q --filter ancestor=nanoclaw-agent:latest 2>/dev/null) 2>/dev/null || true
  sqlite3 store/messages.db "DELETE FROM sessions;" 2>/dev/null || true
  launchctl kickstart -k "gui/$(id -u)/com.nanoclaw"
  log "Rollback complete. Reverted to ${PREV_COMMIT:0:8}."
  exit 1
fi
