require "capistrano/anycable/version"

load File.expand_path('../tasks/anycable.rb', __FILE__)

module Capistrano
  module Anycable
    class Error < StandardError; end
    # Your code goes here...
  end
end
