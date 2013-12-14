# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  config.vm.network "forwarded_port", guest: 9090, host: 9090, auto_correct: true

  # To speed up provisioning, run `vagrant plugin install vagrant-cachier`
  if defined? VagrantPlugins::Cachier
    config.cache.auto_detect = true
  end

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1048"]
  end

  config.vm.provision :shell, :inline => <<-'EOT'
    apt-get update
    apt-get install vim curl git -y
    apt-get install -y python-software-properties python g++ make
    add-apt-repository -y ppa:chris-lea/node.js
    apt-get update
    apt-get install nodejs -y

    npm install -g bower
    npm install -g grunt-cli
    gem install compass --no-rdoc --no-ri

    su -l vagrant -c "cd /vagrant; npm install; bower install; grunt build"
  EOT
end
