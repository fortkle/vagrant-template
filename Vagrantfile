# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "opscode-centos-6.4"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "./vagrant_home", "/home/vagrant/share",
    :create => true, :owner => 'vagrant', :group => 'vagrant',
    :mount_options => ['dmode=775,fmode=775']

  Encoding.default_external = 'UTF-8'
  
  # Network delay measures in IPv6 and DNS
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provision :shell, :path => "bootstrap.sh", privileged: false
end
