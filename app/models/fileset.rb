# Fileset model is the application representation of Bacula's Fileset.
# It has references to a host and job templates.
class Fileset < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  serialize :exclude_directions, Array
  serialize :include_directions, JSON

  attr_accessor :include_files

  belongs_to :host
  has_many :job_templates

  validates :name, presence: true, uniqueness: { scope: :host }
  validate :has_included_files, on: :create
  validates_with NameValidator

  before_save :sanitize_exclude_directions, :sanitize_include_directions

  DEFAULT_EXCLUDED = %w{/var/lib/bacula /proc /tmp /.journal /.fsck /bacula}
  DEFAULT_INCLUDE_OPTIONS = { signature: :SHA1, compression: :GZIP }
  DEFAULT_INCLUDE_FILE_LIST = ['/']

  # Constructs an array where each element is a line for the Fileset's bacula config
  #
  # @return [Array]
  def to_bacula_config_array
    ['FileSet {'] +
      ["  Name = \"#{name_for_config}\""] +
      include_directions_to_config_array +
      exclude_directions_to_config_array +
      ['}']
  end

  # Provides a human readable projection of the fileset
  #
  # @return [String]
  def human_readable
    result = "Directories:\n"
    result << "\t* " << include_directions['file'].join("\n\t* ")
    if exclude_directions.present?
      result << "\n\nExcluded:\n"
      result << "\t* " << exclude_directions.join("\n\t*")
    end

    result
  end

  # Generates a name that will be used for the configuration file.
  # It is the name that will be sent to Bacula through the configuration
  # files.
  #
  # @return [String]
  def name_for_config
    [host.name, name].join(' ')
  end

  # Returns the hosts that have enabled jobs that use this fileset
  #
  # @return [ActiveRecord::Relation] the participating hosts
  def participating_hosts
    Host.joins(:job_templates).where(job_templates: { enabled: true, fileset_id: id }).uniq
  end

  # Creates a default fileset resource for a simple config
  def default_resource(name, time_hex, opts = {})
    @include_files = opts[:files].presence || DEFAULT_INCLUDE_FILE_LIST
    self.name = "files_#{name}_#{time_hex}"
    self.exclude_directions = DEFAULT_EXCLUDED

    save!
    self
  end

  private

  def has_included_files
    if include_files.blank? || include_files.all?(&:blank?)
      errors.add(:include_files, :cant_be_blank)
    end
  end

  def sanitize_include_directions
    files = include_files.compact.uniq.keep_if(&:present?) rescue nil
    if files.blank?
      self.errors[:include_files] << "Include files can't be empty"
      return false
    end

    files = files.map {|file| Shellwords.escape(file) }

    self.include_directions = { options: DEFAULT_INCLUDE_OPTIONS, file: files }
  end

  def sanitize_exclude_directions
    self.exclude_directions =
      begin
        exclude_directions.keep_if(&:present?).uniq.map do |x|
          Shellwords.escape(x)
        end
      rescue
        nil
      end
  end

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
    options = include_directions.deep_symbolize_keys[:options].
      reverse_merge(DEFAULT_INCLUDE_OPTIONS)
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
    include_directions['file'].map { |f| "    File = \"#{f}\"" }
  end

  def included_wildfile
    include_directions['wildfile'].map { |f| "   wildfile = \"#{f}\"" }.join("\n")
  end
end
