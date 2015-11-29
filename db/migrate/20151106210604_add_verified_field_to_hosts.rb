class AddVerifiedFieldToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :verified, :boolean, default: false
  end
end
