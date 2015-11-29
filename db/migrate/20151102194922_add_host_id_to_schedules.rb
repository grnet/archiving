class AddHostIdToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :host_id, :integer

    add_index :schedules, :host_id
  end
end
