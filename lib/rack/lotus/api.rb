module Rack
  class Lotus
    require 'json'
    require 'date'
    require 'nokogiri'

    module API
      # Retrieves a Hash of all routes on the system as URI templates. Keys
      # indicate standard rels and values are URI templates.
      def self.routes
        {
          :lrdd             => "/api/lrdd/{uri}",
          :subscription_url => "/subscriptions"
        }
      end

      # Retrieve a hash representing the host JRD. Use to_json to yield a string.
      def self.jrd
        links = []

        routes = self.routes
        routes.keys.each do |k|
          links << {:rel => k, :template => routes[k]}
        end

        routes = {:links => links}

        # Get the domain from the first authorized account
        # It is a strange way to not have to provide the host name
        # I don't know how much I like it. :)
        identity = Authorization.first.identity

        routes[:subject] = "http#{identity.ssl ? "s" : ""}://#{identity.domain}"
        routes[:host]    = identity.domain
        routes[:expires] = "#{(Time.now.utc.to_date >> 1).xmlschema}Z"

        routes
      end

      # Retrieve a String containing XML conforming to the host-meta xrd
      # specification.
      def self.xrd
        routes = self.jrd

        # Build xml
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.XRD("xmlns"     => 'http://docs.oasis-open.org/ns/xri/xrd-1.0',
                  "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance',
                  "xmlns:hm"  => 'http://host-meta.net/ns/1.0') do
            xml.Subject routes[:subject]
            xml['hm'].Host routes[:host]
            xml.Expires routes[:expires]

            routes[:links].each do |link|
              xml.Link link
            end
          end
        end

        # Output
        builder.to_xml
      end
    end

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
        Lotus.routes.to_json
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
