require 'minitest/spec'
require 'turn/autorun'

Turn.config do |c|
  c.natural = true
end

require "mocha/setup"
require "debugger"

require 'lotus'
require 'lotus-mongodb'
require './lib/rack/lotus'
