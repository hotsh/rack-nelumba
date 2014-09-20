module Rack
  class Nelumba
    # Contains methods to coordinate API routes and host-meta.
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

        # Get the domain from the first authorized account
        # It is a strange way to not have to provide the host name
        # I don't know how much I like it. :)
        identity = ::Nelumba::Authorization.first.identity

        url = "http#{identity.ssl ? "s" : ""}://#{identity.domain}"

        routes = self.routes
        routes.keys.each do |k|
          links << {:rel => k, :template => "#{url}#{routes[k]}"}
        end

        routes = {:links => links}

        routes[:subject] = url
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
  end
end
