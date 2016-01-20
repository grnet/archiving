class AddPoolFieldToSettings < ActiveRecord::Migration
  def up
    add_column :configuration_settings, :pool, :string, default: {}.to_json
  end

  def down
    remove_column :configuration_settings, :pool
  end
end
