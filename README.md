# One-Wire Docker-Container

+ **Home of owserver etc. is https://owfs.org**
+ **This container is based on debian-slim:stable and installs owserver, owhttpd and owftpd via apt-get - here are no changes on their sourcecode**
+ **intended to use on a Raspberry-PI together with the SmartHome Server FHEM (may even work in other SmartHome scenarios, but untested)**
+ **Dev-version is always for testing purposes only.**
+ **Latest will always come from main-branch.**
+ **you can find source files on github [ https://github.com/roobbb/owserver ] to build the container on your own**

### Variables declared inside docker-file for setting defaults:

|VAR               |VALUE   |hint                                                                                     |
|------------------|:----------:|--------------------------------------------------------------------------|
|WEB_PORT   |2121     |sets value inside /etc/owfs.conf for http port             | 
|OWFS_PORT|4303      |sets value  inside /etc/owfs.conf for owserver's port|
|FTP_PORT    |2120      |sets value inside /etc/owfs.conf for ftp port                |
|OW_DEVICE |onewire|sets value inside /etc/owfs.conf for mapped device  |

Those variables can be overwritten when starting the container. The new value from cli will be put inside the containers /etc/owfs.conf again and substitute the defaults.

### Variables evaluated by main script (start.sh) when starting the container

|VAR               |VALUE   |hint                                                                                     |
|------------------|:----------:|--------------------------------------------------------------------------|
|CUSTOM_CONFIG_ENABLED|1                         |starts with full custom config file, other than 1 means disabled| 
|CUSTOM_CONFIG_FILE          |/path/filename|set the full path and filename of the custom config <br> make sure you mapped it in there (e.g. -v /mypath/to_my_config:/root/.local/share)|
|SERVICES_LVL|1, 2 or 3| 1 starts owserver only, no owhttpd or owftpd<br>2 starts owserver and owhttpd, no owftpd<br>3 start all 3 services<br>leaving this away or giving any other value than 1-3 means use the default: 3|

### run example: start with standard config (a udev rule sets a denkovi-usb-device to /dev/onewire):

let's assume you have set a symlink for your device via udev-rule like found here https://wiki.fhem.de/wiki/OWServer_%26_OWDevice#Konfiguration_von_owserver

set udev-rule for a Denkovi-Device on host \
`ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="DAE001xy", SUBSYSTEMS=="usb", ACTION=="add", MODE="0660", GROUP="plugdev", SYMLINK+="onewire"`


    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --device=/dev/onewire \
    roobbb/owserver

+ standard config sets owserver listening on localhost:4303 and owhttpd on 2121
+ if another process on your host should connect to owserver, the unix socket localhost:4303 doesn't work with docker - therefore owserver is listening on 127.0.0.1:4303 by default

### run example: start owserver only with default values 

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --device=/dev/onewire \
       -e SERVICES_LVL=1 \
    roobbb/owserver

### run example: overwriting defaults

If your host's device is other than "onewire", then you always have to set "OW_DEVICE=" to that device name. Otherwise you can leave it away (because the default comes in affect).

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --device=/dev/ttyUSB0 \
       -e WEB_PORT=1234 \
       -e OW_DEVICE=ttyUSB0 \
       -e FTP_PORT=21 \
    roobbb/owserver

+ this example keeps OWFS_PORT to it's default (4303) but changes the rest
+ you can set one, all values or omit some

If you like to set your own owfs.conf, then pass the variable CUSTOM_CONFIG_ENABLED=1 and map your config-path into the container's file system und finally tell the main script where you put your own config file.

### run example: running a custom config

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       -v /mypath/to_my_config:/root/.local/share \
       --device=/dev/ttyS0 \
       -e CUSTOM_CONFIG_ENABLED=1 \
       -e CUSTOM_CONFIG_FILE=/root/.local/share/owfs.example \
    roobbb/owserver:dev

+ starts the dev-version with custom config "owfs.example" wich activates the fake-server (you could omit the paramter " --device=/dev/ttyS0" in this example, because the owfs.example doesn't point to any device)
+ you should reach the Web-Interface via http://yourHost:2121/ even if you dont have a real 1-wire device connected/ mapped

### example enter the running container
`docker exec -it owserver bash`

### stopping the container
`docher stop owserver`

### example definition in FHEM

`define myOWServer OWServer 127.0.0.1:4304` \
`attr myOWServer room OneWire`

+ please check WIKI [ https://wiki.fhem.de/wiki/OWServer_%26_OWDevice ] or commandref [ https://fhem.de/commandref.html#OWServer ] for more details  
+ FHEM can even run inside a docker container - the neccessary network config especially to get the docker containers to work together is not covered/ tested yet
