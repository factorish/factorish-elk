# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

CLOUD_CONFIG_PATH = './user-data'
CONFIG = 'config.rb'

# Defaults for config options defined in CONFIG
$num_instances = 1
$enable_serial_logging = false
$vb_gui = false
$vb_memory = 512
$vb_cpus = 1

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV['NUM_INSTANCES'].to_i > 0 && ENV['NUM_INSTANCES']
  $num_instances = ENV['NUM_INSTANCES'].to_i
end

require_relative CONFIG if File.exist?(CONFIG)

if ARGV.include? 'up'
  puts 'rewriting userdata'
  write_user_data($num_instances)
end

Vagrant.configure('2') do |config|
  config.vm.box = 'coreos-beta'
  config.vm.box_version = '>= 308.0.1'
  config.vm.box_url = 'http://storage.core-os.net/coreos/amd64-usr/beta/coreos_production_vagrant.json'

  config.vm.provider :vmware_fusion do |_, override|
    override.vm.box_url = 'http://storage.core-os.net/coreos/amd64-usr/beta/coreos_production_vagrant_vmware_fusion.json'
  end

  # plugin conflict
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  (1..$num_instances).each do |i|
    config.vm.define vm_name = format('core-%02d', i) do |c|
      c.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), 'log')
        FileUtils.mkdir_p(logdir)

        serial_file = File.join(logdir, format('%s-serial.txt', vm_name))
        FileUtils.touch(serial_file)

        c.vm.provider :vmware_fusion do |v, _|
          v.vmx['serial0.present'] = 'TRUE'
          v.vmx['serial0.fileType'] = 'file'
          v.vmx['serial0.fileName'] = serialFile
          v.vmx['serial0.tryNoRxLoss'] = 'FALSE'
        end

        c.vm.provider :virtualbox do |vb, _|
          vb.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
          vb.customize ['modifyvm', :id, '--uartmode1', serialFile]
        end
      end

      if $expose_docker_tcp
        c.vm.network 'forwarded_port', guest: 9200, host: 9200, auto_correct: true
        c.vm.network 'forwarded_port', guest: 514, host: 5014, auto_correct: true
        c.vm.network 'forwarded_port', guest: 5601, host: 5601, auto_correct: true
      end

      c.vm.provider :virtualbox do |vb|
        vb.gui = $vb_gui
        vb.memory = $vb_memory
        vb.cpus = $vb_cpus
      end

      ip = "172.17.8.#{i + 100}"
      c.vm.network :private_network, ip: ip

      c.vm.synced_folder '.', '/home/core/share', id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp']

      if File.exist?(CLOUD_CONFIG_PATH)
        c.vm.provision :file, source: "#{CLOUD_CONFIG_PATH}", destination: '/tmp/vagrantfile-user-data'
        c.vm.provision :shell, inline: 'mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/', privileged: true
      end

      if i == 1
        c.vm.network 'forwarded_port', guest: 5000, host: 5000
        c.vm.provision :shell, inline: <<-EOF
          echo Creating a Private Registry
          if [[ -e /home/core/share/registry/registry.tgz ]]; then
            docker images registry | grep registry > /dev/null || docker load < /home/core/share/registry/registry.tgz
          else
            docker pull registry > /dev/null
            docker save registry > /home/core/share/registry/registry.tgz
          fi
          curl -s 10.0.2.2:5000 || docker run -d -p 5000:5000 -e GUNICORN_OPTS=[--preload] -e search_backend= -v /home/core/share/registry:/tmp/registry registry
          sleep 10
          echo Building base java image
          docker pull 10.0.2.2:5000/paulczar/java_confd > /dev/null || \
            docker build -t 10.0.2.2:5000/paulczar/java_confd /home/core/share && \
            docker push 10.0.2.2:5000/paulczar/java_confd && \
            docker tag 10.0.2.2:5000/paulczar/java_confd paulczar/java_confd
          echo Building elasticsearch image
          docker pull 10.0.2.2:5000/paulczar/elasticsearch_confd > /dev/null || \
            docker build -t 10.0.2.2:5000/paulczar/elasticsearch_confd /home/core/share/elasticsearch  && \
            docker push 10.0.2.2:5000/paulczar/elasticsearch_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/elasticsearch_confd paulczar/elasticsearch_confd
          echo Building Logstash image
          docker pull 10.0.2.2:5000/paulczar/logstash_confd > /dev/null || \
            docker build -t 10.0.2.2:5000/paulczar/logstash_confd /home/core/share/logstash  && \
            docker push 10.0.2.2:5000/paulczar/logstash_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/logstash_confd paulczar/logstash_confd
          echo Building Kibana image
          docker pull 10.0.2.2:5000/paulczar/kibana_confd > /dev/null || \
            docker build -t 10.0.2.2:5000/paulczar/kibana_confd /home/core/share/kibana  && \
            docker push 10.0.2.2:5000/paulczar/kibana_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/kibana_confd paulczar/kibana_confd
          echo Grab logspout
          docker pull 10.0.2.2:5000/progrium/logspout > /dev/null || \
            docker pull progrium/logspout
          docker tag 10.0.2.2:5000/progrium/logspout progrium/logspout || \
            docker tag progrium/logspout 10.0.2.2:5000/progrium/logspout
          docker push 10.0.2.2:5000/progrium/logspout > /dev/null
        EOF
      else
        c.vm.provision :shell, inline: <<-EOF
          echo fetching images.  This may take some time.
          echo - java ...
          docker pull 10.0.2.2:5000/paulczar/java_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/java_confd paulczar/java_confd
          echo - elasticsearch ...
          docker pull 10.0.2.2:5000/paulczar/elasticsearch_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/elasticsearch_confd paulczar/elasticsearch_confd
          echo - logstash ...
          docker pull 10.0.2.2:5000/paulczar/logstash_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/logstash_confd paulczar/logstash_confd
          echo - kibana ...
          docker pull 10.0.2.2:5000/paulczar/kibana_confd > /dev/null && \
            docker tag 10.0.2.2:5000/paulczar/kibana_confd paulczar/kibana_confd
        EOF
      end
      c.vm.provision :shell, inline: <<-EOF
        eval `cat /etc/environment | sed "s/^/export /"`
        echo "Running elasticsearch"
        docker run  -d  -p 9200:9200 -p 9300:9300 -e PUBLISH=9200 \
          -e HOST=$COREOS_PRIVATE_IPV4 --name elasticsearch paulczar/elasticsearch_confd || \
          echo is it already running?
        echo "Running logstash"
        docker run  -d  -p 514:514 -p 514:514/udp -e PUBLISH=514 \
          -e HOST=$COREOS_PRIVATE_IPV4 --name logstash paulczar/logstash_confd || \
          echo is it already running?
        echo "Running kibana"
        docker run  -d  -p 5601:5601 -e PUBLISH=5601 \
          -e HOST=$COREOS_PRIVATE_IPV4 --name kibana paulczar/kibana_confd || \
          echo is it already running?
        echo "Finally, logspout"
        docker pull 10.0.2.2:5000/progrium/logspout && \
          docker tag 10.0.2.2:5000/progrium/logspout progrium/logspout
        docker run -d -v=/var/run/docker.sock:/tmp/docker.sock progrium/logspout \
          syslog://$COREOS_PRIVATE_IPV4:514 -h $HOSTNAME
      EOF

    end
  end
end
