class BaculaHandler
  require 'net/scp'

  attr_accessor :host, :templates, :client, :jobs, :schedules, :filesets

  # Initializes a BaculaHandler instance.
  #
  # Sets `host` and `templates` attributes.
  # Sets the temporal files that contain the client's configuration
  #
  # @param host[Host] A the host instance the the bacula handler will act upon
  def initialize(host)
    @host = host
    @templates = host.job_templates.includes(:fileset, :schedule)

    @client = get_client_file
    @jobs = get_jobs_file
    @schedules = get_schedules_file
    @filesets = get_filesets_file
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
  # @param job_name[String] the job's name
  def backup_now(job_name)
    job = host.job_templates.enabled.find_by(name: job_name)
    return false unless job
    command = "echo \"run job=\\\"#{job.name_for_config}\\\" yes\" | #{bconsole}"
    log(command)
    exec_with_timeout(command, 2)
  end

  # Schedules an immediate restore to the bacula director for the given host.
  #
  # @param location[String] the desired restore location
  def restore(location="/tmp/bacula-restore")
    command = "echo \"restore client=\\\"#{host.name}\\\" where=\\\"#{location}\\\" select current all done yes\" | #{bconsole}"
    log(command)
    exec_with_timeout(command, 2)
  end

  private

  def get_client_file
    file = a_tmpfile
    file.write host.to_bacula_config_array.join("\n")
    file.close
    file
  end

  def get_jobs_file
    file = a_tmpfile
    file.write templates.map(&:to_bacula_config_array).join("\n")
    file.close
    file
  end

  def get_schedules_file
    file = a_tmpfile
    file.write templates.map(&:schedule).uniq.map(&:to_bacula_config_array).join("\n")
    file.close
    file
  end

  def get_filesets_file
    file = a_tmpfile
    file.write templates.map(&:fileset).uniq.map(&:to_bacula_config_array).join("\n")
    file.close
    file
  end

  def send_config
    begin
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        client.path,
        ssh_settings[:path] + 'clients/' + host.name + '.conf',
        ssh: { keys: [ssh_settings[:key_file]] }
      )
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        jobs.path,
        ssh_settings[:path] + 'jobs/' + host.name + '.conf',
        ssh: { keys: [ssh_settings[:key_file]] }
      )
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        schedules.path,
        ssh_settings[:path] + 'schedules/' + host.name + '.conf',
        ssh: { keys: [ssh_settings[:key_file]] }
      )
      Net::SCP.upload!(
        ssh_settings[:host],
        ssh_settings[:username],
        filesets.path,
        ssh_settings[:path] + 'filesets/' + host.name + '.conf',
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
        ssh.exec!("rm #{ssh_settings[:path]}*/#{host.name}.conf")
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

  def a_tmpfile
    file = Tempfile.new(host.name)
    file.chmod(0666)
    file
  end

  def log(msg)
    Rails.logger.warn("[BaculaHandler]: #{msg}")
  end
end
