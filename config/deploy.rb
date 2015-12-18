# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'archiving'
set :repo_url, 'git@bitbucket.org:xlembouras/baas.git'

set :deploy_to, '/srv/archiving'

set :linked_files, %w(config/database.yml config/secrets.yml config/bconsole.conf config/ssh.yml config/bacukey config/bacula.yml config/mailer.yml)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets)

set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo unicornctl respawn'
    end
  end

  after :publishing, :restart
end
