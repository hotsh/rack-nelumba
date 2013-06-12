module Rack
  # Contains the Rack application responsible for federation routing.
  class Lotus
    require 'lotus/subscription'

    # PuSH subscription callback
    get '/subscriptions/:id' do
      # Only respond if there is a challenge
      if params["hub.challenge"]
        # Find the referenced feed
        feed = ::Lotus::Feed.find_by_id(params[:id])

        # Don't continue if the feed doesn't exist
        status 404 and return unless feed

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
          content_type "text/plain"
          return response[:body]
        end
      end

      status 404
    end

    # Subscriber receives updates
    post '/subscriptions/:id.atom' do
      # Find the referenced feed
      feed = ::Lotus::Feed.find_by_id(params[:id])
      status 404 and return unless feed

      signature = request.env['HTTP_X_HUB_SIGNATURE']
      sub = ::Lotus::Subscription.new(:callback_url => request.url,
                                      :feed_url     => feed.url,
                                      :secret       => feed.secret)

      if sub.verify_content(request.body.read, signature)
        incoming_feed = ::Lotus.feed_from_string(request.body,
                                                 "application/atom+xml")

        feed.merge!(incoming_feed)

        status 200
      else
        status 404
      end
    end
  end
end
