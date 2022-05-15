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
    - [ ] pgAdmin
    - [ ] Visual Studio Code Web
  - Utils
    - [x] cfssl for internal certificate management
    - [x] certbot
    - [x] duckdns

## Current Deployment Status

![Deployment Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/tetofonta/homeassistant-docker-deploy/master/nwstatus.puml)

## Setup

  - Change subdomains in nginx config files. _there's a file for each service_
  - Create env files from templates. _e.g `cd env; for file in *.template; do; cp -v "$file" "$(echo $file | sed 's/.template//')"; done`_
  - Run.

## Known Problems

  - App releated
    - [ ] iOS app does not work
    - [ ] MFA not working
  - User experience releated
    - [ ] users on hass must coincide with authentik
  - Setup releated
    - [ ] initial setup is required in hass (and needs to be the same as the authentik user)
    - [ ] interactive certbot first run

### Notes

postrges-12 is used because of a bug in upstream libpq for v.14.

In case of a persisting "initializing" page in homeassistant after the login, try hard reloading/deleting cache.