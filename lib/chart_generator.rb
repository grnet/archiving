module ChartGenerator
  extend self

  def job_statuses(clients, days_ago)
    result = {
      'Running'   => { y: 0, color: '#D9EDF7' },
      'Completed' => { y: 0, color: '#DFF0D8' },
      'Canceled'  => { y: 0, color: '#999999' },
      'Failed'    => { y: 0, color: '#FFDEDE' },
      'Waiting'   => { y: 0, color: '#FCF8E3' },
    }

    Job.where(ClientId: clients).
        where('StartTime > :time OR SchedTime > :time', time: days_ago.days.ago).
        group(:JobStatus).count.each do |k,v|
      if k == 'R'
        result['Running'][:y] += v
      elsif k == 'T'
        result['Completed'][:y] += v
      elsif ['f', 'E'].include? k
        result['Failed'][:y] += v
      elsif k == 'A'
        result['Canceled'][:y] += v
      elsif ["C","F", "M", "S", "c", "d", "j", "m", "p", "s", "t"].include? k
        result['Waiting'][:y] += v
      end
    end

    series = result.map { |k,v| { name: "#{v[:y]} #{k}", y: v[:y], color: v[:color] } }

    Chart::Pie.new(
      series,
      title: 'Job Status',
      name: 'Status'
    ).chart_opts.to_json
  end

  def job_stats(clients, days_ago)
    days = days_ago.downto(0).map {|x| I18n.l(x.days.ago.to_date, format: :short) }
    year_days = days_ago.downto(0).map {|x| x.days.ago.yday }

    yaxis = [
      {
        title: { text: 'Bytes Size' },
        labels: { format: '{value} MB' },
        opposite: true
      },
      {
        title: { text: 'Files Count' },
        labels: { format: '{value} Files' }
      }
    ]

    files_data = year_days.map { |x| [x, 0] }.to_h
    bytes_data = year_days.map { |x| [x, 0] }.to_h

    Job.where(ClientId: clients, JobStatus: 'T').
      where(EndTime: days_ago.days.ago.end_of_day..Time.now.end_of_day).each do |job|
        files_data.merge!(Hash[job.end_time.yday, job.job_files.to_i]) do |_, old_v, new_v|
          old_v + new_v
        end

        bytes_data.merge!(Hash[job.end_time.yday, (job.job_bytes.to_f / 1048576).round(1)]) do |_, old_v, new_v|
          old_v + new_v
        end
    end

    files = { name: 'Files Count', data: files_data.values, yAxis: 1, tooltip: { valueSuffix: '' } }
    bytes = { name: 'Bytes Size', data: bytes_data.values, yAxis: 0, tooltip: { valueSuffix: 'MB'} }

    Chart::ColumnTwoAxis.new(
      [files, bytes],
      title: 'Job Stats',
      categories: days,
      yaxis: yaxis
    ).chart_opts.to_json
  end
end
