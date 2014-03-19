exec { 'update':
  path    => '/usr/bin',
  command => 'apt-get update',
}

package { 'psp':
  name   => 'python-software-properties',
  ensure => 'installed'
}

class java {
  class { 'apt': }
  apt::ppa { 'ppa:webupd8team/java': } ->
  # Prepare response file
  file { "/tmp/oracle-java6-installer.preseed":
    source => '/vagrant/java.response',
    mode   => 600,
    backup => false,
  } ->
  # Install Java
  package { "oracle-java6-installer":
    ensure       => "installed",
    responsefile => '/tmp/oracle-java6-installer.preseed'
  } ->
  package { "oracle-java6-set-default": ensure => "installed" }
}

Exec['update']    ->
Package['psp']    ->
class { 'tmux': } ->
class { 'git': }  ->
class { 'java': }
