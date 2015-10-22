class ClientsController < ApplicationController
  before_action :set_client, only: :show

  # GET /clients
  def index
    @clients = Client.includes(:jobs).all
    @active_jobs = Job.running.group(:ClientId).count
  end

  # GET /clients/1
  def show; end

  private

  def set_client
    @client = Client.find(params[:id])
  end
end
