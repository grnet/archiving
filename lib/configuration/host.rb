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
      ]
    end

    # Fetches the Director resource for the file-deamon configuration
    # file
    def bacula_fd_director_config
      [
        'Director {',
        "  Name = \"#{Baas.settings[:director_name]}\"",
        "  Password = \"#{password}\"",
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
  end
end
