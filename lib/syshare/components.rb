require "dry/system"

module Syshare
  module Components
    Dry::System.register_provider(
      :syshare,
      boot_path: Pathname(__dir__).join("boot").realpath
    )
  end
end
