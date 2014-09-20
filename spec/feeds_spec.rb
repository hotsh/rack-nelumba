require_relative 'helper'
require_controller 'feeds'

class  Nelumba::Feed;  end
module Nelumba; end

describe Rack::Nelumba do
  before do
    # Do not render
    Rack::Nelumba.any_instance.stubs(:render).returns("html")
  end

  describe "Feeds Controller" do
    describe "GET /feeds/:id" do
      it "should return 404 if the feed doesn't exist" do
        Nelumba::Feed.stubs(:find_by_id).returns(nil)

        get '/feeds/bogus'
        last_response.status.must_equal 404
      end

      it "should render feeds/show" do
        feed = stub('Feed')
        feed.stubs(:entries).returns("entries")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"feeds/show",
                                                       anything)

        get '/feeds/valid'
      end

      it "should return 200 upon success" do
        feed = stub('Feed')
        feed.stubs(:entries).returns("entries")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        Rack::Nelumba.any_instance.stubs(:render).with(anything,
                                                     :"feeds/show",
                                                     anything)

        get '/feeds/valid'
        last_response.status.must_equal 200
      end

      it "should pass a feed variable to the view" do
        feed = stub('Feed')
        feed.stubs(:entries).returns("entries")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       anything,
                                                       has_local(:feed, feed))

        get '/feeds/valid'
      end

      it "should pass an activities variable to the view" do
        feed = stub('Feed')
        feed.stubs(:entries).returns("entries")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:activities, "entries")
        )

        get '/feeds/valid'
      end

      it "should render for html" do
        feed = stub('Feed')
        feed.stubs(:entries).returns("entries")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        Rack::Nelumba.any_instance.stubs(:render).returns("html")

        get '/feeds/valid'
        last_response.body.must_equal "html"
      end
    end
  end
end
