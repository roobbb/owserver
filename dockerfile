#FROM arm32v7/debian:buster-slim AS temp_base

FROM debian:stable-slim AS temp_base

# Runtime environment variables with defaults
ENV WEB_PORT=2121 \
    OWFS_PORT=4303 \
    FTP_PORT=2120 \
    OW_DEVICE=onewire

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install owserver ow-shell owhttpd owftpd -y && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# get start-template
COPY ./start.sh /start.sh
#fill template with default values from above step by step 
RUN sed -i "s/\${WEB_PORT}/${WEB_PORT}/g" /start.sh
RUN sed -i "s/\${OWFS_PORT}/${OWFS_PORT}/g" /start.sh
RUN sed -i "s/\${FTP_PORT}/${FTP_PORT}/g" /start.sh
RUN sed -i "s/\${OW_DEVICE}/${OW_DEVICE}/g" /start.sh

#RUN chmod +x /start.sh
RUN ["chmod", "+x", "/start.sh"]

#get conf-template
COPY ./owfs.conf /etc/owfs.conf
#fill template with default values from above step by step
RUN sed -i "s/\${WEB_PORT}/${WEB_PORT}/g" /etc/owfs.conf
RUN sed -i "s/\${OWFS_PORT}/${OWFS_PORT}/g" /etc/owfs.conf
RUN sed -i "s/\${FTP_PORT}/${FTP_PORT}/g" /etc/owfs.conf
RUN sed -i "s/\${OW_DEVICE}/${OW_DEVICE}/g" /etc/owfs.conf

#collapse
FROM scratch
COPY --from=temp_base / /

EXPOSE ${WEB_PORT} ${OWFS_PORT} ${FTP_PORT}

ENTRYPOINT ["/start.sh"]
#ENTRYPOINT ["/bin/sh"]
