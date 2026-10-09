#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

bashio::log.info "Set snmp configuration..."
VERSION=$(bashio::config 'snmp_version' 'v2c')
COMMUNITY=$(bashio::config 'snmp_community')
NAME=$(bashio::config 'snmp_name')
LOCATION=$(bashio::config 'snmp_location')
CONTACT=$(bashio::config 'snmp_contact')
PORT=$(bashio::config 'snmp_port')
LLDP_ENABLED=$(bashio::config 'lldp_enabled')

HAOS_HOSTNAME=$(bashio::info.hostname)
HAOS_MACHINE=$(bashio::info.machine)
HAOS_OPERATING_SYSTEM=$(bashio::info.operating_system)

UN_KERNEL_NAME=$(uname -s)
UN_KERNEL_RELEASE=$(uname -r)
UN_KERNEL_VERSION=$(uname -v)
UN_MACHINE=$(uname -m)

SNMPD_CONF_FILE="/etc/snmp/snmpd.conf"
SNMPD_PERSISTENT_CONF_FILE="/var/lib/snmp/snmpd.conf"
LLDPD_CONF_FILE="/etc/lldpd.d/ha.conf"

# escape a value to be used as quoted string in snmpd config
quote() {
    local value="${1//\\/\\\\}"
    echo "\"${value//\"/\\\"}\""
}

if [[ "$VERSION" == "v3" ]]; then
    V3_USERNAME=$(bashio::config 'snmp_v3_username')
    V3_SECURITY_LEVEL=$(bashio::config 'snmp_v3_security_level' 'authPriv')
    V3_AUTH_PROTOCOL=$(bashio::config 'snmp_v3_auth_protocol' 'SHA')
    V3_AUTH_PASSWORD=$(bashio::config 'snmp_v3_auth_password')
    V3_PRIVACY_PROTOCOL=$(bashio::config 'snmp_v3_privacy_protocol' 'AES')
    V3_PRIVACY_PASSWORD=$(bashio::config 'snmp_v3_privacy_password')

    if ! bashio::config.has_value 'snmp_v3_username' || [[ ! "$V3_USERNAME" =~ ^[^[:space:]\"\'\\]+$ ]]; then
        bashio::exit.nok "SNMPv3 requires a username without whitespaces or quotes (snmp_v3_username)"
    fi
    if ! bashio::config.has_value 'snmp_v3_auth_password' || [[ ${#V3_AUTH_PASSWORD} -lt 8 ]]; then
        bashio::exit.nok "SNMPv3 requires an authentication password with at least 8 characters (snmp_v3_auth_password)"
    fi

    V3_USER_ENTRY="createUser $V3_USERNAME $V3_AUTH_PROTOCOL $(quote "$V3_AUTH_PASSWORD")"
    if [[ "$V3_SECURITY_LEVEL" == "authPriv" ]]; then
        if ! bashio::config.has_value 'snmp_v3_privacy_password' || [[ ${#V3_PRIVACY_PASSWORD} -lt 8 ]]; then
            bashio::exit.nok "SNMPv3 with security level authPriv requires a privacy password with at least 8 characters (snmp_v3_privacy_password)"
        fi
        V3_USER_ENTRY="$V3_USER_ENTRY $V3_PRIVACY_PROTOCOL $(quote "$V3_PRIVACY_PASSWORD")"
        V3_ACCESS_LEVEL="priv"
    else
        V3_ACCESS_LEVEL="auth"
    fi

    # snmpd reads createUser from its persistent config and replaces it by the localized keys,
    # so drop previously stored users to ensure changed credentials are applied
    mkdir -p "$(dirname "$SNMPD_PERSISTENT_CONF_FILE")"
    touch "$SNMPD_PERSISTENT_CONF_FILE"
    sed -i '/^\(usmUser\|createUser\) /d' "$SNMPD_PERSISTENT_CONF_FILE"
    echo "$V3_USER_ENTRY" >> "$SNMPD_PERSISTENT_CONF_FILE"

    ACCESS_CONFIG="group MyROGroup usm $V3_USERNAME
view all included .1 80
access MyROGroup \"\" usm $V3_ACCESS_LEVEL exact all none none"
else
    ACCESS_CONFIG="com2sec readonly default $COMMUNITY
group MyROGroup v2c readonly
view all included .1 80
access MyROGroup \"\" any noauth exact all none none"
fi

cat > $SNMPD_CONF_FILE <<EOF
master agentx
agentAddress udp:$PORT,udp6:$PORT

sysname $NAME
syslocation $LOCATION
syscontact $CONTACT
sysdescr $UN_KERNEL_NAME $HAOS_HOSTNAME $UN_KERNEL_RELEASE $UN_KERNEL_VERSION $UN_MACHINE ($HAOS_OPERATING_SYSTEM)

$ACCESS_CONFIG

# hass data
extend hass_docker_version '/usr/bin/bashio /bashio_info.sh docker'
extend hass_hassos_version '/usr/bin/bashio /bashio_info.sh hassos'
extend hass_homeassistant_version '/usr/bin/bashio /bashio_info.sh homeassistant'
extend hass_supervisor_version '/usr/bin/bashio /bashio_info.sh supervisor'
extend hass_state '/usr/bin/bashio /bashio_info.sh state'
extend hass_supported '/usr/bin/bashio /bashio_info.sh supported'

# libreNMS distro detection
extend distro '/bin/echo $HAOS_OPERATING_SYSTEM'
EOF

if [[ "$UN_MACHINE" == "x86"* ]]; then
cat >> $SNMPD_CONF_FILE <<EOF
# libreNMS Hardware Detection
extend manufacturer '/bin/cat /sys/devices/virtual/dmi/id/sys_vendor'
extend hardware '/bin/cat /sys/devices/virtual/dmi/id/product_name'
extend serial '/bin/cat /sys/devices/virtual/dmi/id/product_serial'
EOF
elif [[ "$UN_MACHINE" == "arm"* ]] || [[ "$UN_MACHINE" == "aarch64"* ]]; then
cat >> $SNMPD_CONF_FILE <<EOF
# libreNMS Hardware Detection
extend hardware '/bin/echo $HAOS_MACHINE'
EOF
fi

# write lldpd config
cat > $LLDPD_CONF_FILE <<EOF
configure system hostname $NAME
configure system description "$UN_KERNEL_NAME $HAOS_HOSTNAME $UN_KERNEL_RELEASE $UN_KERNEL_VERSION $UN_MACHINE ($HAOS_OPERATING_SYSTEM)"
configure system interface pattern *,!veth
EOF

# start LLDPd
if [[ "$LLDP_ENABLED" == "true" ]]; then
bashio::log.info "Starting the lldpd daemon..."
lldpd -x
fi

# Run daemon
bashio::log.info "Starting the snmpd daemon (SNMP $VERSION) on port $PORT..."
snmpd -f -LSwd
