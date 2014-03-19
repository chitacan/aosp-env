# == Class: tmux::debian
#
# Takes care of Debian specific build deps.
#
# === Authors
#
# Vincent Palmer <shift@someone.section.me>
#
# === Copyright
#
# Copyright 2013 Vincent Palmer
#
class tmux::debian {
  package { 'libevent-dev':
    ensure => installed,
    alias  => 'libevent-dev'
  }
  package { 'libncurses-dev':
    ensure => installed,
    alias  => 'libncurses-dev'
  }
  package { 'build-essential':
    ensure => installed,
    alias  => 'build-essential'
  }
}
