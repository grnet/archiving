class CreateUsersTable < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.integer :user_type, limit: 1, null: false
      t.boolean :enabled, default: false
      t.timestamps
    end
  end
end
