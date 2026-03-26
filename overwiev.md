flowchart LR

%% Lokales Netzwerk
subgraph LOCAL [Lokales Netzwerk]
direction TB

    JF[Jellyfin\nPort 8096\nREAD: /media]

    MB[(Medienbibliothek\n/home/fill-usr/media)]

    SON[Sonarr\nPort 8989\nWRITE: /media]
    RAD[Radarr\nPort 7878\nWRITE: /media]
    QBIT[qBittorrent\nPort 8080\nWRITE: /media]

    SEERR[Seerr\nPort 5055]

    TS[Tailscale Node\nHost Network\nFunnel Endpoint]

end

%% Internet
subgraph INTERNET [Öffentlich / Internet]
direction TB
    FUNNEL[Tailscale Funnel\nHTTPS 443 -> Jellyfin 8096]
    CLIENT[Externes Gerät\nLaptop / TV / Phone]
end

%% Medienzugriffe
JF -->|read| MB
SON -->|write| MB
RAD -->|write| MB
QBIT -->|write| MB

%% API-Flows
SEERR -->|API| SON
SEERR -->|API| RAD

SON -->|API DL Job| QBIT
RAD -->|API DL Job| QBIT

%% Extern
CLIENT -->|HTTPS 443| FUNNEL --> TS --> JF
