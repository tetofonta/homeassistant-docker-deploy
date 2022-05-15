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

## Known Problems

  - [ ] iOS app does not work
  - [ ] users on hass must coincide with authentik
  - [ ] initial setup is required in hass (and needs to be the same as the authentik user)
  - [ ] apps not added to outpost in authentik
  - [ ] postgresql not working in homeassistant
  - [ ] use duckdns for real

### Notes
postrges-12 is used because of a bug in upstream libpq for v.14.