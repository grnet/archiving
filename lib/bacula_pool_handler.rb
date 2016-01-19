class BaculaPoolHandler
  require 'net/scp'

  attr_accessor :pool

  # Initializes a BaculaPoolHandler instance.
  #
  # Sets `pool` attribute.
  # Sets the temporal files that contain the client's configuration
  #
  # @param pool[Pool] the pool instance the bacula handler will act upon
  def initialize(pool)
    @pool = pool
  end

  # Deploys the pool's config to the bacula director by
  #
  # * uploading the configuration
  # * reloadind the bacula director
  #
  # @return [Boolean] false if something went wrong
  def deploy_config
    send_config && reload_bacula
  end

  # Removes the pool's configuration from the bacula director by
  #
  # * removing the pool's configuration files
  # * reloading the bacula director
  #
  # @return [Boolean] false if something went wrong
  def undeploy_config
    remove_config && reload_bacula
  end

  private

  def pool_file
    file = Tempfile.new(pool.name)
    file.chmod(0666)
    file.write pool.to_bacula_config_array.join("\n")
    file.close
    file
  end

  def send_config
    file = pool_file
    begin
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        file.path,
        ssh_settings[:admin_path] + 'pools/' + pool.name + '.conf',
        ssh: { keys: [ssh_settings[:key_file]] }
      )
      Rails.logger.warn("[BACULA_POOL_HANDLER]: OK SEND_CONFIG")
    rescue
      Rails.logger.warn("[BACULA_POOL_HANDLER]: ERROR SEND_CONFIG")
      return false
    end
    true
  end

  def remove_config
    begin
      Net::SSH.start(ssh_settings[:host], ssh_settings[:username],
                     keys: ssh_settings[:key_file]) do |ssh|
        ssh.exec!("rm #{ssh_settings[:admin_path]}pools/#{pool.name}.conf")
      end
    rescue
      return false
    end
    true
  end

  def reload_bacula
    command = "echo \"reload quit\" | #{bconsole}"
    exec_with_timeout(command, 2)
  end

  def exec_with_timeout(command, sec)
    begin
      Timeout::timeout(sec) do
        `#{command}`
      end
      Rails.logger.warn("[BACULA_POOL_HANDLER]: OK RELOAD BACULA")
    rescue
      Rails.logger.warn("[BACULA_POOL_HANDLER]: ERROR RELOAD BACULA")
      return false
    end
    true
  end

  def bconsole
    "bconsole -c #{Rails.root}/config/bconsole.conf"
  end

  def ssh_settings
    @ssh_settings ||= YAML::load(File.open("#{Rails.root}/config/ssh.yml"))[Rails.env].
      symbolize_keys
  end
end
