# frozen_string_literal: true

require_relative "syshare/version"
require "dry-types"

module Syshare
  class Error < StandardError; end

  module Types
    include Dry.Types()
  end
end
