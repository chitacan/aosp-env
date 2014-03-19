include curl

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

class repo {
  curl::fetch { 'repo':
    source      => 'http://commondatastorage.googleapis.com/git-repo-downloads/repo',
    destination => '/usr/bin/repo'
  } ->
  file { 'change-premission':
    path => '/usr/bin/repo',
    mode => 'ugo+x'
  } ->
  file { ['/home/vagrant/workspace', '/home/vagrant/workspace/android-4.4_r1']:
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  exec { 'init':
    path    => '/usr/bin',
    cwd     => '/home/vagrant/workspace/android-4.4_r1/',
    command => 'repo init -u https://android.googlesource.com/platform/manifest -b android-4.4_r1',
    user    => 'vagrant',
    returns => 1
  }
}

class packages {
  package {
    'gnupg':
      ensure => 'latest';
    'flex':
      ensure => 'installed';
    'bison':
      ensure => 'installed';
    'zip':
      ensure => 'installed';
    'gperf':
      ensure => 'installed';
    'libc6-dev':
      ensure => 'installed';
    'libncurses5-dev:i386':
      ensure => 'installed';
    'x11proto-core-dev':
      ensure => 'installed';
    'libx11-dev:i386':
      ensure => 'installed';
    'libreadline6-dev:i386':
      ensure => 'installed';
    'libgl1-mesa-glx:i386':
      ensure => 'installed';
    'libgl1-mesa-dev':
      ensure => 'installed';
    'g++-multilib':
      ensure => 'installed';
    'mingw32':
      ensure => 'installed';
    'tofrodos':
      ensure => 'installed';
    'python-markdown':
      ensure => 'installed';
    'libxml2-utils':
      ensure => 'installed';
    'xsltproc':
      ensure => 'installed';
    'zlib1g-dev:i386':
      ensure => 'installed';
  } ->
  file { '/usr/lib/i386-linux-gnu/libGL.so':
    ensure => 'link',
    target => '/usr/lib/i386-linux-gnu/mesa/libGL.so.1'
  }
}

Exec['update']    ->
Package['psp']    ->
class { 'tmux': } ->
class { 'git': }  ->
class { 'java': } ->
class { 'repo': } ->
class { 'packages': }
