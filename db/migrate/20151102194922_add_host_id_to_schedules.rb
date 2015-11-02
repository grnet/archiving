class AddHostIdToSchedules < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    add_column :schedules, :host_id, :integer

    add_index :schedules, :host_id
  end
end
