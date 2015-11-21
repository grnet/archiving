# Helper class that fetches job stats for the desired clients
class JobStats
  attr_reader :client_ids, :active_jobs, :last_jobs, :jobs_sizes, :jobs_files

  # Initializes the object.
  def initialize(client_ids=nil)
    @client_ids = client_ids
    fetch_stats
  end

  private

  # Assigns values to:
  #
  # * active_jobs
  # * last_jobs
  # * jobs_sizes
  # * jobs_files
  def fetch_stats
    @active_jobs = Job.running
    @active_jobs = @active_jobs.where(ClientId: client_ids) if client_ids
    @active_jobs = @active_jobs.group(:ClientId).count

    @last_jobs = {}
    @jobs_sizes = Hash.new { |h,k| h[k] = 0 }
    @jobs_files = Hash.new { |h,k| h[k] = 0 }

    jobs = Job.backup_type.order(EndTime: :asc)
    jobs = jobs.where(ClientId: client_ids) if client_ids
    jobs.each do |job|
      @last_jobs[job.client_id] = I18n.l(job.end_time, format: :long) if job.end_time
      @jobs_sizes[job.client_id] += job.job_bytes
      @jobs_files[job.client_id] += job.job_files
    end
  end
end
