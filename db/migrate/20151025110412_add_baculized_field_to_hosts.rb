class AddBaculizedFieldToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :baculized, :boolean, default: false, null: false
    add_column :hosts, :baculized_at, :datetime
  end
end
