# frozen_string_literal: true

return unless ENV["COVERAGE"] && ENV["COVERAGE"] != "false"

require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch if respond_to?(:enable_coverage)

  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"
  add_filter "/bin/"

  minimum_coverage line: 70
end
