class Admin::SettingsController < Admin::BaseController
  # GET /admin/settings
  def index
    @settings = ConfigurationSetting.last || ConfigurationSetting.new
  end

  # GET /admin/settings/1
  def show
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
  end

  # PATCH /admin/settings/1/update
  def update
  end

  # DELETE /admin/settings/1/delete
  def destroy
  end
end
