# frozen_string_literal: true

require_relative "syshare/version"
require_relative "syshare/components"
require "dry-types"

module Syshare
  class Error < StandardError; end

  module Types
    include Dry.Types()
  end
end
