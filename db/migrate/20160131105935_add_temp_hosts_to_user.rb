class AddTempHostsToUser < ActiveRecord::Migration
  def up
    add_column :users, :temp_hosts, :string, default: [].to_json
  end

  def down
    remove_column :users, :temp_hosts
  end
end
