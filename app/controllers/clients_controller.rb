class ClientsController < ApplicationController
  before_action :set_client, only: :show

  # GET /clients
  def index
    client_ids = Client.for_user(current_user.id).pluck(:ClientId)
    @clients = Client.where(ClientId: client_ids).includes(:jobs)
    @active_jobs = Job.running.where(ClientId: client_ids).group(:ClientId).count
    @hosts = current_user.hosts.not_baculized
  end

  # GET /clients/1
  def show; end

  private

  def set_client
    @client = Client.for_user(current_user.id).find(params[:id])
  end
end
