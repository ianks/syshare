require "dry/system/container"
require "syshare/components"

module Syshare
  module Components
    RSpec.describe "Component: dalli" do
      it "works with a default config" do
        app = Class.new(Dry::System::Container) do
          boot(:dalli, from: :syshare)
        end

        app[:dalli].set("abc", 123)
        expect(app[:dalli].get("abc")).to eql(123)
      end

      it "works without a connection pool" do
        app = Class.new(Dry::System::Container) do
          boot(:dalli, from: :syshare) do
            configure do |config|
              config.use_connection_pool = false
            end
          end
        end

        app[:dalli].set("abc", 123)
        expect(app[:dalli].get("abc")).to eql(123)
      end

      it "sets up the logger if one is configured" do
        require "logger"

        output = StringIO.new

        app = Class.new(Dry::System::Container) do
          use :logging
          configure { config.logger = Logger.new(output) }
          boot(:dalli, from: :syshare)
        end

        app[:dalli].set("abc", 123)
        output.rewind

        expect(output.read).to match(/Dalli::Server#connect/)
      end

      [
        [:serializer, :invalid],
        [:servers, Object.new],
        [:namespace, Object.new]
      ].each do |config_option, invalid_value|
        it "fails with an invalid #{config_option}" do
          app = Class.new(Dry::System::Container) do
            boot(:dalli, from: :syshare) do
              configure do |config|
                config.__send__("#{config_option}=", invalid_value)
              end
            end
          end

          expect do
            app[:dalli].set("abc", 123)
          end.to raise_error(Dry::Struct::Error)
        end
      end
    end
  end
end
