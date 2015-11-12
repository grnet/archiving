class CreateOwnerships < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def up
    create_table :ownerships do |t|
      t.integer :user_id, index: true
      t.integer :host_id, index: true
      t.timestamps
    end
  end

  def down
    drop_table :ownerships
  end
end
