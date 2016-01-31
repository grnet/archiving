class AddMailRecipientsToHost < ActiveRecord::Migration
  def up
    add_column :hosts, :email_recipients, :string, default: [].to_json
  end

  def down
    remove_column :hosts, :email_recipients
  end
end
