class InvitationsController < ApplicationController
  before_action :fetch_invitation, only: [:accept]

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

  # GET /invitations/:host_id/:verification_code
  def accept
    return redirect_to root_path unless @invitation
    host = @invitation.host
    if !@invitation.host.users.include? @invitation.user
      if @invitation.host.users << @invitation.user
        @invitation.destroy
      end
    else
      @invitation.destroy
    end

    redirect_to client_path(host.client)
  end

  private

  def fetch_params
    params.require(:invitation).permit(:user_id, :host_id)
  end

  def fetch_invitation
    @invitation = Invitation.find_by(host_id: params[:host_id],
                                   verification_code: params[:verification_code])
  end
end
