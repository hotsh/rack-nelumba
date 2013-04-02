require 'sinatra'

module Rack
  # Contains the various routes used by the federation.
  class Lotus < Sinatra::Base
    require 'lotus'
    require 'mongo_mapper'

    # Use the application directory as root
    set :app_file => '.'

    # Use HTML5
    set :haml, :format => :html5
  end
end

Dir[File.join(File.dirname(__FILE__), "lotus", "*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "lotus", "controllers", "*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "lotus", "helpers", "*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "lotus", "models", "*.rb")].each {|file| require file }
