# frozen_string_literal: true

module Syshare
  ::Dry::System.register_component(:redis, provider: :syshare) do
    settings do
      key :url, Types::String.default(ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
      key :connect_timeout, Types::Integer.default(5)
      key :read_timeout, Types::Integer.default(1)
      key :write_timeout, Types::Integer.default(1)
      key :reconnect_attempts, Types::Integer.default(3)
      key :driver, Types::String.default("hiredis").enum("ruby", "hiredis", "synchrony")
      key :use_connection_pool, Types::Bool.default(true)
      key :pool_timeout, Types::Integer.default(5)
      key :pool_size, Types::Integer.default(5)
    end

    init do
      Syshare.require_gem "redis"
      Syshare.require_gem "connection_pool" if config.use_connection_pool

      case config.driver
      when "synchrony"
        Syshare.require_gem("em-synchrony")
      when "hiredis"
        Syshare.require_gem("hiredis")
      end
    end

    start do
      redis_conf = config.to_h
      redis_conf[:logger] = target.logger if target.respond_to?(:logger)

      if config.use_connection_pool
        pool_config = {size: config.pool_size, timeout: config.pool_timeout}
        pool = ConnectionPool.new(pool_config) { Redis.new(redis_conf.to_h) }
        register("redis.pool", pool)
        register("redis", ConnectionPool::Wrapper.new(pool: pool))
      else
        register("redis", Redis.new(redis_conf.to_h))
      end
    end

    stop do
      if config.use_connection_pool
        redis.shutdown(&:disconnect!)
      else
        redis.disconnect!
      end
    end
  end
end
