class AddIdentifierUsers < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def up
    add_column :users, :identifier, :string

    add_index :users, :identifier
  end

  def down
    remove_column :users, :identifier
  end
end
