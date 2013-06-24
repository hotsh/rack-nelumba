require_relative 'helper'
require_controller 'subscriptions'

class  Subscription; end
module Lotus;  end

describe Rack::Lotus do
  before do
    # Do not render
    Rack::Lotus.any_instance.stubs(:render).returns("html")
  end

  describe "Avatars Controller" do
    describe "GET /subscriptions/:id" do
      it "should return 404 if no hub.challenge is given" do
        get '/subscriptions/valid'
        last_response.status.must_equal 404
      end

      it "should return 404 if the feed does not exist" do
        Lotus::Feed.stubs(:find_by_id).returns(nil)

        get '/subscriptions/valid', "hub.challenge" => "challenge"
        last_response.status.must_equal 404
      end

      it "should return 404 if the hub.topic doesn't match the feed.url" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        get '/subscriptions/valid', "hub.challenge" => "challenge",
                                    "hub.topic"     => "bogus_url"
        last_response.status.must_equal 404
      end

      it "should return 404 if the subscription does not verify" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_subscription).returns(false)
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "bogus_token"
        last_response.status.must_equal 404
      end

      it "should return status via Lotus::Subscription if verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "challenge")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
        last_response.status.must_equal 123
      end

      it "should return body via Lotus::Subscription if verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
        last_response.body.must_equal "response!"
      end

      it "should verify the subscription with Lotus::Subscription" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.expects(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should pass the token to Lotus::Subscription#verify_subscription" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.expects(:verify_subscription).with("verify_token").returns(true)
        sub.stubs(:challenge_response).returns(:status => 123,
                                               :body => "response!")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should pass the challenge to Lotus::Subscription#challenge_response" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.expects(:challenge_response).with("challenge")
                                        .returns(:status => 123,
                                                 :body   => "response!")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"
      end

      it "should have the 'text/plain' content_type when successful" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:verification_token).returns("valid_token")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_subscription).returns(true)
        sub.stubs(:challenge_response).with("challenge")
                                      .returns(:status => 200,
                                               :body   => "response!")
        Lotus::Subscription.stubs(:new).returns(sub)

        get '/subscriptions/valid', "hub.challenge"    => "challenge",
                                    "hub.topic"        => "valid_url",
                                    "hub.verify_token" => "verify_token"

        content_type.must_equal "text/plain"
      end
    end

    describe "POST /subscriptions/:id.atom" do
      it "should return 404 when the feed does not exist" do
        Lotus::Feed.stubs(:find_by_id).returns(nil)

        post '/subscriptions/bogus.atom'
        last_response.status.must_equal 404
      end

      it "should return 404 if the signature does not exist" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_content).returns(false)
        Lotus::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom'
        last_response.status.must_equal 404
      end

      it "should return 404 if the content cannot be verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_content).returns(false)
        Lotus::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
        last_response.status.must_equal 404
      end

      it "should pass the body to Lotus::Subscription#verify_content" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.expects(:verify_content).with("body", anything).returns(false)
        Lotus::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
      end

      it "should pass the signature to Lotus::Subscription#verify_content" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.expects(:verify_content).with(anything, "bogus").returns(false)
        Lotus::Subscription.stubs(:new).returns(sub)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "bogus"
      end

      it "should merge the feed stored in the body when verified" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_content).returns(true)
        Lotus::Subscription.stubs(:new).returns(sub)

        Lotus.stubs(:feed_from_string).returns("FEED")
        feed.expects(:merge!).with("FEED")

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "valid"
      end

      it "should return 200 when successful" do
        feed = stub('Feed')
        feed.stubs(:url).returns("valid_url")
        feed.stubs(:secret).returns("secret")
        Lotus::Feed.stubs(:find_by_id).returns(feed)

        sub = stub('Lotus::Subscription')
        sub.stubs(:verify_content).returns(true)
        Lotus::Subscription.stubs(:new).returns(sub)

        Lotus.stubs(:feed_from_string).returns("FEED")
        feed.stubs(:merge!)

        post '/subscriptions/valid.atom', "body",
                                          "HTTP_X_HUB_SIGNATURE" => "valid"
        last_response.status.must_equal 200
      end
    end
  end
end
