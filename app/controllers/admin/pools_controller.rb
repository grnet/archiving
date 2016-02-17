class Admin::PoolsController < Admin::BaseController

  # GET /admin/pools
  def index
    @pools = Pool.all
  end

  # GET /admin/pools/new
  def new
    @pool = Pool.new
  end

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

  private

  def fetch_params
    params.require(:pool).permit(
      [
        :name, :name_confirmation, :vol_retention, :use_once, :auto_prune, :recycle,
        :max_vols, :max_vol_jobs, :max_vol_files, :max_vol_bytes, :label_format
      ]
    )
  end
end
