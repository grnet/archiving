class Fileset < ActiveRecord::Base
  establish_connection Baas::settings[:local_db]

  serialize :exclude_directions, Array
  serialize :include_directions, JSON

  belongs_to :host
  has_many :job_templates

  DEFAULT_EXCLUDED = %w{/var/lib/bacula /proc /tmp /.journal /.fsck /bacula}
  DEFAULT_INCLUDE_OPTIONS = { signature: :SHA1, compression: :GZIP }
  DEFAULT_INCLUDE_FILE_LIST = ['/']

  def to_bacula_config_array
    ['FileSet {'] +
      ["  Name = \"#{name}\""] +
      exclude_directions_to_config_array +
      include_directions_to_config_array +
      ['}']
  end

  private

  def exclude_directions_to_config_array
    return [] if exclude_directions.empty?
    ['  Exclude {'] +
      exclude_directions.map { |x| "    File = \"#{x}\"" } +
      ['  }']
  end

  def include_directions_to_config_array
    return [] if include_directions.blank?
    ["  Include {"] +
      included_options +
      included_files +
      ['  }']
  end

  def included_options
    formatted = ["    Options {"]
    options = include_directions.deep_symbolize_keys[:options].reverse_merge(DEFAULT_INCLUDE_OPTIONS)
    options.each do |k,v|
      if not [:wildfile].include? k
        formatted <<  "      #{k} = #{v}"
      else
        formatted << v.map { |f| "      #{k} = \"#{f}\"" }
      end
    end
    formatted << "    }"
    formatted
  end

  def included_files
    include_directions['file'].map { |f| "    File = #{f}" }
  end

  def included_wildfile
    include_directions['wildfile'].map { |f| "   wildfile = \"#{f}\"" }.join("\n")
  end
end
