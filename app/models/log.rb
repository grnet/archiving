# Bacula Log table.
#
# The Log table contains a log of all Job output.
class Log < ActiveRecord::Base
  establish_connection BACULA_CONF

  self.table_name = "#{connection_config[:database]}.Log"
  self.primary_key = :LogId

  alias_attribute :log_id, :LogId
  alias_attribute :job_id, :JobId
  alias_attribute :time, :Time
  alias_attribute :log_text, :LogText

  belongs_to :job, foreign_key: :JobId

  paginates_per 20

  def time_formatted
    if time
      I18n.l(time, format: :long)
    end
  end

  # Extracts the log's compression info if there is any data available
  #
  # @return [String] the compression or nil
  def compression
    $1.strip if log_text =~ /.*Software Compression:(.*)\n.*/
  end

  # Extracts the log's encryption info if there is any data available
  #
  # @return [String] the encryption or nil
  def encryption
    $1.strip if log_text =~ /.*Encryption:(.*)\n.*/
  end
end
