# chronyd

#### Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [Beginning with chronyd](#beginning-with-chronyd)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Limitations](#limitations)

## Description

Configures the chrony daemon in RHEL 7.

This module installs and configures the chrony package, service, and configuration files.

## Setup

### Beginning with chronyd

To set up chrony with default values:

```puppet
class { '::chronyd':
  servers => ['0.au.pool.ntp.org','1.au.pool.ntp.org'],
}
```

## Reference

**Parameters:**

`servers`: The list of NTP servers to connect to

`keyfile_hash`: A hash of keys to install in the format `{ key_id => key_data }`. Defaults to an empty hash

`package_name`: Name of the package to install, defaults to `chrony`

`config_path`: Path to the config file, defaults to `/etc/chrony.conf`

`template_name`: Template to use, modify this if the default template does not have enough flexibility. Defaults to `chronyd/chrony.conf.epp`

`service_name`: The service to manage, defaults to `chronyd`

`package_ensure`: Defaults to `present`

`template_hash`: Hash of local variables to pass to the template, only useful combination with `template_name`

`service_ensure`: Defaults to `running`

`service_enable`: Defaults to `true`

`iburst`: Whether to use iburst, defaults to `true`

`stratumweight`: Does [this](http://chrony.tuxfamily.org/manual.html#stratumweight-directive), defaults to `0`

`drift_file`: Defaults to `/var/lib/chrony/drift`

`rtcsync`: Defaults to `true`

`makestep`: Defaults to `true`

`step_threshold`: Defaults to `0.1`

`step_number`: Defaults to `10`

`ipv4_bindaddress`: Defaults to `'127.0.0.1'`

`ipv6_bindaddress`: Defaults to `'::1'`

`keyfile`: Defaults to `'/etc/chrony.keys'`

`noclientlog`: Defaults to `false`

`logchange_value`: Defaults to `1`

`logdir`: Defaults to `'/var/log/chrony'`

`template_keyfile`: Defaults to `chronyd/keyfile.epp`

`keyfile_path`: Defaults to `/etc/chrony.keys`

`replace_keyfile`: Defaults to `true`

## Limitations

This is only tested on RHEL 7
