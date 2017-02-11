class CreateRejectedHostsTable < ActiveRecord::Migration
  def change
    create_table :rejected_hosts do |t|
      t.binary :name, limit: 255, null: false
      t.binary :fqdn, limit: 255, null: false
      t.references :user
      t.integer :rejecter_id
      t.text :reason
      t.datetime :host_created_at
      t.timestamps
    end

    add_index :rejected_hosts, :name
  end
end
