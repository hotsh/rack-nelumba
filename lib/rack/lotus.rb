require 'sinatra'

module Rack
  # Contains the various routes used by the federation.
  class Lotus < Sinatra::Base
  end
end

require 'rack/lotus/subscriptions'
require 'rack/lotus/activities'
require 'rack/lotus/people'
require 'rack/lotus/feeds'
