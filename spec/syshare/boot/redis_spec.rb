require "dry/system/container"
require "syshare/components"

module Syshare
  module Components
    RSpec.describe "Component: redis" do
      it "works with a default config" do
        app = Class.new(Dry::System::Container) do
          boot(:redis, from: :syshare)
        end

        expect(app[:redis].ping).to eql("PONG")
        expect(app["redis.pool"].with(&:ping)).to eql("PONG")
      end

      it "works without a connection pool" do
        app = Class.new(Dry::System::Container) do
          boot(:redis, from: :syshare) do
            configure do |config|
              config.use_connection_pool = false
            end
          end
        end

        expect(app[:redis].ping).to eql("PONG")
      end

      it "allows for driver to be configured" do
        app = Class.new(Dry::System::Container) do
          boot(:redis, from: :syshare) do
            configure do |config|
              config.use_connection_pool = false
              config.driver = "ruby"
            end

            after(:start) { |app| app[:redis].ping }
          end
        end

        expect(app[:redis]._client.connection).to be_a(Redis::Connection::Ruby)
      end

      it "sets up the logger if one is configured" do
        require "logger"

        output = StringIO.new

        app = Class.new(Dry::System::Container) do
          use :logging
          configure { config.logger = Logger.new(output) }
          boot(:redis, from: :syshare)
        end

        app[:redis].ping
        output.rewind

        expect(output.read).to match(/command=PING/)
      end
    end
  end
end
