class UsersController < ApplicationController

  # GET users/1
  def show; end

  # PATCH users/1/generate_token
  def generate_token
    if current_user.create_token
      flash[:success] = 'Token created'
    else
      flash[:error] = 'Token not created'
    end

    redirect_to user_path(current_user)
  end
end
