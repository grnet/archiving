class AddHostsUpdatedAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :hosts_updated_at, :datetime

    User.vima.update_all(hosts_updated_at: Time.now)
  end

  def down
    remove_column :users, :hosts_updated_at
  end
end
