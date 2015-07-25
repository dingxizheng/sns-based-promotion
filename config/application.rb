require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "bson"
require "moped"

Moped::BSON = BSON
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
 
module GampApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.autoload_paths += Dir["#{config.root}/lib/modules/*"]
    
    config.active_job.queue_adapter = :delayed_job

    # log mongodb queries, updates into seperate file
    Moped.logger = Logger.new("#{ Rails.root }/log/#{ Rails.env }-mongodb.log")

    # custom logger
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new("#{ Rails.root }/log/#{ Rails.env }-rails.log"))

    config.exception_logger = ActiveSupport::TaggedLogging.new(Logger.new("#{ Rails.root }/log/#{ Rails.env }-rails-exceptions.log"))
    
    config.middleware.use ExceptionNotification::Rack,
        :email => {
            :email_prefix         => "[VICINITY SERVER ERROR]",
            :sender_address       => %{ "vicinity notifier" gampapp14@gmail.com },
            :exception_recipients => %w{ dingxizheng@gmail.com teepan.nanthakumar@gmail.com }
        }

    # config.force_ssl = true
  end
end
