class AddBaculizedFieldToHosts < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :hosts, :baculized, :boolean, default: false, null: false
    add_column :hosts, :baculized_at, :datetime
  end
end
