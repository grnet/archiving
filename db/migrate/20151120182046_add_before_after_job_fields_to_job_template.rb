class AddBeforeAfterJobFieldsToJobTemplate < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def up
    add_column :job_templates, :client_before_run_file, :string
    add_column :job_templates, :client_after_run_file, :string
  end

  def down
    remove_column :job_templates, :client_before_run_file
    remove_column :job_templates, :client_after_run_file
  end
end
