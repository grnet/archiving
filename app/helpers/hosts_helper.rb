module HostsHelper
  # Returns an html span with the host's status
  def host_status_label(host)
    case
    when host.pending?
      klass = "default"
    when host.configured?
      klass = "warning"
    when host.dispatched?
      klass = "info"
    when host.deployed?
      klass = "success"
    when host.updated?
      klass = "info"
    when host.redispatched?
      klass = "primary"
    when host.for_removal?
      klass = "danger"
    end

    content_tag(:span, class: "label label-#{klass}") { host.human_status_name.upcase }
  end
end
