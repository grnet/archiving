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
        "  Name = message_#{name}",
        "  mailcommand = \"#{mail_command}\"",
        "  operatorcommand = \"#{operator_command}\"",
        "  mail = root = all, !skipped",
        "  operator = root = mount",
        "  console = all, !skipped, !saved",
        "  append = \"/var/log/bacula/bacula.log\" = all, !skipped",
        "  catalog = all",
        "}"
      ]
    end

    # Fetches the Director resource for the file-deamon configuration
    # file
    def bacula_fd_director_config
      [
        'Director {',
        "  Name = \"#{Archiving.settings[:director_name]}\"",
        "  Password = \"*********\"",
        '}'
      ].join("\n")
    end

    # Fetches the FileDeamon resource for the file-deamon configuration
    def bacula_fd_filedeamon_config
      [
        'FileDeamon {',
        "  Name = #{name}",
        "  FDport = #{port}",
        '  WorkingDirectory = /var/lib/bacula',
        '  Pid Directory = /var/run/bacula',
        '  Maximum Concurrent Jobs = 10',
        '  FDAddress = 0.0.0.0',
        '}'
      ].join("\n")
    end

    private

    def mail_command
      "#{mail_general} -u \\\"\[Bacula\]: %t %e of %c %l\\\" -m \\\"Bacula Report %r\\\""
    end

    def operator_command
      "#{mail_general} -u \\\"\[Bacula\]: Intervention needed for %j\\\" -m \\\"Intervention needed %r\\\""
    end

    def mail_general
      "/usr/bin/sendEmail -f #{settings[:default_sender]}" <<
        " -t #{email_recipients.join(' ')}" <<
        " -s #{settings[:address]}:#{settings[:port]}" <<
        " -o tls=yes -xu #{settings[:user_name]} -xp #{settings[:password]}"
    end

    def settings
      Archiving.settings[:mail_settings]
    end
  end
end
