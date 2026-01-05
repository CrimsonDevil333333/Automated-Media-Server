#!/bin/bash

# --- CONFIGURATION ---
VPN_CONTAINER="gluetun"
REQUESTS_CONTAINER="jellyseerr"

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}--- 🛡️ MEDIA SERVER HEALTH CHECK (LINUX/MAC) ---${NC}"

# 1. Check if containers are running
containers=("gluetun" "jellyfin" "jellyseerr" "radarr" "sonarr" "prowlarr" "flaresolverr" "qbittorrent")
for c in "${containers[@]}"; do
    status=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)
    if [ "$status" == "true" ]; then
        echo -e "${GREEN}[OK]${NC} $c is running."
    else
        echo -e "${RED}[!!]${NC} $c is NOT running."
    fi
done

echo -e "\n${CYAN}--- 🌐 NETWORK PRIVACY CHECK ---${NC}"

# 2. Check VPN IP vs Local IP
vpnIp=$(docker exec $VPN_CONTAINER wget -qO- https://api.ipify.org 2>/dev/null)
if [ -n "$vpnIp" ]; then
    echo -e "${YELLOW}[VPN]${NC} Current VPN IP: $vpnIp"
else
    echo -e "${RED}[ERROR]${NC} Could not retrieve VPN IP. Check Gluetun logs."
fi

# 3. Check Inter-Container Connectivity
echo -e "\n${CYAN}--- 🔗 INTER-CONTAINER ROUTING ---${NC}"

# Test: Jellyseerr -> Radarr (via Gluetun)
# We use 'docker exec' to try a network connection from within Jellyseerr
if docker exec $REQUESTS_CONTAINER sh -c "cat < /dev/null > /dev/tcp/gluetun/7878" 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS]${NC} Jellyseerr can reach Radarr via 'gluetun:7878'"
else
    echo -e "${RED}[FAILURE]${NC} Jellyseerr cannot reach Radarr! Check if Radarr is in Gluetun's network."
fi

# Test: Jellyseerr -> Jellyfin (Direct Bridge)
if docker exec $REQUESTS_CONTAINER sh -c "cat < /dev/null > /dev/tcp/jellyfin/8096" 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS]${NC} Jellyseerr can reach Jellyfin via 'jellyfin:8096'"
else
    echo -e "${RED}[FAILURE]${NC} Jellyseerr cannot reach Jellyfin! Use container name 'jellyfin' in settings."
fi

# Test: Prowlarr -> FlareSolverr (Internal VPN Loopback)
if docker exec $VPN_CONTAINER wget -q --spider http://127.0.0.1:8191 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS]${NC} Prowlarr can reach FlareSolverr at 127.0.0.1:8191"
else
    echo -e "${RED}[FAILURE]${NC} FlareSolverr unreachable inside the VPN tunnel!"
fi

echo -e "\n${CYAN}--- ✅ CHECK COMPLETE ---${NC}\n"