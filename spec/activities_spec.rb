require_relative 'helper'
require_controller 'activities'

describe Rack::Lotus do
  before do
    # Do not render
    Rack::Lotus.any_instance.stubs(:render).returns("html")
  end

  describe "Activities Controller" do
    describe "GET /activities/:id" do
      it "should return 404 if the activity is not found" do
        Lotus::Activity.stubs(:find_by_id).returns(nil)

        get '/activities/1234abcd'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        Lotus::Activity.stubs(:find_by_id).returns("something")

        get '/activities/1234abcd'
        last_response.status.must_equal 200
      end
    end

    describe "PUT /activities/:id" do
      it "should return 404 if the activity is not found" do
        Lotus::Activity.stubs(:find_by_id).returns(nil)

        put '/activities/1234abcd'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        Lotus::Activity.stubs(:find_by_id).returns("something")

        put '/activities/1234abcd'
        last_response.status.must_equal 200
      end
    end
  end
end
