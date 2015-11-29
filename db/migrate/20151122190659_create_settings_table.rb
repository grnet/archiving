class CreateSettingsTable < ActiveRecord::Migration
  def up
    create_table :configuration_settings do |t|
      t.string :job, default: {}.to_json
      t.string :client, default: {}.to_json
      t.timestamps
    end
  end

  def down
    drop_table :configuration_settings
  end
end
