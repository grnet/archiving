class Chart < Hash
  class Pie
    attr_accessor :chart_opts

    def initialize(series, opts)
      @chart_opts = {
        chart: {
          plotBackgroundColor: nil,
          plotBorderWidth: nil,
          plotShadow: false,
          type: 'pie'
        },
        title: { text: opts[:title] },
        tooltip: { pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>' },
        plotOptions: {
          pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: { enabled: false },
            showInLegend: true
          }
        },
        series: [
          {
            name: opts[:name],
            colorByPoint: true,
            data: series
          }
        ]
      }
    end
  end

  class ColumnTwoAxis
    attr_accessor :chart_opts

    def initialize(series, opts)
      @chart_opts = {
        chart: { type: 'column' },
        title: { text: opts[:title] },
        xAxis: {
            categories: opts[:categories],
            crosshair: true
        },
        yAxis: opts[:yaxis],
        tooltip: { shared: true },
        plotOptions: {
            column: {
                pointPadding: 0.2,
                borderWidth: 0
            }
        },
        series: series
      }
    end
  end
end
