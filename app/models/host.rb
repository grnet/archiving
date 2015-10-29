class Host < ActiveRecord::Base
  FILE_RETENTION_DAYS = 60
  JOB_RETENTION_DAYS = 180
  CATALOG = 'MyCatalog'
  AUTOPRUNE = 1

  establish_connection :local_development

  enum status: { draft: 0, pending: 1, config: 2, ready: 3 }

  belongs_to :client, class_name: :Client, foreign_key: :name, primary_key: :name
  has_many :filesets, dependent: :destroy
  has_many :job_templates, dependent: :destroy

  validates :file_retention, :job_retention,
    :port, :password, presence: true
  validates :port, numericality: true

  validates :name, presence: true, uniqueness: true

  validate :fqdn_format

  scope :not_baculized, -> { where(baculized: false) }

  before_validation :set_retention, :unset_baculized, :sanitize_name

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

  def auto_prune_human
    AUTOPRUNE == 1 ? 'yes' : 'no'
  end

  private

  def sanitize_name
    self.name = fqdn
  end

  def set_retention
    self.file_retention = FILE_RETENTION_DAYS
    self.job_retention = JOB_RETENTION_DAYS
  end

  def unset_baculized
    self.baculized = false if new_record?
    true
  end

  def fqdn_format
    regex = /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/
    unless fqdn =~ regex
      self.errors.add(:fqdn)
    end
  end
end
