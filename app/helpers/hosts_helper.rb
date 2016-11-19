module HostsHelper
  # Returns an html span with the host's status
  def host_status_label(host)
    return unless host

    case
    when host.pending?
      klass = "default"
      msg = 'Client is not configured yet. No backups available'
    when host.configured?
      klass = "warning"
      msg = 'Client is configured. Configuration not yet sent to the backup server. No backups available'
    when host.dispatched?
      klass = "info"
      msg = 'Client is configured. Configuration not yet sent to the backup server. No backups available'
    when host.deployed?
      klass = "success"
      msg = 'Client is OK'
    when host.updated?
      klass = "info"
      msg = 'Client has new configuration, not yet transmitted to the server. Backups are available for the previous config'
    when host.redispatched?
      klass = "primary"
      msg = 'Client has new configuration, not yet transmitted to the server. Backups are available for the previous config'
    when host.for_removal?
      klass = "danger"
      msg = 'Client will be removed'
    when host.inactive?
      klass = "warning"
      msg = 'Client is not yet verified'
    when host.blocked?
      klass = "warning"
      msg = 'Client is blocked by an administrator. No backups available'
    end

    content_tag(:small, 'data-toggle' => 'tooltip', title: msg) do
      content_tag(:span, class: "label label-#{klass}") { host.human_status_name.upcase }
    end
  end
end
