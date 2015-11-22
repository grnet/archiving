class AddRetentionPeriodsToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :job_retention_period_type, :string
    add_column :hosts, :file_retention_period_type, :string
  end

  def down
    remove_column :hosts, :job_retention_period_type
    remove_column :hosts, :file_retention_period_type
  end
end
