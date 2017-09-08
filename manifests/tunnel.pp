# This is a defined type to define tunnels.  It simply creates concat fragments
# that it adds to the main ngrok.yml file.  I'd rather use a conf.d sort of
# pattern, but the app's -config directive won't take a wildcard.
#
# See the docs for information on the options:
#     https://ngrok.com/docs#tunnel-definitions

define ngrok::tunnel (
  String $tunnel_name                             = $title,

  # Options that a tunnel can have.
  Enum['http','tcp','tls'] $proto                 = 'http',
  String $addr                                    = '80',
  Optional[Boolean] $inspect                      = undef,
  Optional[String] $auth                          = undef,
  Optional[String] $host_header                   = undef,
  Optional[Enum['true','false','both']] $bind_tls = undef,
  Optional[String] $subdomain                     = undef,
  Optional[String] $hostname                      = undef,
  Optional[Stdlib::Absolutepath] $crt             = undef,
  Optional[Stdlib::Absolutepath] $key             = undef,
  Optional[Stdlib::Absolutepath] $client_cas      = undef,
  Optional[String] $remote_addr                   = undef,
) {

  # Make sure there's a 'tunnels' header in the config file
  if !defined(Concat::Fragment['tunnels heading']) {
    concat::fragment { 'tunnels heading':
      target => "${ngrok::conf_dir}/ngrok.yml",
      content => "tunnels:\n",
      order   => '50',
    }
  }

  # Build up a concat fragment, so we can add this tunnel to the config file.
  concat::fragment { "define ngrok tunnel '${tunnel_name}'":
    target  => "${ngrok::conf_dir}/ngrok.yml",
    content => template('ngrok/ngrok_tunnel.yml.erb'),
    order   => '51',
  }

}
