# SNMPD Home Assistant add-on

## How to use

This add-on allows you to monitor your Home Assistant installation via snmp (_v2c_).

## Configuration

Add-on configuration:

```yaml
snmp_community: pmnsssah
snmp_name: ha
snmp_location: home
snmp_contact: me
```

| key              | name             | description                                                                                                                        |
| ---------------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `snmp_community` | SNMP community   | The SNMP community string used for SNMP queries queries.                                                                           |
| `snmp_name`      | SNMP system name | An administratively-assigned name for this managed device. By convention, this is the device fully-qualified domain name.          |
| `snmp_location`  | SNMP location    | The physical location of this device                                                                                               |
| `snmp_contact`   | SNMP contact     | The textual identification of the contact person for this managed device, together with information on how to contact this person. |

## Support

In case you've found a bug, please [open an issue on our GitHub][issue].

[issue]: https://github.com/mib1185/ha-addon-snmpd/issues
