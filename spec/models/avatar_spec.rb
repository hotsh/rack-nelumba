require_relative 'helper'
require_model 'avatar'

module Net
  class HTTPSuccess; end

  class HTTPNotFound; def initialize; end; end
  class HTTPRedirection; def initialize; end; end
  class HTTPOK < HTTPSuccess; def initialize; end; end

  class HTTP
    class Get; end
    class Post; end
  end
end

module Base64; end

describe Avatar do
  before do
    Avatar.class_variable_set :@@grid, nil
  end

  describe "Schema" do
    it "should have an author_id" do
      Avatar.keys.keys.must_include "author_id"
    end

    it "should have a sizes array" do
      Avatar.keys.keys.must_include "sizes"
    end

    it "should has a default sizes array of []" do
      Avatar.new.sizes.must_equal []
    end

    it "should have a content_type" do
      Avatar.keys.keys.must_include "content_type"
    end

    it "should have a created_at" do
      Avatar.keys.keys.must_include "created_at"
    end

    it "should have a updated_at" do
      Avatar.keys.keys.must_include "updated_at"
    end
  end

  describe "from_url!" do
    it "should return nil if url is not found" do
      uri = stub('URI')
      uri.stubs(:request_uri)
      uri.stubs(:hostname)
      uri.stubs(:port)
      uri.stubs(:scheme)
      Avatar.stubs(:URI).returns(uri)

      request = stub('Net::HTTP::Request')
      Net::HTTP::Get.stubs(:new).returns(request)

      http = stub('Net::HTTP')
      http.stubs(:use_ssl=)
      http.stubs(:verify_mode=)
      Net::HTTP.stubs(:new).returns(http)

      response = stub('Net::HTTP::Response')
      response.stubs(:class).returns(Net::HTTPNotFound)
      response.stubs(:is_a?).returns false
      http.stubs(:request).returns(response)

      Magick::ImageList.stubs(:new)

      author = Author.create
      Avatar.from_url!(author, "bogus").must_equal nil
    end

    it "should use ssl and verify when given" do
      uri = stub('URI')
      uri.stubs(:request_uri)
      uri.stubs(:hostname)
      uri.stubs(:port)
      uri.stubs(:scheme).returns("https")
      Avatar.stubs(:URI).with("valid").returns(uri)

      request = stub('Net::HTTP::Request')
      Net::HTTP::Get.stubs(:new).returns(request)

      http = stub('Net::HTTP')
      Net::HTTP.stubs(:new).returns(http)

      response = stub('Net::HTTP::Response')
      response.stubs(:class).returns(Net::HTTPNotFound)
      http.stubs(:request).returns(response)

      Magick::ImageList.stubs(:new)

      author = Author.create

      http.expects(:use_ssl=).with(true)
      http.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
      Avatar.from_url!(author, "valid")
    end

    it "should query ImageMagick for the content type" do
      uri = stub('URI')
      uri.stubs(:request_uri)
      uri.stubs(:hostname)
      uri.stubs(:port)
      uri.stubs(:scheme).returns("https")
      Avatar.stubs(:URI).with("valid").returns(uri)

      request = stub('Net::HTTP::Request')
      Net::HTTP::Get.stubs(:new).returns(request)

      http = stub('Net::HTTP')
      http.stubs(:use_ssl=)
      http.stubs(:verify_mode=)
      Net::HTTP.stubs(:new).returns(http)

      response = Net::HTTPOK.new
      response.stubs(:body)
      http.stubs(:request).returns(response)

      image = stub('Magick::ImageList')
      image.stubs(:from_blob)
      image.stubs(:mime_type).returns("MIME")
      Magick::ImageList.stubs(:new).returns(image)

      author = Author.create

      Avatar.from_url!(author, "valid").content_type.must_equal "MIME"
    end

    it "should query ImageMagick to resize and fill to the given sizes" do
      uri = stub('URI')
      uri.stubs(:request_uri)
      uri.stubs(:hostname)
      uri.stubs(:port)
      uri.stubs(:scheme).returns("https")
      Avatar.stubs(:URI).with("valid").returns(uri)

      request = stub('Net::HTTP::Request')
      Net::HTTP::Get.stubs(:new).returns(request)

      http = stub('Net::HTTP')
      http.stubs(:use_ssl=)
      http.stubs(:verify_mode=)
      Net::HTTP.stubs(:new).returns(http)

      response = Net::HTTPOK.new
      response.stubs(:body)
      http.stubs(:request).returns(response)

      image = stub('Magick::ImageList')
      image.stubs(:from_blob)
      image.stubs(:mime_type).returns("MIME")
      Magick::ImageList.stubs(:new).returns(image)

      author = Author.create

      io = stub('IO')
      io.stubs(:put)

      gridfs = stub('Mongo::Grid')
      gridfs.stubs(:put)
      Mongo::Grid.stubs(:new).returns(gridfs)

      new_image = stub('Magick::ImageList')
      new_image.stubs(:to_blob).returns("NEW IMAGE")

      image.expects(:resize_to_fill).with(48, 48).returns(new_image)

      Avatar.from_url!(author, "valid", :sizes => [[48, 48]])
    end

    it "should store the resultant image to GridFS" do
      uri = stub('URI')
      uri.stubs(:request_uri)
      uri.stubs(:hostname)
      uri.stubs(:port)
      uri.stubs(:scheme).returns("https")
      Avatar.stubs(:URI).with("valid").returns(uri)

      request = stub('Net::HTTP::Request')
      Net::HTTP::Get.stubs(:new).returns(request)

      http = stub('Net::HTTP')
      http.stubs(:use_ssl=)
      http.stubs(:verify_mode=)
      Net::HTTP.stubs(:new).returns(http)

      response = Net::HTTPOK.new
      response.stubs(:body)
      http.stubs(:request).returns(response)

      new_image = stub('Magick::ImageList')
      new_image.stubs(:to_blob).returns("NEW IMAGE")

      image = stub('Magick::ImageList')
      image.stubs(:from_blob)
      image.stubs(:mime_type).returns("MIME")
      image.stubs(:resize_to_fill).with(48, 48).returns(new_image)
      Magick::ImageList.stubs(:new).returns(image)

      author = Author.create

      io = stub('IO')
      io.stubs(:put)

      gridfs = stub('Mongo::Grid')
      Mongo::Grid.stubs(:new).returns(gridfs)

      avatar = stub('Avatar')
      avatar.stubs(:id).returns("ID")
      avatar.stubs(:content_type=)
      avatar.stubs(:save)
      avatar.stubs(:_id).returns("ID")
      Avatar.stubs(:new).returns(avatar)

      gridfs.expects(:put).with("NEW IMAGE", :_id => "avatar_ID_48x48")
      Avatar.from_url!(author, "valid", :sizes => [[48, 48]])
    end
  end

  describe "#url" do
    it "should return a url crafted from the given size" do
      avatar = Avatar.create(:sizes => [[48, 48]])

      avatar.url([48, 48]).must_equal "/avatars/#{avatar.id}/48x48"
    end

    it "should return nil if the given size doesn't exist" do
      avatar = Avatar.create(:sizes => [[50, 50]])

      avatar.url([48, 48]).must_equal nil
    end

    it "should return nil when no sizes exist" do
      avatar = Avatar.create

      avatar.url([48, 48]).must_equal nil
    end

    it "should return nil when no sizes exist and none where given" do
      avatar = Avatar.create

      avatar.url.must_equal nil
    end

    it "should return first size given upon creation when none where given" do
      avatar = Avatar.create(:sizes => [[48, 48], [64, 64]])

      avatar.url([48, 48]).must_equal "/avatars/#{avatar.id}/48x48"
    end
  end

  describe "#read" do
    it "should call out to GridFS with the correct id" do
      avatar = Avatar.create(:sizes => [[48, 48]])

      io = stub('IO')
      io.stubs(:read).returns("bytes")

      gridfs = stub('Mongo::Grid')
      gridfs.expects(:get).with("avatar_#{avatar.id}_48x48").returns(io)

      Mongo::Grid.stubs(:new).returns(gridfs)

      avatar.read.must_equal "bytes"
    end

    it "should call out to GridFS with the correct id when size is given" do
      avatar = Avatar.create(:sizes => [[48, 48]])

      io = stub('IO')
      io.stubs(:read).returns("bytes")

      gridfs = stub('Mongo::Grid')
      gridfs.expects(:get).with("avatar_#{avatar.id}_48x48").returns(io)

      Mongo::Grid.stubs(:new).returns(gridfs)

      avatar.read([48, 48]).must_equal "bytes"
    end

    it "should return nil when no sizes exist and no size is given" do
      avatar = Avatar.create

      avatar.read([48, 48]).must_equal nil
    end

    it "should return nil when no sizes exist and size is given" do
      avatar = Avatar.create

      avatar.read([48, 48]).must_equal nil
    end

    it "should return nil when sizes exist but wrong size is given" do
      avatar = Avatar.create(:sizes => [[48, 48]])

      avatar.read([64, 64]).must_equal nil
    end
  end

  describe "#read_base64" do
    before do
      Base64.stubs(:encode64).returns("data_as_base64")
    end

    it "should call out to GridFS with the correct id" do
      avatar = Avatar.create(:sizes => [[48, 48]],
                             :content_type => "mime")

      io = stub('IO')
      io.stubs(:read).returns("bytes")

      gridfs = stub('Mongo::Grid')
      gridfs.expects(:get).with("avatar_#{avatar.id}_48x48").returns(io)

      Mongo::Grid.stubs(:new).returns(gridfs)

      avatar.read_base64([48, 48]).must_equal "data:mime;base64,data_as_base64"
    end

    it "should call out to GridFS with the correct id when size is given" do
      avatar = Avatar.create(:sizes => [[48, 48]],
                             :content_type => "mime")

      io = stub('IO')
      io.stubs(:read).returns("bytes")

      gridfs = stub('Mongo::Grid')
      gridfs.expects(:get).with("avatar_#{avatar.id}_48x48").returns(io)

      Mongo::Grid.stubs(:new).returns(gridfs)

      avatar.read_base64([48, 48]).must_equal "data:mime;base64,data_as_base64"
    end

    it "should return nil when no sizes exist and no size is given" do
      avatar = Avatar.create

      avatar.read_base64([48, 48]).must_equal nil
    end

    it "should return nil when no sizes exist and size is given" do
      avatar = Avatar.create(:content_type => "mime")

      avatar.read_base64([48, 48]).must_equal nil
    end

    it "should return nil when sizes exist but wrong size is given" do
      avatar = Avatar.create(:content_type => "mime")

      avatar.read_base64([64, 64]).must_equal nil
    end
  end
end
