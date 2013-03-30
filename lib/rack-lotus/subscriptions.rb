module Rack
  # Contains the Rack application responsible for federation routing.
  class Lotus < Sinatra::Base
    require 'lotus/subscription'

    # PuSH subscription callback
    get '/subscriptions/:id' do
      # Only respond if there is a challenge
      if params["hub.challenge"]
        # Find the referenced feed
        feed = Feed.find_by_id(params[:id])

        # Don't continue if the feed doesn't exist
        if feed.nil?
          status 404
          return
        end

        # Build a new subscription manager
        sub = ::Lotus::Subscription.new(:callback_url => request.url,
                                        :topic_url    => feed.url,
                                        :token        => feed.verification_token)

        # Verify that the topic url is the feed url
        verified = params['hub.topic'] == feed.url

        # Also verify that the random token matches
        if verified && sub.verify_subscription(params['hub.verify_token'])
          response = sub.challenge_response(params['hub.challenge'])

          # Respond
          status response[:status]
          content_type "text"
          return response[:body]
        end
      end

      status 404
    end

    # Subscriber receives updates
    post '/subscriptions/:id.atom' do
      # Find the referenced feed
      feed = Feed.find_by_id(params[:id])

      # Don't continue if the feed doesn't exist
      if feed.nil?
        status 404
        return
      end

      incoming_feed = Lotus.feed_from_string(request.body)

      feed.merge!(incoming_feed)

      status 200
    end

    # Subscribe (internal action created by a logged in user)
    post '/subscriptions' do
      if session[:person_id].nil?
        status 401
        return
      end

      person = Person.find_by_id(session[:person_id])

      feed_url = params[:subscribe_to]
      feed = Feed.find_by_url(feed_url)

      if feed.nil?
        feed = Lotus.discover_feed(feed_url)
        Feed.create!(feed)
      end

      # Follow the feed
    end

    # Unsubscribe (internal action created by a logged in user)
    delete '/subscriptions/:id.atom' do
      # Find the referenced feed
      feed = Feed.find_by_id(params[:id])

      # Don't continue if the feed doesn't exist
      if feed.nil?
        status 404
        return
      end
    end
  end
end
