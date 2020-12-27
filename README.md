**--> more will follow soon<--**

you can find more details about source on github https://github.com/roobbb/owserver


### run example with standard config (a udev rule sets a denkovi-usb-device to /dev/onewire):

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       --device=/dev/onewire \
    roobbb/owserver

+ standard config sets owserver listening on localhost:4303 and owhttpd on 2121
+ if another process on your host should connect to owserver, the unix socket doesn't work - please set up your own custom config where owserver is listening on 127.0.0.1:4303 e.g.

### example running a custom config

    docker run -d \
       --name=owserver \
       --net=host \
       --restart=always \
       -v /etc/localtime:/etc/localtime:ro \
       -v /mypath/to_my_config:/root/.local/share \
       --device=/dev/onewire \
       -e CUSTOM_CONFIG_ENABLED=1 \
       -e CUSTOM_CONFIG_FILE=/root/.local/share/owfs.conf \
    roobbb/owserver

