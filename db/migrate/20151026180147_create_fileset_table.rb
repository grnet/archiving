class CreateFilesetTable < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def up
    create_table :filesets do |t|
      t.string :name
      t.integer :host_id
      t.text :exclude_directions
      t.text :include_directions

      t.timestamps
    end

    add_index :filesets, :host_id
  end

  def down
    drop_table :filesets
  end
end
