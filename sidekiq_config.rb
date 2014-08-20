require 'bundler/setup'
Bundler.setup(:default, :web)
Bundler.require(:default)

Sidekiq.configure_server do |config|
  config.redis = {namespace: 'retries'}

  config.server_middleware do |chain|
  end
end


Sidekiq.configure_client do |config|
  config.redis = {namespace: 'retries'}
end

require 'sidekiq/retries'

class RetryJob
  include Sidekiq::Worker
  sidekiq_options retry: 10

  def perform(*args)
    raise Sidekiq::Retries::Fail.new(RuntimeError.new('do not retry'))
  end
end

class RetryZeroJob
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(*args)
    raise Sidekiq::Retries::Fail.new(RuntimeError.new('do not retry'))
  end
end

class NonRetryJob
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*args)
    raise Sidekiq::Retries::Retry.new(RuntimeError.new('retry it anyway'))
  end
end

class NonRetryJobTenTimes
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*args)
    raise Sidekiq::Retries::Retry.new(RuntimeError.new('retry it ten times'), 10)
  end
end
