class Vaprobash

  ####
  # Configure Vagrant environment
  ##########
  def self.configure(github_url, config, config_file)

    # Check Vagrant version
    Vagrant.require_version ">= 1.8.0"

    # Check if required plugin
    missing_plugin = false
    if !Vagrant.has_plugin?("vagrant-hostmanager")
      warn "The required plugin 'vagrant-hostmanager' is currently not installed. You can install it by executing: 'vagrant plugin install vagrant-hostmanager'"
      missing_plugin = true
    end
    if !Vagrant.has_plugin?("vagrant-reload")
      warn "The required plugin 'vagrant-reload' is currently not installed. You can install it by executing: 'vagrant plugin install vagrant-reload'"
      missing_plugin = true
    end
    if !Vagrant.has_plugin?("vagrant-auto_network")
      warn "The required plugin 'vagrant-auto_network' is currently not installed. You can install it by executing: 'vagrant plugin install vagrant-auto_network'"
      missing_plugin = true
    end
    if !Vagrant.has_plugin?("vagrant-cachier")
      warn "The required plugin 'vagrant-cachier' is currently not installed. You can install it by executing: 'vagrant plugin install vagrant-cachier'"
      missing_plugin = true
    end
    if missing_plugin
      exit
    end

    # Load user configuration
    require "yaml"
    if !File.exist?(config_file)
        raise "Config file #{config_file} is missing."
    end
    user_config = YAML.load_file(config_file) || {}

    # Basic server configuration
    user_config["hostname"] ||= "Vaprobash"
    user_config["start_dir"] ||= "/vagrant"
    user_config["public_folder"] ||= "/vagrant"
    user_config["server_ip"] ||= "192.168.22.10"
    user_config["server_timezone"] ||= "Europe/Zurich"
    user_config["roles"] ||= []
    user_config["roles"].push("base")
    user_config["roles"].push("base_box_optimizations")
    user_config["roles"].push("whatwedo")
    user_config["roles"].push("cleanup")

    # Personal settings
    user_config["github_pat"] ||= ""

    # Database configuration
    user_config["mysql_root_password"] ||= "root"
    user_config["mysql_version"] ||= "5.6"
    user_config["mysql_enable_remote"] ||= "true"
    user_config["pgsql_postgres_password"] ||= "postgres"
    user_config["mongo_version"] ||= "2.6"
    user_config["mongo_enable_remote"] ||= "true"

    # Languages and packages configuration
    user_config["php_timezone"] ||= user_config["server_timezone"]
    user_config["php_version"] ||= "7.0"
    user_config["ruby_version"] ||= "latest"
    user_config["ruby_gems"] ||= []
    user_config["go_version"] ||= "latest"
    user_config["hhvm"] ||= "false"
    user_config["composer_packages"] ||= []
    user_config["nodejs_version"] ||= "latest"
    user_config["nodejs_packages"] ||= []
    user_config["rabbitmq_user"] ||= "rabbitmq"
    user_config["rabbitmq_password"] ||= "rabbitmq"
    user_config["sphinxsearch_version"] ||= "rel22"
    user_config["elasticsearch_version"] ||= "2.3.1"
    user_config["apt_packages"] ||= []

    # Calculate system resources
    # Default: all CPU cores, an eighth of available RAM as memory and swap size
    if !user_config.has_key?("server_memory")
      host = RbConfig::CONFIG["host_os"]
      if host =~ /darwin/
        user_config["server_memory"] = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 8
      elsif host =~ /linux/
        user_config["server_memory"] = `grep "MemTotal" /proc/meminfo | sed -e "s/MemTotal://" -e "s/ kB//"`.to_i / 1024 / 8
      else # sorry Windows folks, I can"t help you
        user_config["server_memory"] = 512
      end
    end
    if !user_config.has_key?("server_cpus")
      host = RbConfig::CONFIG["host_os"]
      if host =~ /darwin/
        user_config["server_cpus"] = `sysctl -n hw.ncpu`.to_i
      elsif host =~ /linux/
        user_config["server_cpus"] = `nproc`.to_i
      else # sorry Windows folks, I can"t help you
        user_config["server_cpus"] = 1
      end
    end
    user_config["server_swap"] ||= user_config["server_memory"]

    # Set hostname
    config.vm.hostname = user_config["hostname"]

    # Set box to Ubuntu 14.04
    config.vm.box = "ubuntu/trusty64"

    # Define VM
    config.vm.define "Vaprobash" do |vapro|
    end

    # Read SSH public key
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip

    # Configure vagrant-cachier
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }

    # Configure hostmanager
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false

    # Configure network
    config.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true

    # Enable agent forwarding over SSH connections
    config.ssh.forward_agent = true

    # Use NFS for the shared folder
    config.vm.synced_folder ".", "/vagrant",
      id: "core",
      :nfs => true,
      :mount_options => ["nolock,vers=3,udp,noatime,actimeo=2,fsc"]

    # Replicate local .gitconfig file if it exists
    if File.file?(File.expand_path("~/.gitconfig"))
      config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
    end

    # Add SSH public key to authorized_keys
    config.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      SHELL
    end

    # Configure virtualbox settings
    config.vm.provider :virtualbox do |vb|

      vb.name = user_config["hostname"]

      # Set server cpus
      vb.customize ["modifyvm", :id, "--cpus", user_config["server_cpus"]]

      # Set server memory
      vb.customize ["modifyvm", :id, "--memory", user_config["server_memory"]]

      # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
      # If the clock gets more than 15 minutes out of sync (due to your laptop going
      # to sleep for instance, then some 3rd party services will reject requests.
      vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

      # Allow symlinks inside shared folders
      vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]

      # Share VPN connection from host to guest
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

      # Force use of linked clones
      vb.linked_clone = true

    end

    # Base items
    Vaprobash.installRole("base", [github_url, user_config["server_swap"], user_config["server_timezone"], user_config["start_dir"]], github_url, user_config, config)
    Vaprobash.installRole("base_box_optimizations", [], github_url, user_config, config)

    # Customization
    Vaprobash.installRole("whatwedo", [], github_url, user_config, config)

    # Cleaning up
    config.vm.provision :reload
    Vaprobash.installRole("cleanup", [], github_url, user_config, config)

  end

  ####
  # Check if role is needed and install
  ##########
  def self.installRole(role, args, github_url, user_config, config)
    if user_config["roles"].include?(role)
      config.vm.provision "shell", path: "#{github_url}/scripts/#{role}.sh", args: args
    end
  end
end
