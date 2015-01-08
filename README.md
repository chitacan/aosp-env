# aosp-env

Provision [AOSP](http://s.android.com/index.html) development environment on [Ubuntu 12.04 LTS 64-bit](https://vagrantcloud.com/hashicorp/precise64) with puppet.

## How to use

* Make sure you have [Virtualbox](https://www.virtualbox.org/), [Vagrant](http://www.vagrantup.com/) (1.5.0 or higher) on your machine.

* Download or clone this repo.

```
$ git clone https://github.com/chitacan/aosp-env
$ cd aosp-env
```

* Update your virtual machine configuration.

```
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory",          (1024*16).to_s]
    vb.customize ["modifyvm", :id, "--cpus",            "8"   ]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"  ]
  end
```

* Modify AOSP version on `Vagrantfile`

```
  config.vm.provision "puppet" do |puppet|
    puppet.facter = {
      "aospversion" => "android-4.4_r1"
    }
  end
```

> [Available AOSP
  versions](https://android.googlesource.com/platform/manifest/+refs)

* Fire up !!

```
$ vagrant up
$ vagrant ssh
vagrant$ cd workspace/android-4.4_r1
vagrant$ repo sync
vagrant$ . build/envsetup
vagrant$ lunch
vagrant$ make
```

## What's included?

* [required packages](http://s.android.com/source/initializing.html#installing-required-packages-ubuntu-1204) to build AOSP
* vim & plugins ([unite](https://github.com/Shougo/unite.vim), [fugitive](https://github.com/tpope/vim-fugitive), [Vundle](https://github.com/gmarik/Vundle.vim))
* [tmux](http://tmux.sourceforge.net/)
* [linuxbrew](https://github.com/Homebrew/linuxbrew)
