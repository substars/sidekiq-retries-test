require './sidekiq_config'
Bundler.require(:web)

require 'sidekiq/web'
run Sidekiq::Web