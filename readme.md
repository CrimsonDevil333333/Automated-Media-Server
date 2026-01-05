# 🏠 Automated Media Server Stack

### 🛡️ VPN-Protected | ⚡ High-Performance | 🤖 Fully Automated

This repository contains a production-ready Docker Compose configuration for a complete media ecosystem. It is specifically tuned for a **"Split-Network" architecture**: keeping your automation and metadata searches private via **Proton VPN**, while maintaining maximum ISP speeds for local streaming and high-bandwidth downloads.

---

## 🏗️ Architecture Overview

The stack is divided into two logical zones to balance privacy with performance:

* **🔒 Privacy Zone (Behind VPN):** All "Arr" applications (**Radarr, Sonarr, Lidarr, Prowlarr**) and **FlareSolverr** are routed through **Gluetun**. This masks your traffic from your ISP and prevents metadata/indexer tracking.
* **🚀 Performance Zone (Local ISP):** **Homepage**, **Jellyseerr**, **Jellyfin**, and **qBittorrent** run on the standard Docker bridge network. This ensures posters load instantly, 4K streams aren't throttled by VPN overhead, and torrent downloads use your full ISP bandwidth.

---

## 📂 Directory Structure

To ensure **"Atomic Moves"** (hardlinking) work correctly, the stack follows this layout:

```text
D:\Docker\jellyfin
├── .env                  # Environment variables
├── docker-compose.yml    # Core stack configuration
├── check_stack.ps1       # Windows Health Script
├── check_stack.sh        # Linux/macOS Health Script
├── data/                 # Unified Media Storage
│   ├── downloads/        # Active & Seeding torrents
│   │   ├── movies/
│   │   ├── music/
│   │   └── shows/
│   └── media/            # Organized Library (Jellyfin/Arrs)
│       ├── movies/       # Organized by Radarr
│       ├── music/        # Organized by Lidarr
│       └── shows/        # Organized by Sonarr
├── homepage/             # Dashboard configuration
│   └── config/           # services.yaml & widgets.yaml
├── gluetun/              # VPN config & logs
├── jellyfin-config/      # Server metadata
├── jellyseerr/           # Request database
└── [radarr|sonarr|...]   # App-specific configs

```

---

## ⚙️ Environment Configuration (`.env`)

Create a `.env` file in the root directory to manage your paths and VPN credentials.

```bash
# --- Path & System Settings ---
DATA_LOCATION=D:/Docker/jellyfin/data
TIMEZONE=Asia/Kolkata

# --- ProtonVPN Credentials ---
# (Dashboard > Account > OpenVPN/IKEv2 Username)
OPENVPN_USER=OPENVPN_USER
OPENVPN_PASSWORD=OPENVPN_PASSWORD

```

---

## 🌐 Service Map

| Service | Port | Access URL | Role |
| --- | --- | --- | --- |
| **Homepage** | `3000` | [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000) | **Master Dashboard** |
| **Jellyseerr** | `5055` | [http://localhost:5055](https://www.google.com/search?q=http://localhost:5055) | User Request Interface (Bridge) |
| **Jellyfin** | `8096` | [http://localhost:8096](https://www.google.com/search?q=http://localhost:8096) | Media Server & Player (Bridge) |
| **qBittorrent** | `8701` | [http://localhost:8701](https://www.google.com/search?q=http://localhost:8701) | Torrent Downloader (Bridge) |
| **Prowlarr** | `9696` | [http://localhost:9696](https://www.google.com/search?q=http://localhost:9696) | Indexer Manager (VPN) |
| **Radarr** | `7878` | [http://localhost:7878](https://www.google.com/search?q=http://localhost:7878) | Movie Management (VPN) |
| **Sonarr** | `8989` | [http://localhost:8989](https://www.google.com/search?q=http://localhost:8989) | TV Show Management (VPN) |
| **FlareSolverr** | `8191` | (Internal Only) | Cloudflare Bypass (VPN) |

---

## 🔗 Critical Connection Logic

Because the apps live in different network contexts, you **must** use these specific hostnames in their respective Web UIs:

| Connection Type | Target Service | Hostname to Use | Port |
| --- | --- | --- | --- |
| **Inside VPN ⮕ Host IP** | qBittorrent / Jellyfin | `host.docker.internal` | `8701` / `8096` |
| **Inside VPN ⮕ Inside VPN** | Prowlarr ⮕ FlareSolverr | `127.0.0.1` | `8191` |
| **Bridge ⮕ Inside VPN** | Jellyseerr ⮕ Radarr | `gluetun` | `7878` |
| **Bridge ⮕ Bridge** | Jellyseerr ⮕ Jellyfin | `jellyfin` | `8096` |
| **Dashboard ⮕ Apps** | Homepage ⮕ Radarr | `http://gluetun:7878` | `7878` |

---

## 🚀 Deployment & Management

### 1. Initial Start

```bash
# Launch the stack in detached mode
docker-compose up -d

```

### 2. Monitoring

```bash
# View live logs for all services
docker-compose logs -f

# View logs for the VPN connection only
docker logs -f gluetun

```

---

## 🩺 Stack Health Check

Run these scripts to verify if your "Kill-Switch" is active and if services can communicate.

### **Windows (PowerShell)**

```powershell
./check_stack.ps1

```

### **Linux / macOS (Bash)**

```bash
chmod +x check_stack.sh
./check_stack.sh

```

---

## 💾 Backup & Recovery

Your media files are large, but your **configurations (databases)** are small and critical. If your OS crashes, having these backups allows you to restore the entire server in minutes.

### 1. What to Backup

Focus on the `.db` and `.xml` files within: `./radarr`, `./sonarr`, `./prowlarr`, `./jellyseerr`, and `./jellyfin-config`.

### 2. Manual Backup (Windows)

Run this command to create a zipped archive of all configs:

```powershell
Compress-Archive -Path .\radarr, .\sonarr, .\prowlarr, .\jellyseerr, .\jellyfin-config -DestinationPath .\backup_configs.zip

```

### 3. Recovery Procedure

1. Deploy `docker-compose.yml` and `.env` on the new machine.
2. Restore the `data/` folder and extract `backup_configs.zip` into the app directories.
3. Run `docker-compose up -d`.

---

## 🛠️ Maintenance & Useful Commands

| Task | Command |
| --- | --- |
| **Update All Services** | `docker-compose pull && docker-compose up -d` |
| **Clean Unused Data** | `docker system prune -a --volumes` |
| **Check Resource Usage** | `docker stats` |
| **Force VPN Restart** | `docker-compose restart gluetun` |
| **Remove Orphaned Images** | `docker image prune -f` |

---

## 🛠 Troubleshooting & Manual Checks

* **TMDB Metadata Errors:** If Jellyseerr fails to fetch posters, ensure it is **not** behind the VPN (check `network_mode` is removed).
* **Cloudflare (403/Handshake) Errors:** In **Prowlarr**, go to `Settings > Indexer Proxies`. Add **FlareSolverr** with host `http://127.0.0.1:8191` and assign it to the failing indexer.
* **Missing Posters:** In Jellyseerr settings, ensure the **Jellyfin Host** is `http://jellyfin:8096`.
* **Kill-Switch Confirmation:**
```bash
# Check VPN IP (Should be ProtonVPN)
docker exec gluetun wget -qO- https://api.ipify.org

# Check Local ISP IP (Should be your ISP)
docker exec qbittorrent wget -qO- https://api.ipify.org

```



---