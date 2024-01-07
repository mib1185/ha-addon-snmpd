#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

bashio::log.info "Set snmp configuration..."
COMMUNITY=$(bashio::config 'snmp_community')
NAME=$(bashio::config 'snmp_name')
LOCATION=$(bashio::config 'snmp_location')
CONTACT=$(bashio::config 'snmp_contact')

HAOS_HOSTNAME=$(/read_supervisor_data.sh hostname)
HAOS_MACHINE=$(/read_supervisor_data.sh machine)
HAOS_OPERATING_SYSTEM=$(/read_supervisor_data.sh operating_system)

UN_KERNEL_NAME=$(uname -s)
UN_KERNEL_RELEASE=$(uname -r)
UN_KERNEL_VERSION=$(uname -v)
UN_MACHINE=$(uname -m)

cat > /etc/snmp/snmpd.conf <<EOF
com2sec readonly default $COMMUNITY
sysname $NAME
syslocation $LOCATION
syscontact $CONTACT
sysdescr $UN_KERNEL_NAME $HAOS_HOSTNAME $UN_KERNEL_RELEASE $UN_KERNEL_VERSION $UN_MACHINE ($HAOS_OPERATING_SYSTEM)

group MyROGroup v2c readonly
view all included .1 80
access MyROGroup "" any noauth exact all none none

# hass data
extend hass_docker_version '/read_supervisor_data.sh docker'
extend hass_hassos_version '/read_supervisor_data.sh hassos'
extend hass_homeassistant_version '/read_supervisor_data.sh homeassistant'
extend hass_supervisor_version '/read_supervisor_data.sh supervisor'
extend hass_state '/read_supervisor_data.sh state'
extend hass_supported '/read_supervisor_data.sh supported'

#libreNMS distro detection
extend distro '/bin/echo $HAOS_OPERATING_SYSTEM'
EOF

if [[ "$UN_MACHINE" == "x86"* ]]; then
cat >> /etc/snmp/snmpd.conf <<EOF
#libreNMS Hardware Detection
extend manufacturer '/bin/cat /sys/devices/virtual/dmi/id/sys_vendor'
extend hardware '/bin/cat /sys/devices/virtual/dmi/id/product_name'
extend serial '/bin/cat /sys/devices/virtual/dmi/id/product_serial'
EOF
elif [[ "$UN_MACHINE" == "arm"* ]] || [[ "$UN_MACHINE" == "aarch64"* ]]; then
cat >> /etc/snmp/snmpd.conf <<EOF
#libreNMS Hardware Detection
extend hardware '/bin/echo $HAOS_MACHINE'
EOF
fi

# Run daemon
bashio::log.info "Starting the snmpd daemon..."
snmpd -f -LSid -c /etc/snmp/snmpd.conf
