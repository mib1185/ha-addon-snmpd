ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache net-snmp

COPY rootfs /

CMD ["/run.sh"]