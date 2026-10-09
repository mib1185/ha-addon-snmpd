# SNMPD Home Assistant add-on

## How to use

This add-on allows you to monitor your Home Assistant installation via snmp (_v2c_ or _v3_).

## Configuration

Add-on configuration:

```yaml
snmp_name: ha
snmp_location: home
snmp_contact: me
snmp_port: 161
lldp_enabled: false
snmp_version: v2c
snmp_community: pmnsssah
snmp_v3_security_level: authPriv
snmp_v3_auth_protocol: SHA
snmp_v3_privacy_protocol: AES
```

| key                        | name                           | description                                                                                                                        |
| -------------------------- | ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `snmp_name`                | SNMP system name               | An administratively-assigned name for this managed device. By convention, this is the device fully-qualified domain name.          |
| `snmp_location`            | SNMP location                  | The physical location of this device                                                                                               |
| `snmp_contact`             | SNMP contact                   | The textual identification of the contact person for this managed device, together with information on how to contact this person. |
| `snmp_port`                | SNMP port                      | The UDP port the snmpd daemon listens on. Defaults to `161`. You might want to change it to avoid conflicts with other apps.       |
| `lldp_enabled`             | LLDP                           | Enable or disable the lldp support.                                                                                                |
| `snmp_version`             | SNMP version                   | The SNMP version to use, either `v2c` (community based, default) or `v3` (user based with authentication and optional encryption). |
| `snmp_community`           | SNMP community                 | The SNMP community string used for SNMP queries. Only used with SNMP version `v2c`.                                                |
| `snmp_v3_username`         | SNMPv3 username                | The username for SNMPv3 queries. Required for SNMP version `v3`.                                                                   |
| `snmp_v3_security_level`   | SNMPv3 security level          | `authPriv` (authentication and encryption, default) or `authNoPriv` (authentication only).                                         |
| `snmp_v3_auth_protocol`    | SNMPv3 authentication protocol | One of `MD5`, `SHA` (default), `SHA-224`, `SHA-256`, `SHA-384` or `SHA-512`.                                                       |
| `snmp_v3_auth_password`    | SNMPv3 authentication password | The authentication password (at least 8 characters). Required for SNMP version `v3`.                                               |
| `snmp_v3_privacy_protocol` | SNMPv3 privacy protocol        | One of `AES` (default) or `DES`. Only used with security level `authPriv`.                                                         |
| `snmp_v3_privacy_password` | SNMPv3 privacy password        | The encryption password (at least 8 characters). Required for security level `authPriv`.                                           |

### SNMPv3

To use SNMPv3, set `snmp_version` to `v3` and configure at least `snmp_v3_username` and `snmp_v3_auth_password` (_and `snmp_v3_privacy_password` when using the default security level `authPriv`_). The `snmp_community` is not used with SNMPv3 and SNMPv2c queries are rejected.

Example add-on configuration:

```yaml
snmp_name: ha
snmp_location: home
snmp_contact: me
snmp_port: 161
lldp_enabled: false
snmp_version: v3
snmp_community: pmnsssah
snmp_v3_username: monitoring
snmp_v3_security_level: authPriv
snmp_v3_auth_protocol: SHA-256
snmp_v3_auth_password: my-auth-password
snmp_v3_privacy_protocol: AES
snmp_v3_privacy_password: my-privacy-password
```

Example query:

```shell
snmpwalk -v3 -l authPriv -u monitoring -a SHA-256 -A my-auth-password -x AES -X my-privacy-password my.ha.local system
```

## Support

In case you've found a bug, please [open an issue on our GitHub][issue].

[issue]: https://github.com/mib1185/ha-addon-snmpd/issues
