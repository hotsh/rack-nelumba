require_relative 'helper'

describe Rack::Lotus do
  before do
    # Do not render
    Rack::Lotus.any_instance.stubs(:render).returns("html")
  end

  describe "API Controller" do
    describe "GET /api" do
      it "should return JSON when accept not specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        Rack::Lotus::API.stubs(:routes).returns(routes)

        get "/api"
        content_type.must_match "application/json"
      end

      it "should return JSON content when accept not specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        Rack::Lotus::API.stubs(:routes).returns(routes)

        get "/api"
        last_response.body[0..4].must_equal "json"
      end

      it "should return JSON when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        Rack::Lotus::API.stubs(:routes).returns(routes)

        accept "application/json"
        get "/api"

        content_type.must_match "application/json"
      end

      it "should return JSON content when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        Rack::Lotus::API.stubs(:routes).returns(routes)

        accept "application/json"
        get "/api"

        last_response.body[0..4].must_equal "json"
      end

      it "should return JRD+JSON when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/api"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/api"

        last_response.body[0..8].must_equal "jrd+json"
      end

      it "should return XRD+XML when specified" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when specified" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return XRD+XML when XML is specified" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when XML is specified" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return 406 if accept is unacceptable" do
        accept "application/bogus"
        get "/api"

        last_response.status.must_equal 406
      end
    end

    describe "GET /api/lrdd/:acct" do
      it "should return 406 if accept is unacceptable and account exists" do
        Lotus::Authorization.stubs(:xrd).returns("something")

        accept "application/bogus"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.status.must_equal 406
      end

      it "should return XRD+XML when accept not specified" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        accept "*/*"
        get "/api/lrdd/acct:wilkie@rstat.usd"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept not specified" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies XML" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies XML" do
        Lotus::Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return JRD+JSON when accept specifies JSON" do
        Lotus::Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies JSON" do
        Lotus::Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body[0..8].must_equal "jrd+json"
      end

      it "should return JRD+JSON when accept specifies" do
        Lotus::Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/jrd+json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies" do
        Lotus::Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/jrd+json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body[0..7].must_equal "jrd+json"
      end

      it "should return 404 when account not found and accepting JSON" do
        Lotus::Authorization.stubs(:jrd).returns(nil)

        accept "application/json"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting JRD+JSON" do
        Lotus::Authorization.stubs(:jrd).returns(nil)

        accept "application/jrd+json"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting XML" do
        Lotus::Authorization.stubs(:xrd).returns(nil)

        accept "application/xml"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting XRD+XML" do
        Lotus::Authorization.stubs(:xrd).returns(nil)

        accept "application/xrd+xml"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accept unspecified" do
        Lotus::Authorization.stubs(:xrd).returns(nil)

        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and no good accept" do
        Lotus::Authorization.stubs(:xrd).returns(nil)

        accept "application/bogus"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end
    end

    describe "GET /.well-known/host-meta" do
      it "should return 406 if accept is unacceptable" do
        accept "application/bogus"
        get "/.well-known/host-meta"

        last_response.status.must_equal 406
      end

      it "should return XRD+XML when accept not specified" do
        Rack::Lotus::API.stubs(:xrd)

        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept not specified" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        get "/.well-known/host-meta"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies" do
        Rack::Lotus::API.stubs(:xrd)

        accept "application/xrd+xml"
        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/.well-known/host-meta"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies XML" do
        Rack::Lotus::API.stubs(:xrd)

        accept "application/xml"
        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies XML" do
        Rack::Lotus::API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/.well-known/host-meta"

        last_response.body[0..7].must_equal "xrd+xml"
      end

      it "should return JRD+JSON when accept specifies JSON" do
        routes = stub('routes')
        routes.stubs(:to_json)

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/json"
        get "/.well-known/host-meta"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies JSON" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/json"
        get "/.well-known/host-meta"

        last_response.body[0..8].must_equal "jrd+json"
      end

      it "should return JRD+JSON when accept specifies" do
        routes = stub('routes')
        routes.stubs(:to_json)

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/.well-known/host-meta"

        content_type.must_equal "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        Rack::Lotus::API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/.well-known/host-meta"

        last_response.body.must_equal "jrd+json"
      end

      it "should return a lrdd route with a correct domain for json" do
        identity = stub('Lotus::Identity')
        identity.stubs(:ssl).returns(true)
        identity.stubs(:domain).returns("www.example.com")

        auth = stub('Lotus::Authorization')
        auth.stubs(:identity).returns(identity)

        ::Lotus::Authorization.stubs(:first).returns(auth)
        accept "application/jrd+json"
        get "/.well-known/host-meta"

        lrdd = JSON::parse(last_response.body)["links"].select do |l|
          l["rel"] == "lrdd"
        end.first

        lrdd["template"].start_with?("https://www.example.com/").must_equal true
      end

      it "should return a lrdd route with a correct domain for xml" do
        identity = stub('Lotus::Identity')
        identity.stubs(:ssl).returns(true)
        identity.stubs(:domain).returns("www.example.com")

        auth = stub('Lotus::Authorization')
        auth.stubs(:identity).returns(identity)

        ::Lotus::Authorization.stubs(:first).returns(auth)
        accept "application/xrd+xml"
        get "/.well-known/host-meta"

        last_response.body.must_match /\<Link.+rel\s*=\s*"lrdd"\s+template\s*=\s*"https:\/\/www\.example\.com\//
      end
    end
  end
end
