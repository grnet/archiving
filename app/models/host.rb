class Host < ActiveRecord::Base
  FILE_RETENTION_DAYS = 60
  JOB_RETENTION_DAYS = 180
  CATALOG = 'MyCatalog'

  establish_connection :local_development

  validates :file_retention, :job_retention,
    :port, :password, presence: true
  validates :port, numericality: true

  validates :name, presence: true, uniqueness: true

  validate :fqdn_format

  before_validation :set_retention, :unset_baculized

  def to_bacula_config_array
    [
      "Client {",
      "  Name = #{name}",
      "  Address = #{fqdn}",
      "  FDPort = #{port}",
      "  Catalog = #{CATALOG}",
      "  Password = \"#{password}\"",
      "  File Retention = #{file_retention} days",
      "  Job Retention = #{job_retention} days",
      "  AutoPrune = yes",
      "}"
    ]
  end

  private

  def set_retention
    self.file_retention = FILE_RETENTION_DAYS
    self.job_retention = JOB_RETENTION_DAYS
  end

  def unset_baculized
    self.baculized = false
    true
  end

  def fqdn_format
    regex = /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/
    unless fqdn =~ regex
      self.errors.add(:fqdn)
    end
  end
end
