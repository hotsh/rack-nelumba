module Rack
  class Lotus < Sinatra::Base
    require 'json'

    def self.routes
      {
        :subscription_url => "/subscriptions"
      }
    end

    # Report a JSON listing of all lotus routes.
    get '/api' do
      content_type 'application/json'
      Lotus.routes.to_json
    end
  end
end
