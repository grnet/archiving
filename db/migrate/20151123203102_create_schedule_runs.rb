class CreateScheduleRuns < ActiveRecord::Migration
  def up
    create_table :schedule_runs do |t|
      t.integer :schedule_id
      t.integer :level, limit: 1
      t.string :month
      t.string :day
      t.string :time
      t.timestamps
    end

    add_index :schedule_runs, :schedule_id
  end

  def down
    drop_table :schedule_runs
  end
end
