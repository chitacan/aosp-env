# aosp-env

Provision [AOSP](http://s.android.com/index.html) development environment on [Ubuntu 12.04 LTS 64-bit](https://vagrantcloud.com/hashicorp/precise64) with puppet.

## How to use

* Make sure you have [Virtualbox](https://www.virtualbox.org/), [Vagrant](http://www.vagrantup.com/) (latest version required) on your machine.

    $ git clone https://github.com/chitacan/aosp-env
    $ cd aosp-env
    $ vagrant up
    $ vagrant ssh
    vagrant$ cd workspace/android-4.4_r1
    vagrant$ repo sync
    vagrant$ . build/envsetup
    vagrant$ lunch
    vagrant$ make

## What's included?

* [required packages](http://s.android.com/source/initializing.html#installing-required-packages-ubuntu-1204) to build AOSP
* vim & plugins ([unite](https://github.com/Shougo/unite.vim), [fugitive](https://github.com/tpope/vim-fugitive), [Vundle](https://github.com/gmarik/Vundle.vim))
* [tmux](http://tmux.sourceforge.net/)
* AOSP branch(`android-4.4_r1`, `android_4.1.2_r1`, `android_4.3_r1`) directories with manifest