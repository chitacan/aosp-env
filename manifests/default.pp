package { 'apache2':
  ensure => 'installed',
}

file { 'site-config':
  path => '/etc/apache2/sites-enabled/000-default',
  source => '/vagrant/manifests/site-config',
  require => Package['apache2'],
}

service { 'apache2':
  ensure => 'running',
  hasrestart => true,
  subscribe => File['site-config']
}

file { '/vagrant/index.html':
  content => '<h1> vagrant + puppet</h1>',
}
