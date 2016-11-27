class AddNameToSimpleConfiguration < ActiveRecord::Migration
  def change
    add_column :simple_configurations, :name, :string
  end
end
