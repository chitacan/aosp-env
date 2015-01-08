include curl
include apt

$PPA_REPO = ['ppa:webupd8team/java', 'ppa:pi-rho/dev', 'ppa:chris-lea/node.js']
$HOME     = '/home/vagrant'
$GITHUB   = 'https://github.com'
$BREW_BIN = "${HOME}/.linuxbrew/bin"
$PATH     = [$BREW_BIN, '/bin', '/usr/bin', '/usr/local/bin', '/opt/vagrant_ruby/bin']
exec { 'update':
  path    => $PATH,
  command => 'apt-get update'
}

class conf {
  # install configuration files
  file { "${HOME}/.tmux.conf":
    source => '/vagrant/files/tmux.conf',
    mode   => 600,
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  file { "${HOME}/.vimrc":
    source => '/vagrant/files/vimrc',
    mode   => 600,
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  file { "${HOME}/.bash_profile":
    source => '/vagrant/files/bash_profile',
    mode   => 600,
    owner  => 'vagrant',
    group  => 'vagrant'
  } ->
  exec { "${HOME}/.bash_logout":
    path    => $PATH,
    command => "echo 'echo -ne \"\\\033]6;1;bg;*;default\\\a\"' >> ${HOME}/.bash_logout"
  }
}

class vimbundle{
  define plugin(
    $gh_user,
    $gh_repo,
    $install = "rsync -r /tmp/${gh_repo}-master/ ${HOME}/.vim/"
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
      path        => $PATH,
      command     => "unzip /tmp/${name}.zip -d /tmp -x '*.gitignore' 'README.*' 'LICENSE*' ",
      user        => 'vagrant',
      group       => 'vagrant',
      refreshonly => true
    } ->
    exec { "install-${name}":
      path    => $PATH,
      command => $install,
      cwd     => "/tmp/${gh_repo}-master/",
      user    => 'vagrant',
      group   => 'vagrant'
    }
  }
  file { ["${HOME}/.vim", "${HOME}/.vim/colors"]:
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
    install => "make && rsync -r /tmp/vimproc.vim-master/autoload /tmp/vimproc.vim-master/plugin ${HOME}/.vim/"
  } ->
  plugin { 'solarize':
    gh_user => 'altercation',
    gh_repo => 'vim-colors-solarized',
    install => "cp /tmp/vim-colors-solarized-master/colors/* ${HOME}/.vim/colors/"
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

define aosp (
  $url = "https://android.googlesource.com/platform/manifest"
){
  $cmd_init = "repo init -u ${url} -b ${title}"
  exec { "create ${title} path":
    path    => $PATH,
    command => "mkdir -p ${HOME}/workspace/${title}",
    user    => 'vagrant',
    group   => 'vagrant'
  } ~>
  exec { "repo-init ${title}":
    path        => $PATH,
    cwd         => "${HOME}/workspace/${title}",
    environment => ["HOME=${HOME}"],
    command     => $cmd_init,
    logoutput   => on_failure,
    user        => 'vagrant',
    group       => 'vagrant',
    refreshonly => true
  }
}

class brew {
  define install {
    exec { "install-${name}":
      path        => $PATH,
      command     => "brew install ${name}",
      environment => ["HOME=${HOME}"],
      logoutput   => on_failure,
      user        => 'vagrant',
      group       => 'vagrant'
    }
  }
  exec { 'install-linuxbrew':
    path      => $PATH,
    onlyif    => "test ! -f ${BREW_BIN}/brew",
    command   => "git clone ${GITHUB}/Homebrew/linuxbrew ${HOME}/.linuxbrew",
    logoutput => on_failure,
    user      => 'vagrant',
    group     => 'vagrant'
  } ->
  install { ['tig', 'pidcat', 'repo']: }
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
      'texinfo',
      'libbz2-dev',
      'libcurl4-openssl-dev',
      'libexpat-dev',
      'libncurses-dev'
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
apt::ppa { $PPA_REPO: } ->
class { 'packages': }  ->
class { 'java': }      ->
class { 'brew': } ->
aosp  { "$aospversion": } ->
class { 'conf': } ->
class { 'vimbundle': }
