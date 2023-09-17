#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

bashio::log.info "Set snmp configuration..."
COMMUNITY=$(bashio::config 'snmp_community')
NAME=$(bashio::config 'snmp_name')
LOCATION=$(bashio::config 'snmp_location')
CONTACT=$(bashio::config 'snmp_contact')
sed -i "/^com2sec readonly default.*/c\com2sec readonly default $COMMUNITY" /etc/snmp/snmpd.conf
sed -i "/^sysname.*/c\sysname $NAME" /etc/snmp/snmpd.conf
sed -i "/^syslocation.*/c\syslocation $LOCATION" /etc/snmp/snmpd.conf
sed -i "/^syscontact.*/c\syscontact $CONTACT" /etc/snmp/snmpd.conf

# Run daemon
bashio::log.info "Starting the snmpd daemon..."
snmpd -f -Le -c /etc/snmp/snmpd.conf
