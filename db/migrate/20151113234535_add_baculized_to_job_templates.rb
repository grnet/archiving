class AddBaculizedToJobTemplates < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def up
    add_column :job_templates, :baculized, :boolean, default: false
    add_column :job_templates, :baculized_at, :datetime
  end

  def down
    remove_column :job_templates, :baculized
    remove_column :job_templates, :baculized_at
  end
end
