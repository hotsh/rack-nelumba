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
end

# Default current_person to nil
module Rack
  class Lotus
    def current_person
      nil
    end
  end
end
