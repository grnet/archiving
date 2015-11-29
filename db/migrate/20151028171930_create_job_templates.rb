class CreateJobTemplates < ActiveRecord::Migration
  def change
    create_table :job_templates do |t|
      t.string :name, null: false
      t.integer :job_type, limit: 1
      t.integer :host_id
      t.integer :fileset_id
      t.integer :schedule_id

      t.timestamps
    end
  end
end
