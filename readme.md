🏠 Automated Media Server Stack (VPN Protected)

This is a complete, automated media server configuration. It is designed to find, download, and organize media while keeping your search traffic private via Proton VPN (Free Tier).

🏗️ Architecture Summary

This setup uses a "Split-Network" design for maximum performance and privacy:

Privacy Zone (Behind VPN): All "Arr" apps (Radarr, Sonarr, etc.) and metadata searches are routed through Gluetun. If the VPN fails, these apps lose internet access immediately (Kill Switch).

Performance Zone (Local ISP): qBittorrent and Jellyfin run on your local internet connection. This ensures you get your full ISP download speed and can stream to your TV without VPN lag.

🌐 Service Map & Access

| Service | Port | Access URL | Role |
| :--- | :--- | :--- | :--- |
| **Jellyfin** | 8096 | [http://localhost:8096](http://localhost:8096) | Media Library & Player |
| **qBittorrent** | 8701 | [http://localhost:8701](http://localhost:8701) | Torrent Downloader |
| **Prowlarr** | 9696 | [http://localhost:9696](http://localhost:9696) | Torrent Site Indexer |
| **Radarr** | 7878 | [http://localhost:7878](http://localhost:7878) | Movie Manager |
| **Sonarr** | 8989 | [http://localhost:8989](http://localhost:8989) | TV Show Manager |
| **Lidarr** | 8686 | [http://localhost:8686](http://localhost:8686) | Music Manager |
| **Bazarr** | 6767 | [http://localhost:6767](http://localhost:6767) | Subtitle Downloader |
| **Flaresolverr** | 8191 | [http://localhost:8191](http://localhost:8191) | Cloudflare Solver |
| **Jellyseerr** | 5055 | [http://localhost:5055](http://localhost:5055) | Request Site (Optional) |

🚀 Setup Instructions

1. Environment Configuration

Create a .env file in the root folder with the following content:

TIMEZONE=Asia/Kolkata
DATA_LOCATION=D:/Your/Media/Folder

# Get these from Proton VPN Dashboard > Account > OpenVPN/IKEv2 username
OPENVPN_USER=your_long_proton_username
OPENVPN_PASSWORD=your_long_proton_password


2. Launch the Stack

Run this command in PowerShell inside your project folder:

docker compose up -d


3. Verify VPN Protection

Run this command to ensure Radarr is effectively hidden in another country:

docker compose exec radarr curl [https://ipinfo.io](https://ipinfo.io)


If the response shows a country like Netherlands, Singapore, or USA, your VPN is working.

🔗 Critical Connection Settings

Because the apps live in different network zones, you cannot always use localhost to connect them.

To link Radarr/Sonarr to qBittorrent:

Find your computer's local IP (Run ipconfig in PowerShell). It usually looks like 192.168.1.X.

In Radarr > Settings > Download Clients, add qBittorrent.

Host: Use your Local IP (e.g., 192.168.1.15). Do not use localhost.

Port: 8701

To link Prowlarr to Radarr/Sonarr:

Since these are all inside the same VPN container:

In Prowlarr > Settings > Apps.

Prowlarr Server: http://localhost:9696

Radarr Server: http://localhost:7878

Sonarr Server: http://localhost:8989

Lidarr Server: http://localhost:8686

📂 Recommended Folder Structure

For "Instant Moves" (Atomic Moves) to work, ensure your ${DATA_LOCATION} is structured like this:

/data
├── torrents          # Where qBittorrent downloads
└── media
    ├── movies        # Where Radarr moves files
    ├── tv            # Where Sonarr moves files
    └── music         # Where Lidarr moves files


🛠 Troubleshooting

Check VPN Status:
docker compose logs -f gluetun
Look for: "Initialization Sequence Completed"

DNS Issues:
If containers can't find the internet, ensure DOT=off and DNS_ADDRESS=1.1.1.1 are set in the gluetun environment variables.