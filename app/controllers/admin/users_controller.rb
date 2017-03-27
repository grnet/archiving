class Admin::UsersController < Admin::BaseController
  before_action :fetch_user, only: [:show, :edit, :update, :ban, :unban,
                                    :grant_admin, :revoke_admin]
  before_action :editable_users_only, only: [:edit, :update]

  # GET /admin/users
  def index
    @baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @non_baculized_host_names = Hash.new { |h, k| h[k] = [] }
    @unverified_host_names = Hash.new { |h, k| h[k] = [] }

    @users = User.all.includes(:hosts)
    @users = @users.admin if params[:type] == 'admin'
    @users = @users.vima if params[:type] == 'vima'
    @users = @users.institutional if params[:type] == 'institutional'
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
    @user = User.new(user_type: :admin)
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

  # GET /admin/users/1
  def show
  end

  # GET /admin/users/1/edit
  def edit
  end

  # PATCH /admin/users/1/update
  def update
    if @user.admin? && @user.update_attributes_and_password(fetch_params)
      flash[:success] = 'User updated'
      redirect_to admin_user_path(@user)
    elsif @user.admin?
      flash[:error] = 'User not updated'
      render :edit
    else
      flash[:error] = "User is #{@user.user_type} and thus accepts no updates"
      render :edit
    end
  end

  # PATCH /admin/users/1/ban
  def ban
    if @user.ban
      flash[:success] = 'User banned'
    else
      flash[:error] = 'User NOT banned'
    end

    redirect_to admin_users_path
  end

  # PATCH /admin/users/1/unban
  def unban
    if @user.unban
      flash[:success] = 'User enabled'
    else
      flash[:error] = 'User NOT enabled'
    end

    redirect_to admin_users_path
  end

  # PATCH /admin/users/1/revoke_admin
  def revoke_admin
    if @user.update_attribute(:moderator, false)
      flash[:success] = 'User is no longer an admin'
    else
      flash[:error] = 'Admin rights were NOT revoked'
    end

    redirect_to admin_users_path
  end

  # PATCH /admin/users/1/grant_admin
  def grant_admin
    if @user.update_attribute(:moderator, true)
      flash[:success] = 'User is now an admin'
    else
      flash[:error] = 'Admin rights were NOT granted'
    end

    redirect_to admin_users_path
  end


  private

  def fetch_params
    params.require(:user).permit(:username, :email, :password, :retype_password)
  end

  def fetch_user
    @user = User.find(params[:id])
  end

  def editable_users_only
    return if @user.editable?

    flash[:error] = "User #{@user.username} is not editable"
    redirect_to admin_users_path
  end
end
