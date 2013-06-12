module Rack
  class Lotus
    require 'json'
    require 'date'
    require 'nokogiri'

    # Report a listing of all lotus routes.
    get '/api' do
      if request.preferred_type('application/json')
        content_type 'application/json'
        API.routes.to_json
      elsif request.preferred_type('application/jrd+json')
        content_type 'application/jrd+json'
        API.jrd.to_json
      elsif request.preferred_type('application/xrd+xml') ||
            request.preferred_type('application/xml')
        content_type 'application/xrd+xml'
        API.xrd
      else
        status 406
      end
    end

    # Report the host-meta for a particular person.
    get '/api/lrdd/:acct' do
      if request.preferred_type('application/xrd+xml') ||
         request.preferred_type('application/xml')
        "xrd"
        content_type 'application/xrd+xml'
        response = ::Lotus::Authorization.xrd params["acct"]
      elsif request.preferred_type('application/jrd+json') ||
            request.preferred_type('application/json')
        "jrd"
        content_type 'application/jrd+json'
        response = ::Lotus::Authorization.jrd params["acct"]
      else
        status 406 and return if ::Lotus::Authorization.xrd params["acct"]
        status 404 and return
      end

      status 404 and return if response.nil?

      response
    end

    # Handle host-meta.
    get '/.well-known/host-meta' do
      if request.preferred_type('application/xrd+xml') ||
         request.preferred_type('application/xml')
        content_type "application/xrd+xml"
        API.xrd
      elsif request.preferred_type('application/jrd+json') ||
            request.preferred_type('application/json')
        content_type "application/jrd+json"
        API.jrd.to_json
      else
        status 406
      end
    end
  end
end
