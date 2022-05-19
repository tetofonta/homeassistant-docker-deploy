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
    - [x] pgAdmin
    - [x] Visual Studio Code Web
    - [ ] prometheus + exportes
    - [ ] graphana
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

  - Homeassistant App releated
    - [ ] iOS app does not work
    - [ ] MFA not working
    - [ ] in app services may require login and error with 'too many reloads'. It's sufficient to reload the view.
  - User experience releated
    - [ ] users on hass must coincide with authentik
    - [ ] pgadmin will 500 on signing after authentik console redirect
    - [ ] pgadmin is not configured. a new connection has to be made
    - [ ] in homeassistant applications will be authenticated against hass authentik app. it's possible that users not allowed to use those apps will be able to log in from homeassitant
    - [ ] authentik needs to refresh outpost configuration from gui at first startup
  - Setup releated
    - [ ] initial setup is required in hass (and needs to be the same as the authentik user)
    - [ ] interactive certbot first run
    - [ ] setup must be done with user 1000:1000. (still may need chown 1000:1000 -R data/ssl/internal/certs/vscode)

### Notes

postrges-12 is used because of a bug in upstream libpq for v.14.
if you're triyng to run data directory on ntfs, youll'need to use a docker volume for postgres (or move the data directorty over ext4)

In case of a persisting "initializing" page in homeassistant after the login, try hard reloading/deleting cache.

portainer sso must be configured manually [here](https://goauthentik.io/integrations/services/portainer/).

for pgadmin connection to database use `database` as hostname

## Config guides

### first setup

#### Dns setup for development

todo. change eventually uid gid in compose?

### portainer sso

todo

### rclone Google Drive

follow [this guide](https://rclone.org/drive/#making-your-own-client-id) for credentials setup

After all containers are up

<pre>
docker-compose exec rclone rclone config

sudo docker-compose exec rclone rclone config

No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> <b>n</b>
name> <b>homeassistant_backup</b>
Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
...
17 / Google Drive
   \ (drive)
...
Storage> <b>drive</b>
Option client_id.
Google Application Client Id
Setting your own is recommended.
See https://rclone.org/drive/#making-your-own-client-id for how to create your own.
If you leave this blank, it will use an internal key which is low performance.
Enter a value. Press Enter to leave empty.
client_id> <b>*redacted*</b>
Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> <b>*redacted*</b>
Option scope.
Scope that rclone should use when requesting access from drive.
Choose a number from below, or type in your own value.
Press Enter to leave empty.
 1 / Full access all files, excluding Application Data Folder.
   \ (drive)
...
scope> <b>drive</b>
Option root_folder_id.
ID of the root folder.
Leave blank normally.
Fill in to access "Computers" folders (see docs), or for rclone to use
a non root folder as its starting point.
Enter a value. Press Enter to leave empty.
root_folder_id> 
Option service_account_file.
Service Account Credentials JSON file path.
Leave blank normally.
Needed only if you want use SA instead of interactive login.
Leading `~` will be expanded in the file name as will environment variables such as `${RCLONE_CONFIG_DIR}`.
Enter a value. Press Enter to leave empty.
service_account_file> 
Edit advanced config?
y) Yes
n) No (default)
y/n> <b>n</b>
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine

y) Yes (default)
n) No
y/n> <b>n</b>
Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        rclone authorize "drive" "...redacted..."
Then paste the result.
</pre>

Now go to a machine with rclone installed and with a web broser, then execute the command like said

<pre>

Enter a value.
config_token> <b>*pasted value redacted*</b>
Configure this as a Shared Drive (Team Drive)?

y) Yes
n) No (default)
y/n> <b>n</b>
--------------------
configs redacted
--------------------
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> <b>y</b>
Current remotes:

Name                 Type
====                 ====
homeassistant_backup drive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> <b>q</b>
</pre>

### rclone encrypted backup

After all containers are up
<pre>
sudo docker-compose exec rclone rclone config

Current remotes:

Name                 Type
====                 ====
homeassistant_backup drive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> <b>n</b>
name> <b>crypt</b>
Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
 ...
13 / Encrypt/Decrypt a remote
   \ (crypt)
 ...
Storage> <b>crypt</b>
Option remote.
Remote to encrypt/decrypt.
Normally should contain a ':' and a path, e.g. "myremote:path/to/dir",
"myremote:bucket" or maybe "myremote:" (not recommended).
Enter a value.
remote> <b>homeassistant_backup:backup_testing</b>
Option filename_encryption.
How to encrypt the filenames.
Choose a number from below, or type in your own string value.
Press Enter for the default (standard).
   / Encrypt the filenames.
 1 | See the docs for the details.
   \ (standard)
 2 / Very simple filename obfuscation.
   \ (obfuscate)
   / Don't encrypt the file names.
 3 | Adds a ".bin" extension only.
   \ (off)
filename_encryption> <b>2</b>
Option directory_name_encryption.
Option to either encrypt directory names or leave them intact.
NB If filename_encryption is "off" then this option will do nothing.
Choose a number from below, or type in your own boolean value (true or false).
Press Enter for the default (true).
 1 / Encrypt directory names.
   \ (true)
 2 / Don't encrypt directory names, leave them intact.
   \ (false)
directory_name_encryption> <b>2</b>
Option password.
Password or pass phrase for encryption.
Choose an alternative below.
y) Yes, type in my own password
g) Generate random password
y/g> <b>g</b>
Password strength in bits.
64 is just about memorable
128 is secure
1024 is the maximum
Bits> <b>256</b>
Your password is: [redacted]
Use this password? Please note that an obscured version of this 
password (and not the password itself) will be stored under your 
configuration file, so keep this generated password in a safe place.
y) Yes (default)
n) No
y/n> <b>y</b>
Option password2.
Password or pass phrase for salt.
Optional but recommended.
Should be different to the previous password.
Choose an alternative below. Press Enter for the default (n).
y) Yes, type in my own password
g) Generate random password
n) No, leave this optional password blank (default)
y/g/n> <b>g</b>
Password strength in bits.
64 is just about memorable
128 is secure
1024 is the maximum
Bits> 256
Your password is: [redacted]
Use this password? Please note that an obscured version of this 
password (and not the password itself) will be stored under your 
configuration file, so keep this generated password in a safe place.
y) Yes (default)
n) No
y/n> <b>y</b>
Edit advanced config?
y) Yes
n) No (default)
y/n> <b>n</b>
--------------------
redacted
--------------------
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> <b>y</b>
Current remotes:

Name                 Type
====                 ====
crypt                crypt
homeassistant_backup drive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> <b>q</b>
</pre>

### Docker prometheus metrics.

see [this](https://docs.docker.com/config/daemon/prometheus/)

you'll need to install node_exporter