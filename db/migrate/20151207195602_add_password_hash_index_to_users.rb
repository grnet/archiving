class AddPasswordHashIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :password_hash
  end
end
