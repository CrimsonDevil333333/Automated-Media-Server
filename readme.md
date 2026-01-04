# 🏠 Automated Media Server Stack

### 🛡️ VPN-Protected | ⚡ High-Performance | 🤖 Fully Automated

This repository contains a production-ready Docker Compose configuration for a complete media ecosystem. It is specifically tuned for a **"Split-Network"** architecture: keeping your automation and metadata searches private via **Proton VPN**, while maintaining maximum ISP speeds for downloads and local streaming.

---

## 🏗️ Architecture Overview

The stack is divided into two logical zones to balance privacy with performance:

* **🔒 Privacy Zone (Behind VPN):** All "Arr" applications (**Radarr, Sonarr, Lidarr, Prowlarr**) and **FlareSolverr** are routed through a **Gluetun** container. This ensures your search queries and metadata traffic are encrypted and masked.
* **🚀 Performance Zone (Local ISP):** **qBittorrent** and **Jellyfin** run directly on your host network. This prevents VPN overhead from slowing down your 4K streams or capping your torrent download speeds.

---

## 🌐 Service Map

| Service | Port | Access URL | Role |
| --- | --- | --- | --- |
| **Jellyseerr** | `5055` | [http://localhost:5055](https://www.google.com/search?q=http://localhost:5055) | User Request Interface |
| **Jellyfin** | `8096` | [http://localhost:8096](https://www.google.com/search?q=http://localhost:8096) | Media Server & Player |
| **qBittorrent** | `8701` | [http://localhost:8701](https://www.google.com/search?q=http://localhost:8701) | Torrent Downloader |
| **Prowlarr** | `9696` | [http://localhost:9696](https://www.google.com/search?q=http://localhost:9696) | Indexer Manager (VPN) |
| **Radarr** | `7878` | [http://localhost:7878](https://www.google.com/search?q=http://localhost:7878) | Movie Management (VPN) |
| **Sonarr** | `8989` | [http://localhost:8989](https://www.google.com/search?q=http://localhost:8989) | TV Show Management (VPN) |
| **Lidarr** | `8686` | [http://localhost:8686](https://www.google.com/search?q=http://localhost:8686) | Music Management (VPN) |
| **Bazarr** | `6767` | [http://localhost:6767](https://www.google.com/search?q=http://localhost:6767) | Subtitle Automation (VPN) |

---

## 🚀 Getting Started

### 1. Environment Configuration

Create a `.env` file in your project root. This file handles your local paths and VPN credentials.

```bash
# General Settings
TIMEZONE=Asia/Kolkata
DATA_LOCATION=D:/Your/Media/Folder

# Proton VPN Credentials 
# (Find these in Proton Dashboard > Account > OpenVPN/IKEv2)
OPENVPN_USER=your_proton_username
OPENVPN_PASSWORD=your_proton_password

```

### 2. Deployment

Launch the entire stack in detached mode:

```powershell
docker compose up -d

```

### 3. Verify VPN Kill-Switch

Confirm that your management apps are successfully routed through the VPN:

```powershell
docker compose exec radarr curl https://ipinfo.io

```

> **Note:** If the output shows your real ISP location, stop the containers and check your `gluetun` credentials.

---

## 🔗 Critical Connection Logic

Because the apps live in different network contexts (some in the VPN container, some on the host), follow these rules to link them:

### A. Linking Arrs to qBittorrent (VPN → Host)

Since qBittorrent is outside the VPN, the Arrs cannot find it via `localhost`.

1. Run `ipconfig` in PowerShell to find your **Local IPv4 Address** (e.g., `192.168.1.15`).
2. In Radarr/Sonarr > **Settings** > **Download Clients**:
* **Host:** `192.168.1.15` (Your Local IP)
* **Port:** `8701`



### B. Linking Prowlarr to Arrs (VPN → VPN)

Since these are all routed through the Gluetun container, they share the same network stack.

1. In Prowlarr > **Settings** > **Apps**:
* **Prowlarr Server:** `http://localhost:9696`
* **Radarr/Sonarr Server:** `http://localhost:7878` (etc.)



---

## 📂 Data Structure (Atomic Moves)

For "Instant Moves" (hardlinking) to work properly, qBittorrent and the Arrs must see the same internal file structure.

```text
${DATA_LOCATION}
├── torrents          # Active & Seeding downloads
└── media
    ├── movies        # Organized library for Jellyfin
    ├── tv            # Organized library for Jellyfin
    └── music         # Organized library for Jellyfin

```

---

## 🛠 Troubleshooting

* **VPN Stuck Booting:** Check logs with `docker compose logs -f gluetun`. Ensure your Proton VPN account is active and you are using the **OpenVPN credentials**, not your standard login email.
* **Cannot access Web UI:** If `localhost` doesn't work, try accessing the services via your local IP (e.g., `http://192.168.1.15:7878`).
* **DNS Failures:** If containers can't reach the internet, add `DNS_ADDRESS=1.1.1.1` to the `gluetun` environment variables in your `docker-compose.yml`.
