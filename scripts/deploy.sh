#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}🚀 Starting deployment process...${NC}"
echo "================================================"
echo ""

echo -e "${BLUE}📥 Getting latest code from git${NC}"
git pull origin main
echo ""

echo -e "${PURPLE}🔨 Building Docker images${NC}"
(cd .. && npm run prod:build)
echo ""

echo -e "${YELLOW}🔗 Starting port forwarding to database${NC}"
DATABASE_SSH_PID=$(./database-session.sh --pid)
echo -e "${GREEN}✅ Database SSH tunnel started with PID: $DATABASE_SSH_PID${NC}"
echo ""

# Function to cleanup SSH tunnel
cleanup() {
    if [[ -n "$DATABASE_SSH_PID" ]]; then
        echo ""
        echo -e "${YELLOW}🔌 Stopping database SSH tunnel (PID: $DATABASE_SSH_PID)${NC}"
        kill "$DATABASE_SSH_PID" 2>/dev/null || true
    fi
}

# Set trap to cleanup on script exit (success or failure)
trap cleanup EXIT

# Wait a moment for the SSH tunnel to establish
echo -e "${CYAN}⏳ Waiting for SSH tunnel to establish...${NC}"
sleep 5
echo ""

echo -e "${BLUE}🗃️  Running migration on database${NC}"
(cd ../backend && npm run prod:db-init)
echo ""

echo -e "${PURPLE}🖥️  Running backend container${NC}"
./instance-session.sh -b "cd saas-dms && docker-compose down backend && docker-compose pull backend && docker image prune -f && NODE_ENV=production RESTART_POLICY=always docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d backend && exit"
echo ""

echo -e "${BLUE}🌐 Building frontend${NC}"
(cd ../frontend && npm run prod)
echo ""

echo "================================================"
echo -e "${GREEN}🎉 Deployment complete!"