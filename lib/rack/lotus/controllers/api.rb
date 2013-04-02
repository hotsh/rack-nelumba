module Rack
  class Lotus
    require 'json'
    require 'date'
    require 'nokogiri'

    # Report a listing of all lotus routes.
    get '/api' do
      if request.accept?('application/json+jrd')
        content_type 'application/jrd+json'
        API.jrd.to_json
      elsif request.accept?('application/xrd+xml')||
            request.accept?('application/xml')
        content_type 'application/xrd+xml'
        API.xrd
      else
        API.routes.to_json
      end
    end

    # Report the host-meta for a particular person.
    get '/api/lrdd/:acct' do
      if request.accept?('application/json+jrd')
        content_type 'application/jrd+json'
        response = auth.jrd
      else
        content_type 'application/xrd+xml'
        response = auth.xrd
      end

      if response.nil?
        status 404
      else
        response
      end
    end

    # Handle host-meta.
    get '/.well-known/host-meta' do
      if request.accept?('application/json+jrd') ||
         request.accept?('application/json')
        API.jrd.to_json
      else
        API.xrd
      end
    end
  end
end
