# Vaprobash

**Va**&#x200B;grant **Pro**&#x200B;visioning **Bash** Scripts

[View the site and extended docs.](http://fideloper.github.io/Vaprobash/index.html)

[![Build Status](https://travis-ci.org/fideloper/Vaprobash.png?branch=master)](https://travis-ci.org/fideloper/Vaprobash)

## Goal

The goal of this project is to create easy to use bash scripts in order to provision a Vagrant server.

1. This targets Ubuntu LTS releases, currently 14.04.*
2. This project will give users various popular options such as LAMP, LEMP
3. This project will attempt some modularity. For example, users might choose to install a Vim setup, or not.

Some further assumptions and self-imposed restrictions. If you find yourself needing or wanting the following, then other provisioning tool would better suited ([Chef](https://www.chef.io), [Puppet](https://puppet.com), [Ansible](https://www.ansible.com)).

* If other OSes need to be used (CentOS, Redhat, Arch, etc).
* If dependency management becomes complex. For example, installing Laravel depends on Composer. Setting a document root for a project will change depending on Nginx or Apache. Currently, these dependencies are accounted for, but more advanced dependencies will likely not be.

## Dependencies

* Vagrant `1.8.0`+
    * Use `vagrant -v` to check your version
* Virtualbox or VMWare Fusion

## Instructions

**First**, Copy the Vagrantfile from this repo. You may wish to use curl or wget to do this instead of cloning the repository.

```bash
# curl
$ curl -L http://welike.to/1ONvsgs > Vagrantfile

# wget
$ wget -O Vagrantfile http://welike.to/1ONvsgs
```

> The `welike.to` link will always point to the develop branch version of the Vagrantfile.

**Second**, edit the `Vagrantfile` and uncomment which scripts you'd like to run. You can uncomment them by removing the `#` character before the `config.vm.provision` line.

> You can indeed have [multiple provisioning](http://docs.vagrantup.com/v2/provisioning/basic_usage.html) scripts when provisioning Vagrant.

**Third** and finally, run:

```bash
$ vagrant up
```

**Screencast**

Here's a quickstart screencast!

[<img src="https://secure-b.vimeocdn.com/ts/463/341/463341369_960.jpg" alt="Vaprobash Quickstart" style="max-width:100%"/>](http://vimeo.com/fideloper/vaprobash-quickstart)

## Docs

[View the site and extended docs.](http://fideloper.github.io/Vaprobash/index.html)

## What You Can Install

* Base Packages
	* Base Items (Git and more!)
	* PHP (php-fpm)
	* Vim
	* PHP MsSQL (ability to connect to SQL Server)
	* Screen
	* Docker
    * docker-compose
* Web Servers
	* Apache
	* HHVM
	* Nginx
* Databases
	* Couchbase
	* CouchDB
	* MariaDB
	* MongoDB
	* MySQL
	* Neo4J
	* PostgreSQL
	* SQLite
* In-Memory Stores
	* Memcached
	* Redis
* Search
	* ElasticSearch and ElasticHQ
* Utility
	* Beanstalkd
	* Supervisord
    * Kibana
* Additional Languages
	* NodeJS via NVM
	* Ruby via RVM
    * Orcale Java 8
* Frameworks / Tooling
	* Composer
	* Laravel
	* Symfony
	* PHPUnit
	* MailCatcher
    * Ansible
	* Android
    * Maven
    * M4
    * Puppet Client
    * wkhtmltopdf
    * tutum-cli
    * phpMyAdmin
    * docker-nuke
    * mkdocs

## The Vagrantfile

The vagrant file does three things you should take note of:

1. **Gives the virtual machine a static IP address of 192.168.22.10.** This IP address is again hard-coded (for now) into the LAMP, LEMP and Laravel/Symfony installers. This static IP allows us to use [xip.io](http://xip.io) for the virtual host setups while avoiding having to edit our computers' `hosts` file.
2. **Uses NFS instead of the default file syncing.** NFS is reportedly faster than the default syncing for large files. If, however, you experience issues with the files actually syncing between your host and virtual machine, you can change this to the default syncing by deleting the lines setting up NFS:

  ```ruby
  config.vm.synced_folder ".", "/vagrant",
            id: "core",
            :nfs => true,
            :mount_options => ['nolock,vers=3,udp,noatime']
  ```
3. **Offers an option to prevent the virtual machine from losing internet connection when running on Ubuntu.** If your virtual machine can't access the internet, you can solve this problem by uncommenting the two lines below:

  ```ruby
    #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  ```

  Don't forget to reload your Vagrantfile running `vagrant reload --no-provision`, in case your virtual machine already exists.

## Recommended Plugins

For an optimal experience we are recommending the installation of the following Vagrant plugins:

* [vagrant-hostmanager](https://github.com/smdahlen/vagrant-hostmanager)
* [vagrant-reload](https://github.com/aidanns/vagrant-reload)
* [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) (VirtualBox users only)

## Connecting to MySQL from Sequel Pro:

Change your IP address as needed.

![sequel pro vaprobash](http://fideloper.github.io/Vaprobash/img/sequel_pro.png)

## Contribute!

Do it! Any new install or improvement on existing ones are welcome! Please see the [contributing doc](/contributing.md).
