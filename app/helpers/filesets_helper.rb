module FilesetsHelper
  # Creates a bootstrap form-group div with an additional 'Remove' button next to the text field
  #
  # @param object[ActiveRecord::Object] the form's subject
  # @param resource[Symbol] the objects class
  # @param attr[Symbol] the select box's attribute
  # @param attr_name[String] the attribute's display name
  # @param placeholder[String] the text box's placeholder
  def text_with_errors_and_remove(object, resource, attr,
                                  attr_name, placeholder, value=nil, no_sign=false)
    has_errors = object.errors[attr].present?
    content_tag(:div, class: "form-group #{attr} #{' has_error' if has_errors }") do
      attr_label = label(resource, attr, attr_name, class: 'control-label col-xs-3')
      text_div = content_tag(:div, class: 'col-xs-6') do
        text_part = text_field_tag([resource, attr].join('_').to_sym,
                                   value || object.send(attr.to_sym),
                                   placeholder: placeholder,
                                   name: "#{resource}[#{attr}][]",
                                   multiple: true,
                                   class: 'form-control'
                                  ) {}

        if has_errors
          text_part.concat(content_tag(:span, class: 'help-block') { object.errors[attr].first })
        end
        text_part
      end

      actions_part = content_tag(:div, class: 'col-xs-1') do
        attrs = { href: '#', class: "#{attr}-remove-sign" }
        attrs[:style] = "display:none" if value.nil? || no_sign

        remove_link = content_tag(:a, attrs) do
          content_tag(:span, class: 'glyphicon glyphicon-remove text-danger') {}
        end
      end

      attr_label.concat(text_div).concat(actions_part)
    end
  end
end
