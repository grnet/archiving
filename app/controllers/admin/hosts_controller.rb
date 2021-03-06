class Admin::HostsController < Admin::BaseController
  before_action :fetch_host, only: [:verify, :reject, :set_quota]

  # GET /admin/hosts/unverified
  def unverified
    @hosts = Host.unverified
  end

  # GET /admin/hosts/pending
  def pending
    @hosts = Host.where(verified: true).not_baculized
  end

  # GET /admin/hosts/rejected
  def rejected
    @hosts = RejectedHost.order(created_at: :desc)
  end

  # POST /admin/hosts/1/verify
  def verify
    if @host.verify(current_user.id)
      UserMailer.notify_admin_for_verification(current_user, @host.fqdn).deliver
    end

    redirect_to unverified_admin_hosts_path
  end

  # POST /admin/hosts/1/reject
  def reject
    msg = 'You need to provide a reason' if params[:reason].blank?
    msg = 'Host is already verified' if @host.verified?

    if msg.blank?
      if @host.reject(current_user.id, params[:reason])
        flash[:success] = 'Client rejected'
      else
        flash[:error] = 'Something went wrong'
      end
    else
      flash[:error] = msg
    end
    redirect_to unverified_admin_hosts_path
  end

  # PUT /admin/hosts/1/set_quota
  def set_quota
    @host.quota = case params[:unit]
      when 'MB'
        params[:quota].to_i * ConfigurationSetting::MEGA_BYTES
      when 'GB'
        params[:quota].to_i * ConfigurationSetting::GIGA_BYTES
      when 'TB'
        params[:quota].to_i * ConfigurationSetting::TERA_BYTES
      end

    if @host.save
      flash[:success] = 'Changes saved'
    else
      flash[:error] = 'Changes not saved'
    end

    redirect_to admin_client_path(@host.client)
  end

  private

  def fetch_host
    @host = Host.find(params[:id])
  end
end
