ARG BUILD_FROM=ghcr.io/home-assistant/base-debian:trixie
FROM ${BUILD_FROM}

RUN apt-get update \
    && apt-get install -y snmpd lldpd \
    && apt-get clean autoclean \
    && apt-get autoremove -y

COPY bashio_info.sh /
COPY run.sh /

LABEL \
    org.opencontainers.image.title="SNMPD" \
    org.opencontainers.image.description="Monitor your HA installation via snmp" \
    org.opencontainers.image.source="https://github.com/mib1185/ha-addon-snmpd" \
    org.opencontainers.image.licenses="Apache License 2.0"

CMD ["/run.sh"]
