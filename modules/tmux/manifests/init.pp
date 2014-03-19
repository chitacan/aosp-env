# == Class: tmux
#
# Grabs tmux latested source and configure; make; make install;#s
#
# === Examples
#
#  include tmux
#
# === Authors
#
# Vincent Palmer <shift@someone.section.me>
#
# === Copyright
#
# Copyright 2013 Vincent Palmer
#
class tmux($version = '1.8') {

  case $::operatingsystem {
    Debian,Ubuntu:  { include tmux::debian}
    default:        {
      notice "Unsupported operatingsystem ${::operatingsystem}"
    }
  }

  exec {'download':
    cwd     => '/tmp',
    path    => ['/usr/bin', '/bin'],
    command =>
      "wget http://downloads.sourceforge.net/tmux/tmux-${version}.tar.gz",
    creates => "/tmp/tmux-${version}.tar.gz"
  }
  exec {'extract':
    cwd     => '/tmp',
    path    => ['/usr/bin', '/bin'],
    command => "tar xfvz tmux-${version}.tar.gz",
    creates => "/tmp/tmux-${version}",
    require => Exec['download']
  }

  exec {'configure':
    cwd     => "/tmp/tmux-${version}",
    path    => ['/usr/bin', '/bin'],
    command => 'bash -c "./configure"',
    creates => "/tmp/tmux-${version}/config.status",
    require => [Package[libevent-dev],
                Package[libncurses-dev],
                Package[build-essential],
                Exec[extract]]
  }

  exec {'make':
    cwd     => "/tmp/tmux-${version}",
    path    => ['/usr/bin', '/bin'],
    command => 'bash -c make',
    creates => "/tmp/tmux-${version}/tmux",
    require => Exec['configure']
  }

  exec {'install':
    cwd     => "/tmp/tmux-${version}",
    path    => ['/usr/bin', '/bin'],
    command => 'bash -c "make install"',
    creates => '/usr/local/bin/tmux',
    require => Exec['make'],
  }

}
