include curl

exec { 'update':
  path    => '/usr/bin',
  command => 'apt-get update',
}

package { 'psp':
  name   => 'python-software-properties',
  ensure => 'installed'
}

file { 'workspace':
  path   => '/home/vagrant/workspace',
  ensure => 'directory',
  owner  => 'vagrant',
  group  => 'vagrant'
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
    destination => '/usr/local/bin/repo'
  } ->
  file { 'change-premission':
    path => '/usr/local/bin/repo',
    mode => 'ugo+x',
    owner  => 'vagrant',
    group  => 'vagrant'
  }
}

define aosp (
  $branch='android-4.4_r1',
  $url = "https://android.googlesource.com/platform/manifest"
){
  $cmd_init = "repo init -u ${url} -b ${branch}"
  file { "/home/vagrant/workspace/${branch}":
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  exec { "init-${branch}":
    path      => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd       => "/home/vagrant/workspace/${branch}",
    command   => "sudo su -c '${cmd_init}' -s /bin/sh vagrant",
    user      => 'vagrant',
    group     => 'vagrant'
  }
}

class packages {
  package {[
      'gnupg',
      'git-core',
      'flex',
      'bison',
      'zip',
      'gperf',
      'libc6-dev',
      'libncurses5-dev:i386',
      'x11proto-core-dev',
      'libx11-dev:i386',
      'libreadline6-dev:i386',
      'libgl1-mesa-glx:i386',
      'libgl1-mesa-dev',
      'g++-multilib',
      'mingw32',
      'tofrodos',
      'python-markdown',
      'libxml2-utils',
      'xsltproc',
      'zlib1g-dev:i386',
    ]:
    ensure => 'installed';
  } ->
  file { '/usr/lib/i386-linux-gnu/libGL.so':
    ensure => 'link',
    target => '/usr/lib/i386-linux-gnu/mesa/libGL.so.1'
  }
}

Exec['update']         ->
Package['psp']         ->
class { 'tmux': }      ->
class { 'packages': }  ->
class { 'java': }      ->
class { 'repo': }      ->
File['workspace']      ->
aosp { 'android-4.4_r1': } ->
aosp { 'android-4.1.2_r1':
  branch => 'android-4.1.2_r1'
} ->
aosp { 'android-4.3_r1':
  branch => 'android-4.3_r1'
}
