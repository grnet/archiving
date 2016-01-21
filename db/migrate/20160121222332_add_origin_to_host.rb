class AddOriginToHost < ActiveRecord::Migration
  def up
    add_column :hosts, :origin, :integer, limit: 1
  end

  def down
    remove_column :hosts, :origin
  end
end
