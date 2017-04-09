class ChangeTempHostsOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :temp_hosts, :string, limit: 5000, default: [].to_json
  end

  def down
    change_column :users, :temp_hosts, :string, limit: 255, default: [].to_json
  end
end
