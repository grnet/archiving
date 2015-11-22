module SettingsHelper
  # Creates an html table for the given attributes
  #
  # @example table_for( a: 1, b: 2 )
  #   <div>
  #     <table>
  #       <tr>
  #         <td><b>A</b></td>
  #         <td>1</td>
  #       </tr>
  #       <tr>
  #         <td><b>B</b></td>
  #         <td>2</td>
  #       </tr>
  #     </table>
  #   </div>
  #
  # @param attributes[Hash]
  # @returns [String] Html table
  def table_for(attributes)
    content_tag(:div, class: 'table-responsive') do
      content_tag(:table, class: 'table table-striped table-bordered table-condensed') do
        attributes.map { |key, value|
          "<tr><td><b>#{key.to_s.titleize}</b></td><td>#{value}</td></tr>"
        }.inject { |result, element| result.concat(element) }.html_safe
      end
    end
  end
end
