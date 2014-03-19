# Class: gitolite
#
# This installs and configures gitolite 
#
# Requires:
#  - Class[git]
#
class git::gitolite($pubkey) {
  include ::git
  package {'gitolite':
    ensure => present
  }

  user { "git":
    system => true,
    ensure => present,
    managehome => true,
  }

  exec { "/usr/bin/gl-setup -q $pubkey":
    user => "git",
    environment => "HOME=/home/git",
    creates => "/home/git/.gitolite.rc",
    require => [User[git], Package[gitolite]],
  }
}
# from https://raw.github.com/Linux2Go/puppetlabs-git/master/manifests/gitolite.pp
