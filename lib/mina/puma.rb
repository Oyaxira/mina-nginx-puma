set :systemctl_path, 'sudo systemctl'
set :system_config_path, '/etc/systemd/system'
set :system_bundler_path, '/usr/local/rvm/bin/rvm all do bundle'
set :puma_user, -> { fetch(:user).to_s }
set :puma_socket_listen_stream, -> { "#{fetch(:deploy_to)}/shared/tmp/sockets/puma.sock" }
set :puma_config_path, -> { "#{fetch(:deploy_to)}/shared/config/puma.rb" }
set :system_service_name, -> { "#{fetch(:application_name)}.service" }
set :system_socket_name, -> { "#{fetch(:application_name)}.socket" }
set :puma_state_path, -> { "#{fetch(:current_path)}/tmp/sockets/puma.state" }

set :nginx_path, '/etc/nginx'
set :cert_path, '/etc/nginx/cert.pem'
set :cert_key_path, '/etc/nginx/cert.key'
set :use_ssl, false

namespace :puma do

  desc 'install template to change default config'
  task :install do
    run :local do
      if Dir.exist? "./config/deploy/templates"
        error! %(file exists; please rm to continue: config/deploy/templates)
      else
        command %(mkdir -p config/deploy/templates)
        command %(cp #{File.expand_path("../templates/*", __FILE__)} ./config/deploy/templates/)
      end
    end
  end

  desc 'setup puma application service'
  task :setup do
    comment %(write puma.rb)
    command %(echo '#{erb get_template(name: 'puma.rb')}' > #{fetch :puma_config_path})
    comment %(init service config)
    command %(echo '#{erb get_template(name: 'puma.service')}' > #{File.join(fetch(:system_config_path),
                                                                             fetch(:system_service_name))})
    comment %(init socket config)
    command %(echo  root'#{erb get_template(name: 'puma.socket')}' > #{File.join(fetch(:system_config_path),
                                                                                 fetch(:system_socket_name))})
    comment %(reload daemon)
    command %(#{fetch(:systemctl_path)} daemon-reload)
    comment %(enable service )
    command %(#{fetch(:systemctl_path)} enable #{fetch :system_service_name})
    command %(#{fetch(:systemctl_path)} enable #{fetch :system_socket_name})
    comment %(pls run 'mina puma:config' to check puma config )
  end
  desc 'remove puma config'
  task :remove do
    command %( #{fetch(:systemctl_path)} disable #{fetch(:system_service_name)} )
    command %( sudo rm #{File.join(fetch(:system_config_path), fetch(:system_service_name))}  )
    command %( #{fetch(:systemctl_path)} disable #{fetch(:system_socket_name)} )
    command %( sudo rm #{File.join(fetch(:system_config_path), fetch(:system_socket_name))}  )
    comment %(reload daemon)
    command %(#{fetch(:systemctl_path)} daemon-reload)
  end
  desc 'start service and socket'
  task :start do
    command %( #{fetch(:systemctl_path)} start #{fetch(:system_service_name)} #{fetch(:system_socket_name)})
  end

  desc 'check puma config'
  task :check do
    comment %(puma.rb)
    command %(cat #{fetch(:deploy_to)}/shared/config/puma.rb)
    comment %(puma systemd service)
    command %(cat #{File.join(fetch(:system_config_path), fetch(:system_service_name))})
    comment %(puma systemd socket)
    command %(cat #{File.join(fetch(:system_config_path), fetch(:system_socket_name))})
  end

  desc 'stop service and socket'
  task :stop do
    command %( #{fetch(:systemctl_path)} stop #{fetch(:system_service_name)} #{fetch(:system_socket_name)})
  end
  desc 'restart server'
  task :restart do
    command %( #{fetch(:systemctl_path)} restart #{fetch(:system_service_name)} )
  end
  desc 'get service status'
  task :status do
    command %(#{fetch(:systemctl_path)} status #{fetch(:system_service_name)} #{fetch(:system_socket_name)})
  end

  desc 'get service log'
  task :log do
    command %(journalctl -u #{fetch :application_name} -f)
  end

  desc 'setup nginx with puma config'
  task :setup_nginx do
    comment %(write nginx config '"#{fetch :nginx_path}/conf.d/#{fetch :application_name}.conf"')
    command %(echo '#{erb nginx_template}' > #{fetch :nginx_path}/conf.d/#{fetch :application_name}.conf)
    command %(nginx -t)
    command %(nginx -s reload)
  end

  private

  def nginx_template
    use_ssl = fetch :use_ssl
    use_ssl ? get_template(name: 'nginx_ssl.conf') : get_template(name: 'nginx.conf')
  end

  def get_template(name: 'puma.rb')
    installed_file = File.expand_path("./config/deploy/templates/#{name}.erb")
    File.exist?(installed_file) ? installed_file : File.expand_path("../templates/#{name}.erb", __FILE__)
  end
end
