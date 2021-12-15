# frozen_string_literal: true

module Syshare
  ::Dry::System.register_component(:dalli, provider: :syshare) do
    settings do
      key :servers, Types.Array(Types::String).optional.default(nil)
      key :username, Types::String.optional.default(nil)
      key :password, Types::String.optional.default(nil)
      key :expires_in, Types::Coercible::Integer.default(0)
      key :cache_nils, Types::Bool.default(false)
      key :namespace, Types::String.optional.default(nil)
      key :value_max_bytes, Types::Integer.default(1024 * 1024)
      key :serializer, Types.Interface(:dump, :load).default(Marshal, shared: true)
      key :compress, Types::Bool.default(true)
      key :failover, Types::Bool.default(true)
      key :socket_timeout, Types::Coercible::Integer.default(1)
      key :socket_failure_delay, Types::Float.default(0.2)
      key :down_retry_delay, Types::Coercible::Integer.default(60)
      key :use_connection_pool, Types::Bool.default(true)
      key :pool_timeout, Types::Coercible::Integer.default(5)
      key :pool_size, Types::Coercible::Integer.default(5)
    end

    init do
      Syshare.require_gem "dalli"
      Syshare.require_gem "connection_pool" if config.use_connection_pool
    end

    start do
      dalli_conf = config.to_h
      servers = dalli_conf.delete(:servers)

      Dalli.logger = target.logger if target.respond_to?(:logger)

      if config.use_connection_pool
        pool_config = {size: config.pool_size, timeout: config.pool_timeout}
        pool = ConnectionPool.new(pool_config) do
          Dalli::Client.new(servers, **dalli_conf.to_h, threadsafe: false)
        end
        register("dalli.pool", pool)
        register("dalli", ConnectionPool::Wrapper.new(pool: pool))
      else
        register("dalli", Dalli::Client.new(servers, dalli_conf))
      end
    end

    stop do
      if config.use_connection_pool
        dalli.shutdown(&:close)
      else
        dalli.close
      end
    end
  end
end
