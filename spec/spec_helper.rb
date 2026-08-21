# frozen_string_literal: true

require "bundler/setup"
require "fileutils"
require "pathname"
require "stringio"
require "tmpdir"
require "meetxt"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
