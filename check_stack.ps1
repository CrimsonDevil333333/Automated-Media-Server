# --- CONFIGURATION ---
$VPN_CONTAINER = "gluetun"
$REQUESTS_CONTAINER = "jellyseerr"

Write-Host "`n--- 🛡️ MEDIA SERVER HEALTH CHECK ---" -ForegroundColor Cyan

# 1. Check if containers are running
$containers = "gluetun", "jellyfin", "jellyseerr", "radarr", "sonarr", "prowlarr", "flaresolverr", "qbittorrent"
foreach ($c in $containers) {
    $status = docker inspect -f '{{.State.Running}}' $c 2>$null
    if ($status -eq "true") {
        Write-Host "[OK] $c is running." -ForegroundColor Green
    } else {
        Write-Host "[!!] $c is NOT running." -ForegroundColor Red
    }
}

Write-Host "`n--- 🌐 NETWORK PRIVACY CHECK ---" -ForegroundColor Cyan

# 2. Check VPN IP vs Local IP
$vpnIp = docker exec $VPN_CONTAINER wget -qO- https://api.ipify.org
Write-Host "[VPN] Current VPN IP: $vpnIp" -ForegroundColor Yellow

# 3. Check Inter-Container Connectivity
Write-Host "`n--- 🔗 INTER-CONTAINER ROUTING ---" -ForegroundColor Cyan

# Test: Jellyseerr -> Radarr (via Gluetun)
$radarrTest = docker exec $REQUESTS_CONTAINER sh -c "nc -zv gluetun 7878" 2>&1
if ($radarrTest -match "open") {
    Write-Host "[SUCCESS] Jellyseerr can reach Radarr via 'gluetun:7878'" -ForegroundColor Green
} else {
    Write-Host "[FAILURE] Jellyseerr cannot reach Radarr! Check if Radarr is in Gluetun's network." -ForegroundColor Red
}

# Test: Jellyseerr -> Jellyfin (Direct Bridge)
$jellyfinTest = docker exec $REQUESTS_CONTAINER sh -c "nc -zv jellyfin 8096" 2>&1
if ($jellyfinTest -match "open") {
    Write-Host "[SUCCESS] Jellyseerr can reach Jellyfin via 'jellyfin:8096'" -ForegroundColor Green
} else {
    Write-Host "[FAILURE] Jellyseerr cannot reach Jellyfin! Use container name 'jellyfin' in settings." -ForegroundColor Red
}

# Test: Prowlarr -> FlareSolverr (Internal VPN Loopback)
$flareTest = docker exec $VPN_CONTAINER wget -qO- --spider http://127.0.0.1:8191 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Prowlarr can reach FlareSolverr at 127.0.0.1:8191" -ForegroundColor Green
} else {
    Write-Host "[FAILURE] FlareSolverr unreachable inside the VPN tunnel!" -ForegroundColor Red
}

Write-Host "`n--- ✅ CHECK COMPLETE ---`n"