class AddVerifyDetailsToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :verified_at, :datetime
    add_column :hosts, :verifier_id, :integer
  end

  def down
    remove_column :hosts, :verified_at
    remove_column :hosts, :verifier_id
  end
end
