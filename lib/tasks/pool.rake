namespace :pool do
  desc 'Send new pool parameters to upstream schedules'
  task apply_upstream: :environment do
    # update the config files for all the deployed clients
    for host in Host.where(status: Host::STATUSES[:deployed]) do
      puts "sending: #{host.name}"
      BaculaHandler.new(host).send(:send_config)
    end

    # reload bacula
    BaculaHandler.new(host).send(:reload_bacula) if host
  end
end
