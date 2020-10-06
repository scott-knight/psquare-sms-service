# frozen_string_literal: true
# :nocov:

REDIS =
  if Rails.env.test?
    MockRedis.new
  else
    Redis.new(host: Rails.application.config.redis_host)
  end

# :nocov: