class AddRestoreLocationToJobTemplates < ActiveRecord::Migration
  def change
    add_column :job_templates, :restore_location, :binary
  end
end
