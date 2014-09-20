require_relative 'helper'
require_controller 'subscriptions'

class  Subscription; end
module Nelumba;  end

describe Rack::Nelumba do
  before do
    # Do not render
    Rack::Nelumba.any_instance.stubs(:render).returns("html")
  end

  describe "Avatars Controller" do
    describe "GET /subscriptions/:id" do
      it "should return 404 if no hub.challenge is given" do
        get '/subscriptions/valid'
        last_response.status.must_equal 404
      end

      it "should return 404 if the feed does not exist" do
        Nelumba::Feed.stubs(:find_by_id).returns(nil)

        get '/subscriptions/valid', "hub.challenge" => "challenge"
        last_response.status.must_equal 404
      end

      it "should return 404 if the hub.topic doesn't match the feed.url" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        get '/subscriptions/valid', "hub.challenge" => "challenge",
                                    "hub.topic"     => "bogus_url"
        last_response.status.must_equal 404
      end

      it "should return 404 if the subscription does not verify" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_subscription).returns(false)
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "bogus_token"
        last_response.status.must_equal 404
      end

      it "should return status via Nelumba::Subscription if verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "challenge")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
        last_response.status.must_equal 123
      end

      it "should return body via Nelumba::Subscription if verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
        last_response.body.must_equal "response!"
      end

      it "should verify the subscription with Nelumba::Subscription" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.expects(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should pass the token to Nelumba::Subscription#verify_subscription" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.expects(:verify_subscription).with("verify_token").returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should pass the challenge to Nelumba::Subscription#challenge_response" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.expects(:challenge_response).with("challenge")
                                        .returns(:status => 123,
                                                 :body   => "response!")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should have the 'text/plain' content_type when successful" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).with("challenge")
                                      .returns(:status => 200,
                                               :body   => "response!")
        Nelumba::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"

        content_type.must_equal "text/plain"
      end
    end

    describe "POST /subscriptions/:id.atom" do
      it "should return 404 when the feed does not exist" do
        Nelumba::Feed.stubs(:find_by_id).returns(nil)

        post '/subscriptions/bogus.atom'
        last_response.status.must_equal 404
      end

      it "should return 404 if the signature does not exist" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_content).returns(false)
        Nelumba::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom'
        last_response.status.must_equal 404
      end

      it "should return 404 if the content cannot be verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_content).returns(false)
        Nelumba::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
        last_response.status.must_equal 404
      end

      it "should pass the body to Nelumba::Subscription#verify_content" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.expects(:verify_content).with("body", anything).returns(false)
        Nelumba::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
      end

      it "should pass the signature to Nelumba::Subscription#verify_content" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.expects(:verify_content).with(anything, "bogus").returns(false)
        Nelumba::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
      end

      it "should merge the feed stored in the body when verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_content).returns(true)
        Nelumba::Subscription.stubs(:new).returns(sub)

        Nelumba.stubs(:feed_from_string).returns("FEED")
        feed.expects(:merge!).with("FEED")

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "valid"
      end

      it "should return 200 when successful" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Nelumba::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Nelumba::Subscription')
        sub.stubs(:verify_content).returns(true)
        Nelumba::Subscription.stubs(:new).returns(sub)

        Nelumba.stubs(:feed_from_string).returns("FEED")
        feed.stubs(:merge!)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "valid"
        last_response.status.must_equal 200
      end
    end
  end
end
