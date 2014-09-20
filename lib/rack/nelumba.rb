require 'sinatra'

module Rack
  # Contains the various routes used by the federation.
  class Nelumba < Sinatra::Base
    require 'nelumba'
    require 'nelumba-mongodb'

    use Rack::Session::Cookie, :key    => 'rack.session',
                               :path   => '/',
                               :secret => 'foobar'

    # Use the application directory as root
    set :app_file => '.'

    # Use HTML5
    set :haml, :format => :html5
  end
end

Dir[File.join(File.dirname(__FILE__), "nelumba", "*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "nelumba", "controllers", "*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "nelumba", "helpers", "*.rb")].each {|file| require file }
