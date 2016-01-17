namespace :bvfs do
  desc 'Cleans up the restore database'
  task cleanup: :environment do
    for_purge = ActiveRecord::Base.connection.tables.select do |name|
      match_data = name.match(/^b2\d+(\d{12}$)/)
      match_data.present? && 
        match_data[1].present? &&
        match_data[1] < (Archiving.settings[:temp_db_retention].ago.to_f * 100).to_i.to_s
    end

    for_purge.each do |dbname|
      Bvfs.new(nil,[]).purge_db(dbname)
    end

    Rails.logger.warn("[BVFS]: Cleaned up dbs: #{for_purge.join(', ')}")
  end
end
