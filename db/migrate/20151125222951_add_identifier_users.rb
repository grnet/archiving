class AddIdentifierUsers < ActiveRecord::Migration
  def up
    add_column :users, :identifier, :string

    add_index :users, :identifier
  end

  def down
    remove_column :users, :identifier
  end
end
