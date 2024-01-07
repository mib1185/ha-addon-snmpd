ARG BUILD_FROM
FROM $BUILD_FROM

RUN apt-get update \
    && apt-get install -y snmpd \
    && apt-get clean autoclean \
    && apt-get autoremove -y

COPY read_supervisor_data.sh /
COPY run.sh /

CMD ["/run.sh"]