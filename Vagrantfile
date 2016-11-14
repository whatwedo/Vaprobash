# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configure remote source
github_username = "whatwedo"
github_repo     = "Vaprobash"
github_branch   = "develop"
github_url      = "https://raw.githubusercontent.com/#{github_username}/#{github_repo}/#{github_branch}"

Vagrant.configure("2") do |config|

  ####
  # Automatic provisioning
  ##########
  require "./Vaprobash.rb" #require github_url + "/Vaprobash.rb"
  Vaprobash.configure(github_url, config, "./vaprobash.yml")

  ####
  # Other Scripts
  # Any scripts you may want to run post-provisioning.
  ##########
  # config.vm.provision "shell", path: "./vm-init.sh"

end
