#!/bin/bash

function prepare_config {
  #override the defaults, check if set - if not, keep default
  if [ -z "$WEB_PORT" ]
  then
      echo "\$WEB_PORT not set - keeping default value ..."
  else
      WEB_PORT_NEW="$WEB_PORT"
      echo "\$WEB_PORT set - overriding default with new value"
      sed -i "s/http: port = ${WEB_PORT}/http: port = ${WEB_PORT_NEW}/g" /etc/owfs.conf
  fi
  #######
  if [ -z "$OWFS_PORT" ]
  then
      echo "\$OWFS_PORT not set - keeping default value ..."
  else
      OWFS_PORT_NEW="$OWFS_PORT"
      echo "\$OWFS_PORT set - overriding default with new value"
      sed -i "s/server: port = localhost:${OWFS_PORT}/server: port = localhost:${OWFS_PORT_NEW}/g" /etc/owfs.conf
      sed -i "s/\! server: server = localhost:${OWFS_PORT}/\! server: server = localhost:${OWFS_PORT_NEW}/g" /etc/owfs.conf
  fi
  #######
  if [ -z "$FTP_PORT" ]
  then
      echo "\$FTP_PORT not set - keeping default value ..."
  else
      FTP_PORT_NEW="$FTP_PORT"
      echo "\$FTP_PORT set - overriding default with new value"
      sed -i "s/ftp: port =  ${FTP_PORT}/ftp: port =  ${FTP_PORT_NEW}/g" /etc/owfs.conf
  fi
  #######
  if [ -z "$OW_DEVICE" ]
  then
      echo "\$OW_DEVICE not set - keeping default value ..."
  else
      OW_DEVICE_NEW="$OW_DEVICE"
      echo "\$OW_DEVICE set - overriding default with new value"
      sed -i "s/${OW_DEVICE}/${OW_DEVICE_NEW}/g" /etc/owfs.conf
  fi
  #######
  if [ -z "$OW_SERVER" ]
  then
      echo "\$OW_SERVER not set - keeping default value ..."
  else
      OW_DEVICE_NEW="$OW_SERVER"
      echo "\$OW_SERVER set - overriding default with new value"
      sed -i "s/${OW_SERVER}/${OW_SERVER_NEW}/g" /etc/owfs.conf
  fi

}

if [ "$CUSTOM_CONFIG_ENABLED" = "1" ]
then
    echo "starting services with custom config from $CUSTOM_CONFIG_FILE"
    mv /etc/owfs.conf /etc/owfs.conf.old
    cp "$CUSTOM_CONFIG_FILE" /etc/owfs.conf
else
    prepare_config
    echo "starting services with prepared standard config from /etc/owfs.conf"
fi

SERVICES=(owserver owhttpd owftpd)
#SERVICES_LVL=3

if [ -z "$SERVICES_LVL" ]
then 
 echo "no Service Level set, apply default 3"
 SERVICES_LVL=3
else
  if (( $SERVICES_LVL >= 1 )) && (( $SERVICES_LVL <= 3 ))
  then
   echo "valid Service Level set to $SERVICES_LVL"
  else
   echo "no valid Service Level set, applying default 3"
   SERVICES_LVL=3
 fi
fi


echo "looping array items: ${#SERVICES[*]}"
for index in ${!SERVICES[*]}
do
  if (($index +1 <= $SERVICES_LVL))
  then
   service "${SERVICES[$index]}" start
  fi
done


# Spin until we receive a SIGTERM (e.g. from `docker stop`)
echo "all work done, go sleeping..."
trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
tail -f /dev/null & wait ${!}

