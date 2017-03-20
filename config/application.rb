require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MbMaintenanceUi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Access-Control-Allow-Origin を設定する方法
    # 参考 URL
    # <http://qiita.com/arakaji/items/f7d32e1c94d67b3e2606>
    # <http://qiita.com/kaorumori/items/0a53c248343892c8f35c>
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
      end
    end

  end
end
