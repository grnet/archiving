class AddRestoreLocationToJobTemplates < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :job_templates, :restore_location, :binary
  end
end
