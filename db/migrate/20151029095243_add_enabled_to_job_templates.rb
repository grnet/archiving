class AddEnabledToJobTemplates < ActiveRecord::Migration
  def change
    add_column :job_templates, :enabled, :boolean, default: false
  end
end
