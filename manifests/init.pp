# This is the main class.  It installs and configures ngrok.

class ngrok (
  # Where to get and put things.
  String $download_url                      = 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip',
  Stdlib::Absolutepath $bin_dir             = '/usr/local/bin',
  Stdlib::Absolutepath $conf_dir            = '/etc',

  # What to put in the global configuration.
  Optional[String] $authtoken               = undef,
  Optional[String] $region                  = undef,
  Optional[String] $console_ui              = undef,
  Optional[String] $compress_conn           = undef,
  Optional[String] $http_proxy              = undef,
  Optional[String] $inspect_db_size         = undef,
  Optional[String] $log_level               = undef,
  Optional[String] $log_format              = undef,
  Optional[String] $log                     = undef,
  Optional[String] $metadata                = undef,
  Optional[String] $root_cas                = undef,
  Optional[String] $socks5_proxy            = undef,
  Optional[String] $update                  = undef,
  Optional[String] $update_channel          = undef,
  Optional[String] $web_addr                = undef,

  # Whether to manage the service, and which tunnels to start with it.
  Boolean $service_manage                   = true,
  String  $service_state                    = 'running',
  String  $service_tunnels                  = '--all',

) {

  # Let's make sure ..
  if ( $::kernel != 'Linux' ) {
    fail("The ngrok module does not yet work on ${::operatingsystem}")
  }

  # Download the package and uncompress it into a bin directory.
  archive { '/tmp/ngrok.zip':
    source       => $download_url,
    extract      => true,
    extract_path => $bin_dir,
    creates      => "${bin_dir}/ngrok",
  }

  # Make the config file a concat target.
  concat { "${conf_dir}/ngrok.yml":
    notify => $service_manage ? {
      true  => Service['ngrok'],
      false => undef,
    }
  }

  # Throw the global options into the config file, at the top.
  concat::fragment { 'ngrok.yml main':
    target  => "${conf_dir}/ngrok.yml",
    content => template('ngrok/ngrok_main.yml.erb'),
    order   => '00',
  }

  # Manage whether ngrok runs in the background or not.
  if $service_manage {
    service { 'ngrok':
      ensure    => $service_state,
      provider  => base,
      hasstatus => false,
      start     => "nohup ${bin_dir}/ngrok start ${service_tunnels} -config ${conf_dir}/ngrok.yml &",
      pattern   => 'ngrok',
    }
  }

}
