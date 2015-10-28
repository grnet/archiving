class CreateSchedules < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection(Baas::settings[:local_db]).connection
  end

  def change
    create_table :schedules do |t|
      t.string :name
      t.string :runs
    end
  end
end
