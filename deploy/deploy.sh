#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# iME Weather — VPS Deploy Script
# Usage: bash deploy/deploy.sh
#
# Prerequisites on VPS:
#   - Docker Engine + docker-compose plugin installed
#   - Git installed
#   - SSH access configured
#
# Edit the variables below before running.
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
VPS_USER="YOUR_SSH_USER"           # e.g. ubuntu, root
VPS_HOST="YOUR_VPS_IP"            # e.g. 185.123.45.67
VPS_PORT="22"                      # SSH port (default 22)
REMOTE_DIR="/opt/ime-weather"      # Deployment directory on VPS
GIT_REPO="https://github.com/YOUR_USER/YOUR_REPO.git"  # or use local rsync

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "${GREEN}[DEPLOY]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Pre-flight checks ──────────────────────────────────────────────────────────
log "Running pre-flight checks…"
command -v ssh  >/dev/null 2>&1 || error "ssh not found on local machine"
command -v rsync >/dev/null 2>&1 || warn "rsync not found — falling back to git pull"

# ── Upload / sync backend ──────────────────────────────────────────────────────
log "Syncing backend to ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}…"

# Option A: rsync (recommended for iterative dev)
if command -v rsync >/dev/null 2>&1; then
  rsync -avz --delete \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.env' \
    -e "ssh -p ${VPS_PORT}" \
    ./backend/ \
    "${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/backend/"
else
  # Option B: git pull on server (requires repo access)
  ssh -p "${VPS_PORT}" "${VPS_USER}@${VPS_HOST}" bash <<-ENDSSH
    set -e
    if [ ! -d "${REMOTE_DIR}/.git" ]; then
      git clone "${GIT_REPO}" "${REMOTE_DIR}"
    fi
    cd "${REMOTE_DIR}"
    git pull --ff-only
ENDSSH
fi

# ── Deploy on VPS ─────────────────────────────────────────────────────────────
log "Deploying on VPS…"
ssh -p "${VPS_PORT}" "${VPS_USER}@${VPS_HOST}" bash <<-ENDSSH
  set -euo pipefail

  cd "${REMOTE_DIR}/backend"

  # Copy env file if it doesn't exist
  if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example — please review it"
  fi

  echo "→ Pulling latest images / rebuilding…"
  docker compose pull --quiet 2>/dev/null || true
  docker compose build --no-cache

  echo "→ Stopping old containers…"
  docker compose down --remove-orphans

  echo "→ Starting new containers…"
  docker compose up -d

  echo "→ Waiting for health check…"
  sleep 8
  HEALTH=\$(curl -sf http://127.0.0.1:3000/api/health || echo "FAIL")
  if echo "\$HEALTH" | grep -q '"status":"ok"'; then
    echo "✅ Health check passed: \$HEALTH"
  else
    echo "❌ Health check FAILED: \$HEALTH"
    docker compose logs --tail=50
    exit 1
  fi
ENDSSH

log "✅ Deployment complete!"
log "Backend is available at: http://${VPS_HOST}:3000"
log "Test it: curl http://${VPS_HOST}:3000/api/health"
log "         curl 'http://${VPS_HOST}:3000/api/weather?city=ashgabat'"
