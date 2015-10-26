class AddStatusAndClientIdToHosts < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :hosts, :status, :integer, limit: 1, default: 0
    add_column :hosts, :client_id, :integer
  end
end
