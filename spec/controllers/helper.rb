require_relative '../helper'
require "sinatra"

# To keep requires unnecessary throughout the project, I avoid inheriting
# every time I open the class. So, let's make sure the class inherits the right
# thing.
module Rack
  class Lotus < Sinatra::Base
  end
end

# Test environment
set :environment, :test

# Merge in rack testing methods
require 'rack/test'
include Rack::Test::Methods

# Let the testing methods know what the app class is
def app
  Rack::Lotus
end

# Convenience function to load the controller source.
def require_controller(name)
  require_relative "../../lib/rack/lotus/controllers/#{name}"
end

# Convenience method to 'sign in' as the given username
def login_as(username, author = nil)
  person = stub('Person')
  person.stubs(:id).returns("current_person")
  if author.nil?
    author = stub('Author')
    author.stubs(:nickname).returns(username)
    author.stubs(:short_name).returns(username)
    author.stubs(:name).returns(username)
    author.stubs(:preferred_username).returns(username)
    author.stubs(:display_name).returns(username)
    author.stubs(:id).returns("current_author")
  end
  person.stubs(:author).returns(author)

  Rack::Lotus.any_instance.stubs(:current_person).returns(person)

  person
end

# Helper to give back the content type of the response
def content_type
  last_response.content_type.match(/([^;]+);?/)[1]
end

# Helper to set up accept parameter
def accept(type)
  header "Accept", type
end

module Rack
  class Lotus
    # Default current_person to nil
    def current_person
      nil
    end

    # Helper for session testing
    def session
      @helper_session ||= Class.new do
        # Do not let a session key be set by any means other than
        # a stub.
        def self.[]=(key, value)
          raise "Session key set"
        end

        # Read bogus value. Stub for more control.
        def self.[](key)
          "SESSION_VALUE_#{key}"
        end
      end
    end
  end
end

# Add helper to check that render local exists
module Mocha
  module ParameterMatchers
    def has_local(*options)
      case options.length
      when 1
        key, value = options[0].first
      when 2
        key, value = options
      end

      HasLocal.new(key, value)
    end

    class HasLocal < Base
      def initialize(key, value)
        @key, @value = key, value
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        return false unless parameter.respond_to?(:keys) &&
                            parameter.respond_to?(:[])

        return false unless parameter.keys.include? :locals

        parameter = parameter[:locals]
        matching_keys = parameter.keys.select { |key| @key.to_matcher.matches?([key]) }
        matching_keys.any? { |key| @value.to_matcher.matches?([parameter[key]]) }
      end

      def mocha_inspect
        "has_local(#{@key.mocha_inspect} => #{@value.mocha_inspect})"
      end
    end

    def has_object_with_entry(*options)
      case options.length
      when 1
        key, value = options[0].first
      when 2
        key, value = options
      end

      HasObjectWithEntry.new(key, value)
    end

    class HasObjectWithEntry < Base
      def initialize(key, value)
        @key, @value = key, value
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        return false unless parameter.respond_to?(:keys) &&
                            parameter.respond_to?(:[])

        return false unless parameter.keys.include? :object

        parameter = parameter[:object]
        parameter.send(key) == value
      end

      def mocha_inspect
        "has_object_with_entry(#{@key.mocha_inspect} => #{@value.mocha_inspect})"
      end
    end
  end
end
