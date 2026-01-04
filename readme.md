# 🏠 Automated Media Server Stack

### 🛡️ VPN-Protected | ⚡ High-Performance | 🤖 Fully Automated

This repository contains a production-ready Docker Compose configuration for a complete media ecosystem. It is specifically tuned for a **"Split-Network"** architecture: keeping your automation and metadata searches private via **Proton VPN**, while maintaining maximum ISP speeds for downloads and local streaming.

---

## 🏗️ Architecture Overview

The stack is divided into two logical zones to balance privacy with performance:

* **🔒 Privacy Zone (Behind VPN):** All "Arr" applications (**Radarr, Sonarr, Lidarr, Prowlarr**), **Jellyseerr**, and **FlareSolverr** are routed through a **Gluetun** container. This ensures your search queries and metadata traffic are encrypted and masked.
* **🚀 Performance Zone (Local ISP):** **qBittorrent** and **Jellyfin** run directly on your host network. This prevents VPN overhead from slowing down your 4K streams or capping your torrent download speeds.

---

## 🌐 Service Map

| Service | Port | Access URL | Role |
| --- | --- | --- | --- |
| **Jellyseerr** | `5055` | [http://localhost:5055](https://www.google.com/search?q=http://localhost:5055) | User Request Interface (VPN) |
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

---

## 🔗 Critical Connection Logic

Because the apps live in different network contexts (some in the VPN container, some on the host), use this table to configure the connections in each app's Web UI:

| Connection | Hostname to Use | Reason |
| --- | --- | --- |
| **Radarr/Sonarr ⮕ qBittorrent** | `host.docker.internal` | Connects from inside the VPN container to your Windows Host. |
| **Prowlarr ⮕ Radarr/Sonarr** | `localhost` | Both live inside the same network (Gluetun). |
| **Jellyseerr ⮕ Radarr/Sonarr** | `localhost` | Both live inside the same network (Gluetun). |
| **Jellyseerr ⮕ Jellyfin** | `host.docker.internal` | Connects from the VPN network back to the Host network. |

### Why use `host.docker.internal`?

In this setup, `localhost` inside a container (like Radarr) refers only to that container. To reach **qBittorrent** or **Jellyfin** (which are on the host network), we use `host.docker.internal` to exit the Docker network and communicate with the Windows machine.

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
* **Connection Refused:** Ensure `extra_hosts` is correctly defined in your `docker-compose.yml` for the `gluetun` service, otherwise `host.docker.internal` will not resolve.
* **DNS Failures:** If containers can't reach the internet, add `DNS_ADDRESS=1.1.1.1` to the `gluetun` environment variables.
