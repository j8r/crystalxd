# CrystaLXD

Crystal client for the [LXD](https://linuxcontainers.org/lxd/) REST API.

[![Build Status](https://cloud.drone.io/api/badges/j8r/crystalxd/status.svg)](https://cloud.drone.io/j8r/crystalxd)
[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

## Prerequisites

### Setup

[Install the LXD package](https://linuxcontainers.org/lxd/getting-started-cli/)

Add yourself to the lxd group, so you can run lxc without being root:

`sudo usermod -aG lxd $USER`

Then logout and login again.

Before running containers, LXD must be configured:

`lxd init --auto --storage-backend btrfs --network-address '[::1]'`

The default port is `8443` HTTPS.

[Other backends are also available](https://lxd.readthedocs.io/en/latest/storage/#storage-backends-and-supported-functions), depending of the needs.

### Certificates

The LXD daemon run as root, that's why its API uses [TLS certificates](https://lxd.readthedocs.io/en/latest/security/) for encryption and authentication.

In this directory, create self-signed certificates:
```
mkdir -p certs && cd certs

openssl ecparam -name secp521r1 -genkey -noout -out lxd.key
openssl req -new -sha256 -newkey rsa:4096 -key lxd.key -out lxd.csr -subj "/CN=CrystaLXD specs"
openssl x509 -days 365 -signkey lxd.key -in lxd.csr -req -out lxd.crt
```

Then add the certificate to the trust store:
`lxc config trust add lxd.crt`

If you want to remove one:
`lxc config trust remove <FINGERPRINT>`

## Documentation

CrystaLXD documentation: https://j8r.github.io/con

This library is based on the [official LXD REST API document](https://github.com/lxc/lxd/blob/master/doc/rest-api.md).

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  crystalxd:
    github: j8r/crystalxd
```

## Documentation

https://j8r.github.io/crystalxd

## Usage

```cr
require "crystalxd"

CLIENT = CrystaLXD::Client.new(
  tls: OpenSSL::SSL::Context::Client.from_hash({
    "key"         => "certs/lxd.key",
    "cert"        => "certs/lxd.crt",
    "verify_mode" => "none",
  })
)
```

## Running test specs

`crystal spec`

**Warning**: The specs will try as much as possible to restore the initial LXD state,
but there is no guarantees of any kind.

## License

Copyright (c) 2019 Julien Reichardt - ISC License
