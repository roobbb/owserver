# One-Wire Docker-Container

+ **Home of owfs (owserver etc.) is https://owfs.org**
+ **This container is based on debian-slim:stable and installs owserver, owhttpd and owftpd via apt-get - here are no changes on their sourcecode**
+ **intended to use together with SmartHome systems like FHEM, OpenHAB, Home Assistant, ioBroker or HomeBridge.io on a Raspberry-PI or any other machine (may even work in other SmartHome scenarios, but not all can be tested)**
+ **please find more configuring details and examples in this wiki https://github.com/roobbb/owserver/wiki**
+ **Dev-version is always for testing purposes only.**
+ **Latest will always come from main-branch.**
+ **you can find the docker container under https://hub.docker.com/r/roobbb/owserver for some different architectures**

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

+ this example keeps OWFS_PORT to it's default (4304) but changes the rest
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
`docker exec -it owserver /bin/bash`

### stopping the container
`docker stop owserver`

### example definition in FHEM (when FHEM is installed locally and running on your host directly) 

`define myOWServer OWServer 127.0.0.1:4304` \
`attr myOWServer room OneWire`

+ please check WIKI [ https://wiki.fhem.de/wiki/OWServer_%26_OWDevice ] or commandref [ https://fhem.de/commandref.html#OWServer ] for more details  
+ FHEM can even run inside a docker container - check next example  

### example when FHEM even runs in a container

add a new user-defined-network
    docker network create mynet

+ edit owfs.example and change server ip-address from 127.0.0.1 to the name of the docker container which we want to start (owserver) or its network-alias (myserver), even the server's port should be the same as what we want to map
+ start owserver-container with new network and alias and map ports as required

      docker run -d \
        --rm \
        --name=owserver \
        --net=mynet \
        --network-alias myserver \
        -p 2121:2121 \
        -v /etc/localtime:/etc/localtime:ro \
        -v /mypath/to_my_config:/root/.local/share \
        --device=/dev/ttyUSB0 \
        -e CUSTOM_CONFIG_ENABLED=1 \
        -e CUSTOM_CONFIG_FILE=/root/.local/share/owfs.example \
      roobbb/owserver:dev

+ check if the web-interface is reachable via http://yourHost:2121/

+ start the official FHEM container as it matches your requirements (for more details please check Readme on Github https://github.com/fhem/fhem-docker or FHEM board https://forum.fhem.de/index.php?topic=89745.0)
+ please make sure FHEM is member of at least one network where owserver is connected to (mynet in this example)

example for this testing here:

      docker run -d --rm --net=mynet -p 8083:8083 --name fhem  fhem/fhem

+ please check if you can reach FHEM's web-if via http://yourHost:8083/fhem
+ define a device for owserver in FHEM - let's assume you wrote "myserver:4304" into your owfs.example as owserver's adress 

`define myLocalOWServer OWServer myserver:4304` \
`attr myLocalOWServer room OWDevice` \
`attr myLocalOWServer nonblocking 1`

+ you should see lots of readings right after entering the define-command - if not, please check server adress+port as defined in owfs.example and start-command of owserver-container

+ of course you can start owserver and FHEM with the option "--net=host" and both of them can be member of further networks as long as both share at least one network
+ if you use "--net=host" you have to set owserver to 127.0.0.1:4304 again - just like you should, when FHEM would run as a local service
