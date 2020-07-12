# dylanbulmer/gmod

## Description
This image allows you to easily deploy a GMod server with very little hassle. When developing this image, I based it off SteamCMD's docker image to download set up steamcmd and I developed it around Docker Swarm with traefik as my edge router.

## Docker Swarm Example

Here is what my Prop Hunt server `docker-stack.yml` looks like:

*Replace environment variables wrapped in `${}` with your own values or import a `.env` file durring deployment.*

```yaml
version: "3.7"

services:
  prophunt:
    image: dylanbulmer/gmod:latest
    environment:
      - MAP=${MAP}
      - MAX_PLAYERS=${MAX_PLAYERS}
      - GAMEMODE=${GAMEMODE}
      - WORKSHOP_COLLECTION=${WORKSHOP_COLLECTION}
      - AUTH_KEY=${AUTH_KEY}
    configs:
      - source: server-config
        target: /home/steam/gmod/garrysmod/cfg/server.cfg
      - source: mount-config
        target: /home/steam/gmod/garrysmod/cfg/mount.cfg
    networks:
      - default
      - proxy
    deploy:
      mode: replicated
      replicas: 1
      labels:
       # Set up Traefik routing
       - "traefik.constraint-label=proxy"
       - "traefik.enable=true"
       - "traefik.docker.network=proxy"
       # UDP router
       - "traefik.udp.routers.prophunt.service=prophunt"
       - "traefik.udp.routers.prophunt.entrypoints=steamudp"
       - "traefik.udp.services.prophunt.loadbalancer.server.port=27015"
      placement:
        constraints:
          # Force deployment to worker.
          - node.role!=manager

networks:
  proxy:
    external: true

configs:
  server-config:
    file: ./server.cfg
  mount-config:
    file: ./mount.cfg
```

## Environmental Variables

\* are required.

| Variable | Description |
|---|---|
| `${MAP}` | The server's starting map *(default: 'gm_construct')*
|`${MAX_PLAYERS}`| Max number of players allowed on the server *(default: 12)*
| `${GAMEMODE}` | Server's gamemode, i.e. prop-hunt, ttt, sandbox, etc. *(default: sandbox)*
|`${WORKSHOP_COLLECTION}` | * Workshop collection id, required to obtain gamemodes, maps, and other content.
|`${AUTH_KEY}`| * Developr auth key found on [Steam's community developer page](https://steamcommunity.com/dev/apikey). Enter any url to obtain the key.