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
      attr_label = label(resource, attr, attr_name, class: 'control-label col-xs-4 required')
      select_div = content_tag(:div, class: 'col-xs-6') do
        select_part = select_tag([resource, attr].join('_').to_sym,
                                 options,
                                 name: "#{resource}[#{attr}]",
                                 class: 'form-control'
                                )
        if has_errors
          select_part.concat(content_tag(:span, class: 'help-block') { object.errors[attr].first })
        end
        select_part
      end

      button_part = content_tag(:div, class: 'col-xs-1') do
        link_to 'Add', path, class: 'btn btn-primary', role: 'button'
      end

      attr_label.concat(select_div).concat(button_part)
    end
  end
end
