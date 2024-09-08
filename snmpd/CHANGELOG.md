# Changelog

## 0.4.0
- add lldp support

## 0.3.0
- use pre-built images

## 0.2.3
- add VScode dev container
- fix supervisor api permission denied error

## 0.2.2
- add additional hass information via `NET-SNMP-EXTEND-MIB`
- fix logging to not flood the console with snmpd debug log

## 0.2.1
- fix libreNMS hardware detection for arm platforms

## 0.2

- Switch to debian base image, because the debian prebuild snmpd package comes with enabled ucd modules (_eq. disk-io_)
- add haos version to system description
- add haos system hostname to system description
- add libreNMS specific extensions
  - distro detection
  - hardware detection

## 0.1

- Initial version
