require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DemoecLaiblitzB
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    config.active_storage.variant_processor = :mini_magick

    config.time_zone = 'Asia/Tokyo'
    config.i18n.default_locale = :ja
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    # config.eager_load_paths << Rails.root.join("extras")
  end
end

# module TimeFormatSandbox
#   class Application < Rails::Application
#     # ...

#     # タイムゾーンを日本時間に設定
#     config.time_zone = 'Asia/Tokyo'
    
#     # デフォルトのロケールを日本（ja）に設定
#     config.i18n.default_locale = :ja
#   end
# end

# module Error_messages_jp
#   class Application < Rails::Application
#     config.i18n.default_locale = :ja
#   end
# end

