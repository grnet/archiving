class Admin::PoolsController < Admin::BaseController
  before_action :fetch_pool, only: [:show, :edit, :update]

  # GET /admin/pools
  def index
    @pools = Pool.all
  end

  # GET /admin/pools/new
  def new
    @pool = Pool.new
  end

  # GET /admin/pools/:id/edit
  def edit; end

  # GET /admin/pools/:id
  def show; end

  # POST /admin/pools
  def create
    @pool = Pool.new(fetch_params)

    if @pool.submit_to_bacula
      flash[:success] = 'Pool created succesfully'
      redirect_to admin_pools_path
    else
      flash[:alert] = 'Pool not created'
      render :new
    end
  end

  # PATCH /admin/pools/:id
  def update
    if @pool.update_attributes(fetch_params)
      flash[:success] = 'Pool updated succesfully'
      redirect_to admin_pools_path
    else
      flash[:alert] = 'Pool not updated'
      render :edit
    end
  end

  private

  def fetch_pool
    @pool = Pool.find(params[:id])
  end

  def fetch_params
    params.require(:pool).permit(
      [
        :name, :name_confirmation, :vol_retention, :use_once, :auto_prune, :recycle,
        :max_vols, :max_vol_jobs, :max_vol_files, :max_vol_bytes, :label_format
      ]
    )
  end
end
