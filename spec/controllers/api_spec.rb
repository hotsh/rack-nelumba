require_relative 'helper'
require_controller 'api'

class  API; end
class  Authorization; end
module Lotus;  end

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

        API.stubs(:routes).returns(routes)

        get "/api"
        content_type.must_match "application/json"
      end

      it "should return JSON content when accept not specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        API.stubs(:routes).returns(routes)

        get "/api"
        last_response.body.must_equal "json"
      end

      it "should return JSON when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        API.stubs(:routes).returns(routes)

        accept "application/json"
        get "/api"

        content_type.must_match "application/json"
      end

      it "should return JSON content when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("json")

        API.stubs(:routes).returns(routes)

        accept "application/json"
        get "/api"

        last_response.body.must_equal "json"
      end

      it "should return JRD+JSON when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/api"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when specified" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/api"

        last_response.body.must_equal "jrd+json"
      end

      it "should return XRD+XML when specified" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when specified" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return XRD+XML when XML is specified" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when XML is specified" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return 406 if accept is unacceptable" do
        accept "application/bogus"
        get "/api"

        last_response.status.must_equal 406
      end
    end

    describe "GET /api/lrdd/:acct" do
      it "should return 406 if accept is unacceptable and account exists" do
        Authorization.stubs(:xrd).returns("something")

        accept "application/bogus"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.status.must_equal 406
      end

      it "should return XRD+XML when accept not specified" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept not specified" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies XML" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies XML" do
        Authorization.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return JRD+JSON when accept specifies JSON" do
        Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies JSON" do
        Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body.must_equal "jrd+json"
      end

      it "should return JRD+JSON when accept specifies" do
        Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/jrd+json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies" do
        Authorization.stubs(:jrd).returns("jrd+json")

        accept "application/jrd+json"
        get "/api/lrdd/acct:wilkie@rstat.us"

        last_response.body.must_equal "jrd+json"
      end

      it "should return 404 when account not found and accepting JSON" do
        Authorization.stubs(:jrd).returns(nil)

        accept "application/json"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting JRD+JSON" do
        Authorization.stubs(:jrd).returns(nil)

        accept "application/jrd+json"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting XML" do
        Authorization.stubs(:xrd).returns(nil)

        accept "application/xml"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accepting XRD+XML" do
        Authorization.stubs(:xrd).returns(nil)

        accept "application/xrd+xml"
        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and accept unspecified" do
        Authorization.stubs(:xrd).returns(nil)

        get "/api/lrdd/acct:bogus@rstat.us"

        last_response.status.must_equal 404
      end

      it "should return 404 when account not found and no good accept" do
        Authorization.stubs(:xrd).returns(nil)

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
        API.stubs(:xrd)

        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept not specified" do
        API.stubs(:xrd).returns("xrd+xml")

        get "/.well-known/host-meta"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies" do
        API.stubs(:xrd)

        accept "application/xrd+xml"
        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xrd+xml"
        get "/.well-known/host-meta"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return XRD+XML when accept specifies XML" do
        API.stubs(:xrd)

        accept "application/xml"
        get "/.well-known/host-meta"

        content_type.must_match "application/xrd+xml"
      end

      it "should return XRD+XML content when accept specifies XML" do
        API.stubs(:xrd).returns("xrd+xml")

        accept "application/xml"
        get "/.well-known/host-meta"

        last_response.body.must_equal "xrd+xml"
      end

      it "should return JRD+JSON when accept specifies JSON" do
        routes = stub('routes')
        routes.stubs(:to_json)

        API.stubs(:jrd).returns(routes)

        accept "application/json"
        get "/.well-known/host-meta"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies JSON" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        API.stubs(:jrd).returns(routes)

        accept "application/json"
        get "/.well-known/host-meta"

        last_response.body.must_equal "jrd+json"
      end

      it "should return JRD+JSON when accept specifies" do
        routes = stub('routes')
        routes.stubs(:to_json)

        API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/.well-known/host-meta"

        content_type.must_match "application/jrd+json"
      end

      it "should return JRD+JSON content when accept specifies" do
        routes = stub('routes')
        routes.stubs(:to_json).returns("jrd+json")

        API.stubs(:jrd).returns(routes)

        accept "application/jrd+json"
        get "/.well-known/host-meta"

        last_response.body.must_equal "jrd+json"
      end
    end
  end
end
