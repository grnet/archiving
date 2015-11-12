class BaculaHandler
  require 'net/scp'

  attr_accessor :host, :tempfile

  # Initializes a BaculaHandler instance.
  #
  # Sets `host` and `template` attributes.
  #
  # @param host[Host] A the host instance the the bacula handler will act upon
  def initialize(host)
    @host = host
    @tempfile = get_config_file
  end

  # Deploys the host's config to the bacula director by
  #
  # * uploading the configuration
  # * reloadind the bacula director
  #
  # Updates the host's status accordingly
  #
  # @return [Boolean] false if something went wrong
  def deploy_config
    return false unless send_config
    if reload_bacula
      host.set_deployed
    else
      host.dispatch || host.redispatch
    end
  end

  # Removes the host's configuration from the bacula director by
  #
  # * removing the host's configuration files
  # * reloading the bacula director
  #
  # Updates the host's status accordingly
  #
  # @return [Boolean] false if something went wrong
  def undeploy_config
    return false unless remove_config
    host.disable if reload_bacula
  end

  # Schedules an immediate backup to the bacula director for the given host and job
  #
  # @params job_name[String] the job's name
  def backup_now(job_name)
    job = host.job_templates.enabled.find_by(name: job_name)
    return false unless job
    command = "echo \"run job=\\\"#{job.name_for_config}\\\" yes\" | #{bconsole}"
    Rails.logger.warn("[BaculaHandler] : #{command}")
    exec_with_timeout(command, 2)
  end

  private

  def get_config_file
    file = Tempfile.new(host.name)
    file.chmod(0666)
    file.write host.baculize_config.join("\n")
    file.close
    file
  end

  def send_config
    begin
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        tempfile.path,
        ssh_settings[:path] + host.name + '.conf',
        ssh: { keys: [ssh_settings[:key_file]] }
      )
    rescue
      return false
    end
    true
  end

  def remove_config
    begin
      Net::SSH.start(ssh_settings[:host], ssh_settings[:username],
                     keys: ssh_settings[:key_file]) do |ssh|
        ssh.exec!("rm #{ssh_settings[:path] + host.name}.conf")
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
    rescue
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
