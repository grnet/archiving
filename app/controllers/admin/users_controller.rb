class Admin::UsersController < Admin::BaseController
  # GET /admin/users
  def index
    @baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @non_baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @unverified_host_names = Hash.new { |h, k| h[k] = [] }

    @users = User.all.includes(:hosts)
    @users = @users.admin if params[:type] == 'admin'
    @users = @users.vima if params[:type] == 'vima'
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

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # POST /admin/users
  def create
    @user = User.new(fetch_params)

    @user.user_type = :admin
    if @user.add_password(@user.password)
      flash[:success] = 'User created'
      redirect_to admin_users_path
    else
      flash[:error] = 'User was not created'
      render 'new'
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

  private

  def fetch_params
    params.require(:user).permit(:username, :email, :password, :retype_password)
  end
end
