# Homeassistant docker deployment
### Fully configurable and (hopefully) secured homeassistant deployment

## Components

  - Database:
    - [x] Postgresql
  - [x] Authentication
    - [x] Authentik + Geoipupdate
    - [x] Redis
  - Ingress
    - [x] Nginx
  - HomeAssistant Stack
    - [x] Homeassistant
    - [ ] influxdb
    - [ ] Appdaemon
    - [ ] AdGuard
    - [ ] Zigbee2mqtt
    - [ ] Mosquitto
  - Management
    - [ ] Portainer
    - [ ] Visual Studio Code Web
  - Utils
    - [x] cfssl for internal certificate management
    - [x] certbot
    - [x] duckdns

## Current Deployment Status

![Deployment Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/tetofonta/homeassistant-docker-deploy/master/nwstatus.puml)
