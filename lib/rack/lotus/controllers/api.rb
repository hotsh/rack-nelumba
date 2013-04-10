module Rack
  class Lotus
    require 'json'
    require 'date'
    require 'nokogiri'

    # Report a listing of all lotus routes.
    get '/api' do
      if request.accept?('application/json')
        content_type 'application/json'
        API.routes.to_json
      elsif request.accept?('application/jrd+json')
        content_type 'application/jrd+json'
        API.jrd.to_json
      elsif request.accept?('application/xrd+xml') ||
            request.accept?('application/xml')
        content_type 'application/xrd+xml'
        API.xrd
      else
        status 406
      end
    end

    # Report the host-meta for a particular person.
    get '/api/lrdd/:acct' do
      if request.accept?('application/xrd+xml') ||
         request.accept?('application/xml')
        content_type 'application/xrd+xml'
        response = Authorization.xrd params["acct"]
      elsif request.accept?('application/jrd+json') ||
            request.accept?('application/json')
        content_type 'application/jrd+json'
        response = Authorization.jrd params["acct"]
      else
        status 406 and return if Authorization.xrd params["acct"]
        status 404 and return
      end

      status 404 and return if response.nil?

      response
    end

    # Handle host-meta.
    get '/.well-known/host-meta' do
      if request.accept?('application/xrd+xml') ||
         request.accept?('application/xml')
        content_type "application/xrd+xml"
        API.xrd
      elsif request.accept?('application/jrd+json') ||
            request.accept?('application/json')
        content_type "application/jrd+json"
        API.jrd.to_json
      else
        status 406
      end
    end
  end
end
