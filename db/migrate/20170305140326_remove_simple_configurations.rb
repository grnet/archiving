class RemoveSimpleConfigurations < ActiveRecord::Migration
  def up
    drop_table :simple_configurations
  end

  def down
  end
end
