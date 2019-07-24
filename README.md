
# Overview

This module will install and configure the ngrok tunnel utility for you, and configure tunnels.  By default, it places the ngrok binary in /usr/local/bin, and its configuration file in /etc/ngrok.yml.  By default, it starts an ngrok process, activating all defined tunnels.

In other words, including the class and declaring a single ngrok::tunnel resource should result in that tunnel being active once the Puppet run is complete.

Class and defined type parameters match the ones you'll find in the config file, so for the most part, declaring these matches what you've been typing on the command line or in a config file.

Once ngrok is running, you can verify which tunnels are running with a `curl` command.

```
curl http://localhost:4040/api/tunnels
```


# Usage

## Single http tunnel

Suppose you simply want to tunnel an http connection to your local port 80.  Include the class and declare a single tunnel.

```puppet
include ngrok
ngrok::tunnel { 'web traffic':
  proto => 'http',
  addr  => '80',
}
```

## Specifying an auth token and tcp

If you want to use tcp connections, you'll need to have an account on ngrok.com.  After you login there, it tells you what your token is.  Armed with this, you can declare the class and a defined type for a tcp tunnel.  This example would be useful on a Puppet master running code manager, to allow outside machines to hit its code deployment API.

```puppet
class { 'ngrok':
  authtoken       => '0lkjaidwshytMGYT3dyy0928301983C2b7H2Mw5RnnqvZY',
}

ngrok::tunnel { 'webhook':
  proto => 'tcp',
  addr  => '8170',
}
```

## Install and configure, but don't run

You might like to install and configure ngrok, but not start up the service.  There's a parameter to the main class for that.

```puppet
class { 'ngrok':
  service_manage => false,
}
```

## Start ngrok, but don't start tunnels

You might want to define a bunch of tunnels, and have ngrok running, but not have it automatically start any of those tunnels.  Use the `service_tunnels` parameter to instruct ngrok to not automatically enable any tunnels.

```puppet
class { 'ngrok':
  service_tunnels => '--none',
}
ngrok::tunnel { 'web':
  proto => 'http',
  port  => '80',
}
ngrok::tunnel { 'app':
  proto => 'http',
  port  => 'app.mine.nat:8080',
}
ngrok::tunnel { 'ssh':
  proto => 'tcp',
  port  => 'bastion.mine.nat:22',
}
```

# Reference

## Classes

### ngrok

The main and only class, this installs and does the main configuration of ngrok on a system.  It has sensible defaults for the location of the binary and configuration file, but you can override those.

#### `download_url`

Where to pull the zip file from.  The default grabs the 64-bit Linux version.

#### `bin_dir`

Where to put the ngrok binary.  By default, it goes in `/usr/local/bin`

#### `conf_dir`

Where to put he `ngrok.yaml` file.  By default, drops it right in `/etc`

There are also a few parameters for telling Puppet what to do (or if) with the service.

#### `service_manage`

Whether to even bother managing the ngrok service.  Defaults to `true`

#### `service_state`

If we're managing the service, what state should it be in.  Default: `running`

#### `service_tunnels`

When activating the service, this string is tacked on to the command, to instruct ngrok which tunnels to automatically enable at that time.  The default is '-all'.  Note that if you don't declare any `ngrok::tunnel` resources, you will need to set this to '--none' as ngrok will error out if there are no tunnels defined and you say '--all'.  It can also take a space-separated list of tunnel names to start.  Remember, you will need an auth token (login to ngrok.com to see it) if you want to run tcp tunnels.

#### Other paramters

The ngrok class also exposes parameters for each possible main configuration options.  A detailed list of those options is available on the ngrok.com site itself at:  https://ngrok.com/docs#config-options


## Defined Types

### `ngrok::tunnel`

This type adds tunnel stanzas to the main ngrok configuration file.  All of the attributes that it can accept match the names of options that a tunnel's yaml can contain.  For a list of these, with descriptions, see the main ngrok.com documentation page at:  https://ngrok.com/docs#tunnel-definitions


## Facts

### `ngrok`

This fact lists the active tunnels, as reported by the API.


# Limitations

This module doesn't try to save you from invalid configurations.  For instance, it's possible to omit your auth token, and then try to run some tcp tunnels, which fail without an auth token.  Puppet does not know about this situation, and will quietly try to start the service on every run.

If you see the runs starting the service on every try, but the service isn't actually running, try to start ngrok by hand to see what's going on.

I'm putting it down as a 'to-do' item to write some clever facts.  Things like the 'tunnels' API end point expose some information that could be useful as facts.  It's the confinement of the fact that gets tricky.
