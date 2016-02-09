module ChartHelper
  def archiving_chart(id, chart_options)
    html = <<-HTML
      <script type='text/javascript'>
        $(function () {
          $(document).ready(function () {
            #{id}_data = #{chart_options};
            $('##{id}').highcharts(#{id}_data);
          });
        });
      </script>
    HTML
    html.html_safe
  end
end
