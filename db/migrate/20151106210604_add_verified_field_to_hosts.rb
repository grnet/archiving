class AddVerifiedFieldToHosts < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :hosts, :verified, :boolean, default: false
  end
end
