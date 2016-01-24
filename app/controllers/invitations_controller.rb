class InvitationsController < ApplicationController
  # POST /invitations
  def create
    invitation = Invitation.new(fetch_params)
    if invitation.save
      flash[:success] = "User #{invitation.user.username} has been invited to the client"
    else
      flash[:alert] = 'Invitation not created'
    end

    redirect_to :back
  end

  private

  def fetch_params
    params.require(:invitation).permit(:user_id, :host_id)
  end
end
