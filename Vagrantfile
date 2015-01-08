# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.hostname = "robust-dev"

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory",          "1024"]
    vb.customize ["modifyvm", :id, "--cpus",            "1"   ]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"  ]
  end

  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.options = ['--verbose', '--debug']
    puppet.facter = {
      "aospversion" => "android-4.4_r1"
    }
  end

end
