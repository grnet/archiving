module ApplicationHelper
  # Custom helper for better display of big numbers
  # @example number_by_magnitude(4242)
  #  "4.2K"
  #
  # @param number[Numeric]
  # @return [String] human friendly respresentation
  def number_by_magnitude(number)
    number_to_human(number, units: { thousand: :K, million: :M, billion: :G })
  end

  # Creates a bootstrap form-group div with an additional 'Add' button next to the select field
  #
  # @param object[ActiveRecord::Object] the form's subject
  # @param resource[Symbol] the objects class
  # @param attr[Symbol] the select box's attribute
  # @param attr_name[String] the attribute's display name
  # @param options[Array] the select box options
  # @param path[String] the add button's path
  def select_with_errors_and_button(object, resource, attr, attr_name, options, path)
    has_errors = object.errors[attr].present?
    content_tag(:div, class: "form-group #{' has-error' if has_errors }") do
      attr_label = label(resource, attr, attr_name, class: 'control-label col-xs-5 required')
      select_div = content_tag(:div, class: 'col-xs-5') do
        select_part = select_tag([resource, attr].join('_').to_sym,
                                 options,
                                 include_blank: true,
                                 name: "#{resource}[#{attr}]",
                                 class: 'form-control'
                                )
        if has_errors
          select_part.concat(content_tag(:span, class: 'help-block') { object.errors[attr].first })
        end
        select_part
      end

      button_part = content_tag(:div, class: 'col-xs-1') do
        link_to path do
          content_tag(:span, class: 'glyphicon glyphicon-plus text-success') {}
        end
      end

      attr_label.concat(select_div).concat(button_part)
    end
  end

  # Returns a style class depending on the given parameter
  #
  # @param status[Char]
  def success_class(status)
    case status
      when 'T' then 'success'
      when 'E' then 'danger'
      when 'f' then 'fatal'
    end
  end

  # Fetches the html class for a given path
  #
  # @param path[String] the path to check for
  # @param partial[Boolean] forces a left partial match
  #
  # @return [Hash] { class: 'active' } if the given path is the current page
  def active_class(path, partial = false)
    if current_page?(path) || (partial && request.path.starts_with?(path))
      { class: 'active' }
    else
      {}
    end
  end

  # Constructs a breadcrumb out the given options
  #
  # @param options[Hash] a hash containing the breadcrumb links in name: path sets
  # @return an html ol breadcrumb
  def breadcrumb_with(options)
    content_tag(:ol, class: 'breadcrumb') do
      options.map { |name, path|
        content_tag(:li, active_class(path)) do
          link_to_if !current_page?(path), name, path
        end
      }.inject { |result, element| result.concat(element) }
    end
  end

  # Constructs a list with the given array elements
  #
  # @example:
  #  inline_list([:foo, :bar])
  #
  #  <ul class="list-inline'>
  #   <li><span class="label label-default">foo</span></li>
  #   <li><span class="label label-default">bar</span></li>
  #  </ul>
  #
  # @param arr[Array]
  # @return an html ul list
  def inline_list(arr)
    content_tag(:ul, class: 'list-inline') do
      arr.map { |element|
        content_tag(:li) do
          content_tag(:span, class: 'label label-default') do
            element
          end
        end
      }.inject { |result, element| result.concat(element) }
    end
  end

  # Generates a span with a yes or no and the corresponding formatting
  # according to the value's falseness
  #
  # @param value[Integer]
  def yes_no(value)
    klass = value == 1 ? 'label label-success' : 'label label-danger'
    text = value == 1 ? 'yes' : 'no'
    content_tag(:span, class: klass) { text }
  end

  # Generates a percentage and adds some color coding for better visibility
  #
  # @param ratio [Numeric] the ratio
  # @param quota [Integer] the client's space quota
  #
  # @return [String] an html label tag
  def pretty_percentage(ratio, quota)
    color = ([[ratio, 0.2].max, 0.99].min * 256).to_i.to_s(16) << '0000'

    content_tag(:label, class: 'label', style: "background-color:##{color}") do
      number_to_percentage(100 * ratio, precision: 1)
    end
  end
end
