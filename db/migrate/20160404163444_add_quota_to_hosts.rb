class AddQuotaToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :quota, :integer, limit: 8, default: Archiving.settings[:client_quota]
  end
end
