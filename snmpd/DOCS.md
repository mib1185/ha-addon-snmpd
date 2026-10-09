# SNMPD Home Assistant app

## How to use

This app allows you to monitor your Home Assistant installation via snmp (_v2c_ or _v3_).

## Configuration

App configuration:

```yaml
snmp_name: ha
snmp_location: home
snmp_contact: me
snmp_port: 161
lldp_enabled: false
snmp_version: v2c
snmp_v2:
  community: pmnsssah
snmp_v3:
  security_level: authPriv
  auth_protocol: SHA
  privacy_protocol: AES
```

| key             | name              | description                                                                                                                        |
| --------------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `snmp_name`     | SNMP system name  | An administratively-assigned name for this managed device. By convention, this is the device fully-qualified domain name.          |
| `snmp_location` | SNMP location     | The physical location of this device                                                                                               |
| `snmp_contact`  | SNMP contact      | The textual identification of the contact person for this managed device, together with information on how to contact this person. |
| `snmp_port`     | SNMP port         | The UDP port the snmpd daemon listens on. Defaults to `161`. You might want to change it to avoid conflicts with other apps.       |
| `lldp_enabled`  | LLDP              | Enable or disable the lldp support.                                                                                                |
| `snmp_version`  | SNMP version      | The SNMP version to use, either `v2c` (community based, default) or `v3` (user based with authentication and optional encryption). |
| `snmp_v2`       | SNMP v2c settings | Settings related to SNMP v2c, see [SNMPv2c](#snmpv2c).                                                                             |
| `snmp_v3`       | SNMP v3 settings  | Settings related to SNMP v3, see [SNMPv3](#snmpv3).                                                                                |

### SNMPv2c

SNMPv2c is used by default (`snmp_version: v2c`). The settings are grouped below `snmp_v2`:

| key         | name           | description                                      |
| ----------- | -------------- | ------------------------------------------------ |
| `community` | SNMP community | The SNMP community string used for SNMP queries. |

Example query:

```shell
snmpwalk -v2c -c pmnsssah my.ha.local system
```

### SNMPv3

To use SNMPv3, set `snmp_version` to `v3` and configure at least `username` and `auth_password` (_and `privacy_password` when using the default security level `authPriv`_) below `snmp_v3`. The settings below `snmp_v2` are not used with SNMPv3 and SNMPv2c queries are rejected.

| key                | name                           | description                                                                                |
| ------------------ | ------------------------------ | ------------------------------------------------------------------------------------------ |
| `username`         | SNMPv3 username                | The username for SNMPv3 queries. Required for SNMP version `v3`.                           |
| `security_level`   | SNMPv3 security level          | `authPriv` (authentication and encryption, default) or `authNoPriv` (authentication only). |
| `auth_protocol`    | SNMPv3 authentication protocol | One of `MD5`, `SHA` (default), `SHA-224`, `SHA-256`, `SHA-384` or `SHA-512`.               |
| `auth_password`    | SNMPv3 authentication password | The authentication password (at least 8 characters). Required for SNMP version `v3`.       |
| `privacy_protocol` | SNMPv3 privacy protocol        | One of `AES` (default) or `DES`. Only used with security level `authPriv`.                 |
| `privacy_password` | SNMPv3 privacy password        | The encryption password (at least 8 characters). Required for security level `authPriv`.   |

Example app configuration:

```yaml
snmp_name: ha
snmp_location: home
snmp_contact: me
snmp_port: 161
lldp_enabled: false
snmp_version: v3
snmp_v2:
  community: pmnsssah
snmp_v3:
  username: monitoring
  security_level: authPriv
  auth_protocol: SHA-256
  auth_password: my-auth-password
  privacy_protocol: AES
  privacy_password: my-privacy-password
```

Example query:

```shell
snmpwalk -v3 -l authPriv -u monitoring -a SHA-256 -A my-auth-password -x AES -X my-privacy-password my.ha.local system
```

## Support

In case you've found a bug, please [open an issue on GitHub][issue].

[issue]: https://github.com/mib1185/ha-addon-snmpd/issues

## You like my work?

<a href="https://www.buymeacoffee.com/mib1185" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="41" width="174"></a>
