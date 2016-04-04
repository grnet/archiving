class Admin::HostsController < Admin::BaseController
  before_action :fetch_host, only: [:verify, :set_quota]

  # GET /admin/hosts/unverified
  def unverified
    @hosts = Host.unverified
  end

  # POST /admin/hosts/1/verify
  def verify
    @host.verify(current_user.id)
    redirect_to unverified_admin_hosts_path
  end

  # PUT /admin/hosts/1/set_quota
  def set_quota
    @host.quota = params[:host][:quota]
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
