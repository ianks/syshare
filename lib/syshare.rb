# frozen_string_literal: true

require_relative "syshare/version"
require_relative "syshare/components"
require "dry-types"

module Syshare
  class Error < StandardError; end

  def self.require_gem(gem_name)
    require gem_name
  rescue LoadError => e
    warn "The #{gem_name} gem is not available. Please add it to your Gemfile and run bundle install"
    raise e
  end

  module Types
    include Dry.Types()
  end
end
