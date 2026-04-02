Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.build_dir = "."
    d.privileged = true
    d.has_ssh = true
  end

  config.vm.boot_timeout = 600
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.network "forwarded_port", guest: 80, host: 8081

  # Configuración de acceso automático
  config.ssh.username = "root"
  config.ssh.password = "root"
  config.ssh.insert_key = false

  # ESTA ES LA ENTRADA NUEVA:
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
