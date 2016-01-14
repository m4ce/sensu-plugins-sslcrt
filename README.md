# Sensu plugin for monitoring SSL certificates

A sensu plugin to monitor the validity of SSL certificates

## Usage

The plugin accepts the following command line options:

```
Usage: check-sslcrt.rb (options)
        --connect <HOST>[:<PORT>]    This specifies the host and optional port to connect to
    -c, --crit <DAYS>                Critical if expiration date is DAYS away
    -f, --file <CERT_FILE>           This specifies the input filename to read a certificate from
    -w, --warn <DAYS>                Warn if expiration date is DAYS away
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
