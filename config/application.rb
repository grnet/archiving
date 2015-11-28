require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Production doesn't use bundler
# you've limited to :test, :development, or :production.
if ENV['RAILS_ENV'] != 'production'
  Bundler.require(*Rails.groups)
else
  # Dependencies to load before starting rails in production
  require 'kaminari'
  require 'jquery-rails'
  require 'state_machine'
  require 'beaneater'
  require 'oauth2'
  require 'warden'
  require 'net/scp'
end

module Baas
  def self.settings opts = nil
    @settings ||= {}

    return @settings if opts.nil?
    @settings.merge! opts
    @settings
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Store/Read localtime from the database
    config.time_zone = 'Athens'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths << Rails.root.join('lib')

#    config.x = {}
  end

#  def self.settings
#    Application.config.x
#  end

  def self.bean
    @bean ||= Bean::Client.new(
      YAML.load_file(Rails.root.join('config', 'beanstalk.yml'))[Rails.env].symbolize_keys[:host]
    )
  end
end
