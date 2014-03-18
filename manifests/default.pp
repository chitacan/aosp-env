case $operatingsystem {
  ubuntu: {
    $apache = 'apache2'
    $configfile = '/etc/apache2/sites-enabled/000-default'
  }
}

package { 'apache':
  name   => $apache,
  ensure => 'installed',
}

file { 'site-config':
  path    => $configfile,
  source  => '/vagrant/manifests/site-config',
  require => Package['apache'],
}

service { 'apache':
  name       => $apache,
  ensure     => 'running',
  hasrestart => true,
  subscribe  => File['site-config']
}

file { '/vagrant/index.html':
  content => "<h1> vagrant + puppet + ${apache} + ${operatingsystem}</h1>",
}

if $apache == 'apache2' {
}
