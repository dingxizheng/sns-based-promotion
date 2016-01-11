require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "action_controller/railtie"
require "action_mailer/railtie"

require "bson"
require "moped"
Moped::BSON = BSON

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module GampApi
  class Application < Rails::Application
    # load configration
    Config::Integration::Rails::Railtie.preload
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # ActiveSupport::Dependencies.autoload_paths << "#{Rails.root}/lib/modules/mongoid_rateable"

    # config.autoload_paths += Dir["#{Rails.root}/lib/modules/*"]
    config.autoload_paths += Dir[Rails.root.join('lib', 'modules', '*')]
    
    config.active_job.queue_adapter = :delayed_job

    # log mongodb queries, updates into seperate file
    Moped.logger = Logger.new("#{ Rails.root }/log/#{ Rails.env }-mongodb.log")

    # custom logger
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new("#{ Rails.root }/log/#{ Rails.env }-rails.log"))

    # exception notification setup
    config.middleware.use ExceptionNotification::Rack,
        :email => {
            :email_prefix         => Settings.email_notificaion.email_prefix,
            :sender_address       => Settings.email_notificaion.sender_address,
            :exception_recipients => Settings.email_notificaion.exception_recipients
        }

    # config.force_ssl = true
  end
end
