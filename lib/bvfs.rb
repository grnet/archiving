class Bvfs
  attr_accessor :client, :jobids, :files, :dirs

  def initialize(client, jobids)
    @jobids = jobids.join(',')
    @client = client
  end

  # Fetches the directories that exist in the given directory and
  # stores the output to the result instance variable
  #
  # @param pathid[String|Integer] If nil or omitted, root directory is implied
  def fetch_dirs(pathid=nil)
    path = pathid.nil? ? 'path=\"\"':"pathid=#{pathid}"
    command = pipe_to_bconsole(".bvfs_lsdirs jobid=#{jobids} #{path}")
    @dirs = exec_command(command)
  end

  # Fetches the files that exist in the given directory and
  # stores the output to the result instance variable
  #
  # @param pathid[String|Integer] If nil or omitted, root directory is implied
  def fetch_files(pathid=nil)
    path = pathid.nil? ? 'path=\"\"':"pathid=#{pathid}"
    command = pipe_to_bconsole(".bvfs_lsfiles jobid=#{jobids} #{path}")
    @files = exec_command(command)
  end

  # Extracts the id and name of the bvfs_lsdirs command
  def extract_dir_id_and_name
    dirs.
      split("\n").
      select { |x| x[/^(\d+\W){4}.*[^.]/] }.
      map {|x| s = x.split("\t"); [s.first, s.last.gsub(/(.)\/$/, '\\1')] }.
      select { |x| !['.', '..'].include?(x.last) }.
      to_h
  end

  # Extracts the id and name of the bvfs_lsfiles command
  def extract_file_id_and_name
    files.
      split("\n").
      select { |x| x[/^(\d+\W){4}.*[^.]/] }.
      map {|x| s = x.split("\t"); [s.third, s.last] }.
      select { |x| !['.', '..'].include?(x.last) }.
      to_h
  end

  # Updates the bvfs cache for the specific job ids.
  # This can take some time. Always provide a job id.
  def update_cache
    command = pipe_to_bconsole(".bvfs_update jobid=#{jobids}")
    exec_command(command)
  end

  # Handles restore of multiple selected files and directories
  #
  # * creates a db table with the needed files
  # * issues the restore
  # * cleans up the table
  #
  # @param file_ids[Array] the file ids that will be restored
  # @param location[String] the client's restore location
  # @param dir_ids[Array] the directory ids that will be restored
  def restore_selected_files(file_ids, location  = nil, dir_ids = nil)
    location ||= '/tmp/bacula_restore/'
    dir_ids ||= []

    dbname = "b2#{client.id}#{(Time.now.to_f * 100).to_i}"

    shell_command = [
      create_restore_db(dbname, file_ids, dir_ids),
      restore_command(dbname, location),
      clear_cache
    ].map { |command| pipe_to_bconsole(command) }.join(' && ')

    Rails.logger.warn("[BVFS]: #{shell_command}")
    pid = spawn shell_command
    Process.detach(pid)
  end

  # Issues the bvfs command for cleaning up a temporary db table
  #
  # @param dbname[String] the database table's name
  def purge_db(dbname)
    exec_command(pipe_to_bconsole(".bvfs_cleanup path=#{dbname}"))
  end

  private

  # Generates the bvfs command needed in order to create a temporary database
  # that will hold the files that we want to restore.
  #
  # @param file_ids[Array] the file ids that will be restored
  # @param dir_ids[Array] the directory ids that will be restored
  #
  # @return [String] bvfs restore command
  def create_restore_db(dbname, file_ids, dir_ids)
    params = "jobid=#{jobids} path=#{dbname}"
    params << " fileid=#{file_ids.join(',')}" if file_ids.any?
    params << " dirid=#{dir_ids.join(',')}" if dir_ids.any?

    ".bvfs_restore #{params}"
  end

  # Generates the restore command
  #
  # @param dbname[String] the name of the db table that has the desired files
  # @param location[String] the client's restore location
  #
  # @return [String] bconsole's restore command
  def restore_command(dbname, location)
    "restore file=?#{dbname} client=\\\"#{client.name}\\\" where=\\\"#{location}\\\" yes"
  end

  def clear_cache
    '.bvfs_clear_cache yes'
  end

  def exec_command(command)
    Rails.logger.warn("[BVFS]: #{command}")
    `#{command}`
  end

  def pipe_to_bconsole(what)
    "echo \"#{what}\" | #{bconsole}"
  end

  def bconsole
    "bconsole -c #{Rails.root}/config/bconsole.conf"
  end
end
