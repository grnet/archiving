class GlobalStats
  include ActionView::Helpers::NumberHelper

  def stats
    {
      Clients: Client.count,
      Jobs: Job.count,
      FileSets: FileSet.count,
      Schedules: Schedule.count,
      TotalBytes: number_to_human_size(Job.sum(:job_bytes)),
      TotalFiles: number_to_human(Job.sum(:job_files),
                                  units: { thousand: :K, million: :M, billion: :G },
                                  precision: 5, significant: false),
      Volumes: Media.count,
      VolumesSize: number_to_human_size(Media.sum(:VolBytes)),
      Pools: Pool.count,
      DatabaseSize: number_to_human_size(db_size, precision: 2, significant: false)
    }
  end

  private

  def db_size
    ActiveRecord::Base.connection.
      execute("select sum(data_length + index_length) from information_schema.TABLES where TABLE_SCHEMA='bacula';").
      first.first.to_f
  rescue
    0
  end
end
#Database Size
