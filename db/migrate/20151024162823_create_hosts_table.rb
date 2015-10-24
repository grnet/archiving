class CreateHostsTable < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    create_table :hosts do |t|
      t.binary :name, limit: 255, null: false
      t.binary :fqdn, limit: 255, null: false
      t.integer :port, null: false
      t.integer :file_retention, null: false
      t.integer :job_retention, null: false

      t.timestamps
    end

    add_index :hosts, :name, unique: true, length: { name: 128}, using: :btree
  end
end
