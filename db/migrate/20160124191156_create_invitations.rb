class CreateInvitations < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.references :user
      t.references :host
      t.string :verification_code
      t.timestamps
    end

    add_index :invitations, [:user_id, :verification_code]
  end

  def down
    drop_table :invitations
  end
end
