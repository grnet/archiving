class AddPasswordToHosts < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :hosts, :password, :string
  end
end
