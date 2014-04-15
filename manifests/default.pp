include curl
include apt

$ppa_repo = ['ppa:webupd8team/java', 'ppa:pi-rho/dev', 'ppa:chris-lea/node.js']

exec { 'update':
  path    => '/usr/bin',
  command => 'apt-get update'
}

file { 'workspace':
  path   => '/home/vagrant/workspace',
  ensure => 'directory',
  owner  => 'vagrant',
  group  => 'vagrant'
}

class conf {
  # install configuration files
  file { "/home/vagrant/.tmux.conf":
    source => '/vagrant/files/tmux.conf',
    mode   => 600,
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  file { "/home/vagrant/.vimrc":
    source => '/vagrant/files/vimrc',
    mode   => 600,
    owner  => 'vagrant',
    group  => 'vagrant'
  }
}

class vimbundle{
  define plugin(
    $gh_user,
    $gh_repo,
    $install = "rsync -r /tmp/${gh_repo}-master/ /home/vagrant/.vim/"
  ) {
    curl::fetch { $name:
      source      => "https://codeload.github.com/${gh_user}/${gh_repo}/zip/master",
      destination => "/tmp/${name}.zip"
    } ->
    file { $name:
      path  => "/tmp/${name}.zip",
      owner => 'vagrant',
      group => 'vagrant'
    } ~>
    exec { $name:
      path        => '/usr/bin',
      command     => "unzip /tmp/${name}.zip -d /tmp -x '*.gitignore' 'README.*' 'LICENSE*' ",
      user        => 'vagrant',
      group       => 'vagrant',
      refreshonly => true
    } ->
    exec { "install-${name}":
      path    => ['/bin', '/usr/bin'],
      command => $install,
      cwd     => "/tmp/${gh_repo}-master/",
      user    => 'vagrant',
      group   => 'vagrant'
    }
  }
  file { ['/home/vagrant/.vim', '/home/vagrant/.vim/colors']:
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  plugin { 'unite':
    gh_user => 'Shougo',
    gh_repo => 'unite.vim'
  } ->
  plugin { 'vundle':
    gh_user => 'gmarik',
    gh_repo => 'Vundle.vim'
  } ->
  plugin { 'fugitive':
    gh_user => 'tpope',
    gh_repo => 'vim-fugitive'
  } ->
  plugin { 'vimproc':
    gh_user => 'Shougo',
    gh_repo => 'vimproc.vim',
    install => 'make && rsync -r /tmp/vimproc.vim-master/autoload /tmp/vimproc.vim-master/plugin /home/vagrant/.vim/'
  } ->
  plugin { 'solarize':
    gh_user => 'altercation',
    gh_repo => 'vim-colors-solarized',
    install => "cp /tmp/vim-colors-solarized-master/colors/* /home/vagrant/.vim/colors/"
  }
}

class java {
  # Prepare response file
  file { "/tmp/oracle-java6-installer.preseed":
    source => '/vagrant/files/java.response',
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
  } ->
  curl::fetch { 'pidcat':
    source      => 'https://raw.githubusercontent.com/JakeWharton/pidcat/master/pidcat.py',
    destination => '/usr/local/bin/pidcat'
  } ->
  file {
    path  => '/usr/local/bin/pidcat',
    mode  => 'ugo+x',
    owner => 'vagrant',
    group => 'vagrant'
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
  } ~>
  exec { "init-${branch}":
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd         => "/home/vagrant/workspace/${branch}",
    command     => "sudo su -c '${cmd_init}' -s /bin/sh vagrant",
    user        => 'vagrant',
    group       => 'vagrant',
    refreshonly => true
  }
}

class packages {
  package {
    [
      'make',
      'nodejs',
      'tmux',
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

Exec['update'] ->
package { 'vim':
  ensure => 'installed'
} ->
apt::ppa { $ppa_repo: } ->
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
} ->
class { 'conf': } ->
class { 'vimbundle': }
