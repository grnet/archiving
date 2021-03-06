class Admin::SettingsController < Admin::BaseController
  before_action :fetch_configuration_settings, only: [:edit, :update, :reset]

  # GET /admin/settings
  def index
    @settings = ConfigurationSetting.last || ConfigurationSetting.new
  end

  # GET /admin/settings/new
  def new
    @setting = ConfigurationSetting.new
  end

  # GET /admin/settings/1/edit
  def edit
  end

  # POST /admin/settings
  def create
    @setting = ConfigurationSetting.new(fetch_params)
    if @setting.save
      flash[:success] = 'Configuration Submitted'
      redirect_to admin_settings_path
    else
      flash[:error] = 'Configuration was not submitted'
      render :new
    end
  end

  # PATCH /admin/settings/1/update
  def update
    if fetch_params.present? && @setting.update_attributes(fetch_params)
      flash[:success] = 'Configuration Submitted'
      redirect_to admin_settings_path
    else
      flash[:error] = 'Configuration was not submitted'
      render :edit
    end
  end

  # DELETE /admin/settings/1/reset
  def reset
    @setting.destroy
    redirect_to admin_settings_path
  end

  private

  def fetch_configuration_settings
    @setting = ConfigurationSetting.find(params[:id])
  end

  def fetch_params
    return @clean_params if @clean_params.present?

    @clean_params = required_params

    @clean_params[:client][:quota] = case @clean_params[:client].delete(:quota_unit)
    when 'MB'
      @clean_params[:client][:quota].to_i * ConfigurationSetting::MEGA_BYTES
    when 'GB'
      @clean_params[:client][:quota].to_i * ConfigurationSetting::GIGA_BYTES
    when 'TB'
      @clean_params[:client][:quota].to_i * ConfigurationSetting::TERA_BYTES
    end

    @clean_params
  end

  def required_params
    params.require(:configuration_setting).
      permit(
        job: [:storage, :pool, :messages, :priority, :'Write Bootstrap'],
        client: [:catalog, :file_retention, :file_retention_period_type, :job_retention,
                 :job_retention_period_type, :autoprune, :quota, :quota_unit],
        pool: [:full, :differential, :incremental]
      )
  end
end
