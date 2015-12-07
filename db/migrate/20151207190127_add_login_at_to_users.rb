class AddLoginAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :login_at, :datetime
  end

  def down
    remove_column :users, :login_at
  end
end
