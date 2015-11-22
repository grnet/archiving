class Admin::HostsController < Admin::BaseController
  before_action :fetch_host, only: [:show, :verify]

  # GET /admin/hosts/unverified
  def unverified
    @hosts = Host.unverified
  end

  # GET /admin/hosts/1
  def show
  end

  # POST /admin/hosts/1/verify
  def verify
    @host.verify(current_user.id)
    redirect_to unverified_admin_hosts_path
  end

  private

  def fetch_host
    @host = Host.find(params[:id])
  end
end