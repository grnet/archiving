class CreateSimpleConfigurationsTable < ActiveRecord::Migration
  def change
    create_table :simple_configurations do |t|
      t.integer :host_id
      t.integer :day, limit: 1, null: false
      t.integer :hour, limit: 1, null: false
      t.integer :minute, limit: 1, null: false
      t.timestamps
    end
  end
end
