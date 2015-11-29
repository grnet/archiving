class AddPasswordToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :password, :string
  end
end
