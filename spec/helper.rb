require 'minitest/spec'
require 'turn/autorun'

Turn.config do |c|
  c.natural = true
end

require "mocha/setup"

require 'lotus'
require 'lotus-mongodb'
require './lib/rack/lotus'

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
  require_relative "../lib/rack/lotus/controllers/#{name}"
end

# Convenience method to 'sign in' as the given username
def login_as(username, person = nil)
  if person.nil?
    person = stub('Person')
    person.stubs(:id).returns("current_person")
    person.stubs(:nickname).returns(username)
    person.stubs(:short_name).returns(username)
    person.stubs(:name).returns(username)
    person.stubs(:preferred_username).returns(username)
    person.stubs(:display_name).returns(username)
  end

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

    def has_local_of_type(*options)
      case options.length
      when 1
        key, value = options[0].first
      when 2
        key, value = options
      end

      HasLocalOfType.new(key, value)
    end

    class HasLocalOfType < Base
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
        matching_keys.any? { |key| @value.to_matcher.matches?([parameter[key].class]) }
      end

      def mocha_inspect
        "has_local_of_type(#{@key.mocha_inspect} => #{@value.mocha_inspect})"
      end
    end

    def has_local_includes(local, value)
      HasLocalIncludes.new(local, value)
    end

    class HasLocalIncludes < Base
      def initialize(local, value)
        @local, @value = local, value
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        return false unless parameter.respond_to?(:keys) &&
                            parameter.respond_to?(:[])

        return false unless parameter.keys.include? :locals

        parameter = parameter[:locals]
        matching_keys = parameter.keys.select { |key| @local.to_matcher.matches?([key]) }
        matching_keys.any? do |key|
          array = parameter[key]
          array.include? @value
        end
      end

      def mocha_inspect
        "has_local_with_entry(#{@local.mocha_inspect} => {#{@key.mocha_inspect} => #{@value.mocha_inspect}})"
      end
    end

    def has_local_with_entry(local, *options)
      case options.length
      when 1
        key, value = options[0].first
      when 2
        key, value = options
      end

      HasLocalWithEntry.new(local, key, value)
    end

    class HasLocalWithEntry < Base
      def initialize(local, key, value)
        @local, @key, @value = local, key, value
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        return false unless parameter.respond_to?(:keys) &&
                            parameter.respond_to?(:[])

        return false unless parameter.keys.include? :locals

        parameter = parameter[:locals]
        matching_keys = parameter.keys.select { |key| @local.to_matcher.matches?([key]) }
        matching_keys.any? do |key|
          hash = parameter[key]
          subkeys = hash.keys.select { |key| @key.to_matcher.matches?([key]) }
          subkeys.any? { |key| @value.to_matcher.matches?([parameter[key]]) }
        end
      end

      def mocha_inspect
        "has_local_with_entry(#{@local.mocha_inspect} => {#{@key.mocha_inspect} => #{@value.mocha_inspect}})"
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
