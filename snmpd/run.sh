#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

bashio::log.info "Set snmp configuration..."
COMMUNITY=$(bashio::config 'snmp_community')
NAME=$(bashio::config 'snmp_name')
LOCATION=$(bashio::config 'snmp_location')
CONTACT=$(bashio::config 'snmp_contact')

HAOS_HOSTNAME=$(bashio::info.hostname)
HAOS_MACHINE=$(bashio::info.machine)
HAOS_OPERATING_SYSTEM=$(bashio::info.operating_system)

UN_KERNEL_NAME=$(uname -s)
UN_KERNEL_RELEASE=$(uname -r)
UN_KERNEL_VERSION=$(uname -v)
UN_MACHINE=$(uname -m)

SNMP_CONF_FILE="/etc/snmp/snmpd.conf"

cat > $SNMP_CONF_FILE <<EOF
master agentx

com2sec readonly default $COMMUNITY
sysname $NAME
syslocation $LOCATION
syscontact $CONTACT
sysdescr $UN_KERNEL_NAME $HAOS_HOSTNAME $UN_KERNEL_RELEASE $UN_KERNEL_VERSION $UN_MACHINE ($HAOS_OPERATING_SYSTEM)

group MyROGroup v2c readonly
view all included .1 80
access MyROGroup "" any noauth exact all none none

# hass data
extend hass_docker_version '/usr/bin/bashio /bashio_info.sh docker'
extend hass_hassos_version '/usr/bin/bashio /bashio_info.sh hassos'
extend hass_homeassistant_version '/usr/bin/bashio /bashio_info.sh homeassistant'
extend hass_supervisor_version '/usr/bin/bashio /bashio_info.sh supervisor'
extend hass_state '/usr/bin/bashio /bashio_info.sh state'
extend hass_supported '/usr/bin/bashio /bashio_info.sh supported'

#libreNMS distro detection
extend distro '/bin/echo $HAOS_OPERATING_SYSTEM'
EOF

if [[ "$UN_MACHINE" == "x86"* ]]; then
cat >> $SNMP_CONF_FILE <<EOF
#libreNMS Hardware Detection
extend manufacturer '/bin/cat /sys/devices/virtual/dmi/id/sys_vendor'
extend hardware '/bin/cat /sys/devices/virtual/dmi/id/product_name'
extend serial '/bin/cat /sys/devices/virtual/dmi/id/product_serial'
EOF
elif [[ "$UN_MACHINE" == "arm"* ]] || [[ "$UN_MACHINE" == "aarch64"* ]]; then
cat >> $SNMP_CONF_FILE <<EOF
#libreNMS Hardware Detection
extend hardware '/bin/echo $HAOS_MACHINE'
EOF
fi

# Run daemon
bashio::log.info "Starting the snmpd daemon..."
snmpd -f -LSwd
