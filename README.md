# this repo is now read-only and archived

# One-Wire Docker-Container

+ **Home of owfs (owserver etc.) is https://owfs.org**
+ **This container is based on debian-slim:stable and installs owserver, owhttpd and owftpd via apt-get as it comes from the official debian repositories**
+ **intended to use together with SmartHome systems as follows on a Raspberry-PI or any other machine (may even work in other SmartHome scenarios, but not all can be tested)**
  - **FHEM** (https://github.com/roobbb/owserver/wiki/3.1.-examples-for-FHEM)
  - **OpenHAB** (https://github.com/roobbb/owserver/wiki/3.2.-examples-for-OpenHAB)
  - **Home Assistant** (https://github.com/roobbb/owserver/wiki/3.3.-example-for-Home-Assistant)
  - **ioBroker** (https://github.com/roobbb/owserver/wiki/3.4.-example-for-ioBroker)
  - **HomeBridge.io** (https://github.com/roobbb/owserver/wiki/3.5.-example-for-HomeBridge)
  - **Node Red** (https://github.com/roobbb/owserver/wiki/3.6.-example-for-NodeRed)
+ **Please find more information inside the Github Wiki https://github.com/roobbb/owserver/wiki**
+ **Latest will always come from main-branch; Dev-version is always for testing purposes only**
+ **you can find source files on Github https://github.com/roobbb/owserver to provide an inside into the deep or to build the container on your own**

### Variables declared inside docker-file for setting defaults:

|VAR               |VALUE   |hint                                                                                     |
|------------------|:----------:|--------------------------------------------------------------------------|
|WEB_PORT   |2121     |sets value inside /etc/owfs.conf for http port             | 
|OWFS_PORT|4304      |sets value  inside /etc/owfs.conf for owserver's port|
|FTP_PORT    |2120      |sets value inside /etc/owfs.conf for ftp port                |
|OW_DEVICE |onewire|sets value inside /etc/owfs.conf for mapped device  |
|OW_SERVER|127.0.0.1|sets value inside /etc/owfs.conf for owserver's adress<br>use 127.0.0.1 when a locally installed service should have access<br>set a name or alias when another container should get access see examples for more details|

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

+ standard config binds owserver on localhost:4304 and owhttpd on port 2121
+ if another process on your host should connect to owserver, the unix socket localhost:4304 doesn't work with docker - therefore owserver is set on 127.0.0.1:4304 by default

### run example: start owserver only with default values 

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --device=/dev/onewire \
       -e SERVICES_LVL=1 \
    roobbb/owserver
