module FlashHelper

  def bootstrap_class_for(flash_type)
    {
      success: 'alert-success',
      error:   'alert-danger',
      alert:   'alert-warning',
      notice:  'alert-info'
    }.fetch(flash_type.to_sym, flash_type.to_s)
  end

  def flash_messages
    flash.each do |msg_type, message|
      concat(
        content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
          concat content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
          concat message
        end
      )
    end

    nil
  end

  def notifier(msg)
    content_tag(:div, class: "alert #{bootstrap_class_for(msg[:severity])} fade in") do
      content_tag(:p, msg[:message])
    end
  end
end
