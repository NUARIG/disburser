# config valid only for current version of Capistrano
lock '3.6.0'

APP_CONFIG = YAML.load(File.open('config/config.yml'))

set :application,  APP_CONFIG['application']
set :repo_url,     APP_CONFIG['repository']

set :rvm_ruby_version, '2.3.0'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/apps/#{ fetch(:application) }"
#mgurley come back in SS
# set :deploy_via, :copy

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
#crr set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db_backups}
#ss set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end
  #
  # after :finishing, 'deploy:cleanup'

  # namespace :symlink do
  #   task :database_config do
  #     on roles(:web) do
  #       execute "ln -nfs /etc/nubic/db/studystarter.yml #{release_path}/config/database.yml"
  #     end
  #   end
  # end
  # before 'deploy:assets:precompile', 'deploy:symlink:database_config'

  task :httpd_graceful do
    on roles(:web), in: :sequence, wait: 5 do
      execute :sudo, "service httpd graceful"
    end
  end
end

namespace :deploy_prepare do
  desc 'Configure virtual host'
  task :create_vhost do
    on roles(:web), in: :sequence, wait: 5 do
      vhost_config = <<-EOF
NameVirtualHost *:80
NameVirtualHost *:443

<VirtualHost *:80>
  ServerName #{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }
  ServerAlias #{ APP_CONFIG[ fetch(:stage).to_s ]['server_alias'] }
  Redirect permanent / https://#{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }/
</VirtualHost>

<VirtualHost *:443>
  PassengerFriendlyErrorPages off
  PassengerAppEnv #{ fetch(:stage) }
  PassengerRuby /usr/local/rvm/wrappers/ruby-#{ fetch(:rvm_ruby_version) }/ruby

  ServerName #{ APP_CONFIG[ fetch(:stage).to_s ]['server_name'] }

  SSLEngine On
  SSLCertificateFile #{ APP_CONFIG[ fetch(:stage).to_s ]['cert_file'] }
  SSLCertificateChainFile #{ APP_CONFIG[ fetch(:stage).to_s ]['chain_file'] }
  SSLCertificateKeyFile #{ APP_CONFIG[ fetch(:stage).to_s ]['key_file'] }

  DocumentRoot #{ fetch(:deploy_to) }/current/public
  RailsBaseURI /
  PassengerDebugLogFile /var/log/httpd/#{ fetch(:application) }_passenger.log

  <Location /admin >
    Order deny,allow
    Deny from all
    Allow from 129.105.0.0/16 165.124.0.0/16
  </Location>

  <Directory #{ fetch(:deploy_to) }/current/public >
    Allow from all
    Options -MultiViews
  </Directory>
</VirtualHost>
EOF
      execute :echo, "\"#{ vhost_config }\"", ">", "/etc/httpd/conf.d/#{ fetch(:application) }.conf"
    end
  end
end

after "deploy:updated", "deploy:cleanup"
after "deploy:finished", "deploy_prepare:create_vhost"
after "deploy_prepare:create_vhost", "deploy:httpd_graceful"
after "deploy:httpd_graceful", "deploy:restart"