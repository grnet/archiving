class AddPasswordHashToUsers < ActiveRecord::Migration
  def up
    add_column :users, :password_hash, :string, index: true
  end

  def down
    remove_column :users, :password_hash
  end
end
