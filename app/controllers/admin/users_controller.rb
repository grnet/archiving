class Admin::UsersController < Admin::BaseController
  # GET /admin/users
  def index
    @baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @non_baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @unverified_host_names = Hash.new { |h, k| h[k] = [] }

    @users = User.all.includes(:hosts)
    @users.each do |user|
      user.hosts.each do |host|
        if host.deployed? || host.updated? || host.dispatched? || host.for_removal?
          @baculized_host_names[user.id] << host.name
        else
          @non_baculized_host_names[user.id] << host.name
          @unverified_host_names[user.id] << host.name if !host.verified?
        end
      end
    end
  end

  # PATCH /admin/users/1/ban
  def ban
    @user = User.find(params[:id])
    if @user.ban
      flash[:success] = 'User banned'
    else
      flash[:error] = 'User NOT banned'
    end

    redirect_to admin_users_path
  end

  # PATCH /admin/users/1/unban
  def unban
    @user = User.find(params[:id])
    if @user.unban
      flash[:success] = 'User enabled'
    else
      flash[:error] = 'User NOT enabled'
    end

    redirect_to admin_users_path
  end
end
