require_relative 'helper'
require_controller 'avatars'

class  Lotus::Avatar; end
module Lotus;  end

describe Rack::Lotus do
  before do
    # Do not render
    Rack::Lotus.any_instance.stubs(:render).returns("html")
  end

  describe "Avatars Controller" do
    describe "GET /avatars/:id/:size" do
      it "should return 404 if the avatar does not exist" do
        Lotus::Avatar.stubs(:find_by_id).returns(nil)

        get '/avatars/bogus_id/48x48'
        last_response.status.must_equal 404
      end

      it "should return the content type stored with the avatar" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.stubs(:read)
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/48x48'
        content_type.must_equal("image/some_image_type")
      end

      it "should query the avatar for the given size" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.expects(:read).with([48, 48])
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/48x48'
      end

      it "should read the avatar data" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.stubs(:read).returns("DATA")
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/48x48'
        last_response.body.must_equal "DATA"
      end

      it "should return 404 if avatar size not available" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.stubs(:read).returns(nil)
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/1x4800'
        last_response.status.must_equal 404
      end

      it "should return 200 when successful" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.stubs(:read).returns("DATA")
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/48x48'
        last_response.status.must_equal 200
      end

      it "should return 404 when avatar size doesn't make sense" do
        avatar = stub('Avatar')
        avatar.stubs(:content_type).returns("image/some_image_type")
        avatar.stubs(:read).returns("DATA")
        Lotus::Avatar.stubs(:find_by_id).returns(avatar)

        get '/avatars/valid_id/bogus'
        last_response.status.must_equal 404
      end
    end
  end
end
