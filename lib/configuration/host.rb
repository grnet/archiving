module Configuration
  # Helper module to add configuration getters for Host
  module Host

    # Constructs the final Bacula configuration for the host by appending configs for
    #
    # * Client
    # * Jobs
    # * Schedules
    # * Filesets
    #
    # by calling their `to_bacula_config_array` methods.
    #
    # @return [Array] containing each element's configuration line by line
    def baculize_config
      templates = job_templates.includes(:fileset, :schedule)

      result = [self] + templates.map {|x| [x, x.fileset, x.schedule] }.flatten.compact.uniq
      result.map(&:to_bacula_config_array)
    end

    # Constructs the final Bacula configuration for the host by appending configs for
    #
    # * Client
    # * Jobs
    # * Schedules
    # * Filesets
    #
    # by calling their `to_bacula_config_array` methods.
    #
    # It hides the password.
    #
    # @return [Array] containing each element's configuration line by line
    def baculize_config_no_pass
      baculize_config.join("\n").gsub(/Password = ".*"$/, 'Password = "*************"')
    end

    # Constructs an array where each element is a line for the Client's bacula config
    #
    # @return [Array]
    def to_bacula_config_array
      [
        "Client {",
        "  Name = #{name}",
        "  Address = #{fqdn}",
        "  FDPort = #{port}",
        "  Catalog = #{client_settings[:catalog]}",
        "  Password = \"#{password}\"",
        "  File Retention = #{file_retention} #{file_retention_period_type}",
        "  Job Retention = #{job_retention} #{job_retention_period_type}",
        "  AutoPrune = #{auto_prune_human}",
        "}"
      ] + message_config
    end

    # Constructs the messages bacula resource
    #
    # @return [Array]
    def message_config
      return [] if email_recipients.empty?
      [
        "Messages {",
        "  Name = #{message_name}",
        "  mailcommand = \"#{mail_command}\"",
        "  operatorcommand = \"#{operator_command}\"",
        "  mail = #{email_recipients.join(',')} = all, !skipped",
        "  operator = #{settings[:operator_email]} = mount",
        "  console = all, !skipped, !saved",
        "  append = \"/var/log/bacula/bacula.log\" = all, !skipped",
        "  catalog = all",
        "}"
      ]
    end

    # Fetches the Director resource for the file-daemon configuration
    # file
    def bacula_fd_director_config(hide_pass = true)
      [
        'Director {',
        "  Name = \"#{Archiving.settings[:director_name]}\"",
        "  Password = \"#{hide_pass ? '*********' : password }\"",
        '}'
      ].join("\n")
    end

    # Fetches the FileDaemon resource for the file-daemon configuration
    def bacula_fd_filedaemon_config
      [
        'FileDaemon {',
        "  Name = #{name}",
        "  FDport = #{port}",
        '  WorkingDirectory = /var/lib/bacula',
        '  Pid Directory = /var/run/bacula',
        '# if you have a Windows machine to backup, then you',
        '# should change the above configuration as below:',
        '# WorkingDirectory = "C:/Program Files/Bacula/workdir"',
        '# Pid Directory = "C:/Program Files/Bacula/piddir"',
        '  Maximum Concurrent Jobs = 10',
        '  FDAddress = 0.0.0.0',
        '}'
      ].join("\n")
    end

    # Fetches the Message resource for the file-daemon configuration file
    def bacula_fd_messages_config
      [
        'Messages {',
        "  Name = #{message_name}",
        "  director = #{Archiving.settings[:director_name]} = all, !skipped, !restored",
        '}'
      ].join("\n")
    end

    # The name that the client will use for its messages
    def message_name
      "message_#{name}_#{Digest::MD5.hexdigest(created_at.to_s + name).first(10)}"
    end

    private

    def mail_command
      "#{mail_general}" <<
        ' -t %r' <<
        ' -u \"[Archiving]: %c %t %e\"'
    end

    def operator_command
      "#{mail_general}" <<
        ' -t %r' <<
        ' -u \"[Archiving]: Intervention needed for %j\" -m \"Intervention needed %r\"'
    end

    def mail_general
      command = "/usr/bin/sendEmail -f #{settings[:default_sender]}"
      command << " -s #{settings[:address]}:#{settings[:port]}"
      if settings[:user_name] && settings[:password]
        command << " -o tls=yes -xu #{settings[:user_name]} -xp #{settings[:password]}"
      end
      command
    end

    def settings
      Archiving.settings[:mail_settings]
    end
  end
end
