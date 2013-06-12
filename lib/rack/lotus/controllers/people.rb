module Rack
  class Lotus
    # Get a listing of the people on this server.
    get '/people' do
      people = ::Lotus::Person.all
      render :haml, :"people/index", :locals => {:people => people}
    end

    # Get the public profile for this person.
    get '/people/:id' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?

      timeline = person.activities.feed.ordered
      render :haml, :"people/show", :locals => {:person => person,
                                                :timeline => timeline}
    end

    # Get the public feed for somebody's favorites.
    get '/people/:id/favorites' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?

      favorites = person.favorites.feed.ordered
      render :haml, :"people/favorites", :locals => {:person => person,
                                                     :favorites => favorites}
    end

    # Get the public feed for somebody's feed of shared posts.
    get '/people/:id/shared' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?

      shared = person.shared.feed.ordered
      render :haml, :"people/shared", :locals => {:person => person,
                                                  :shared => shared}
    end

    # Retrieve list of people we follow
    get '/people/:id/following' do
      person = ::Lotus::Person.find_by_id(params["id"])
      status 404 and return unless person

      following = person.following

      render :haml, :"people/following", :locals => {:person => person,
                                                     :following => following}
    end

    # Retrieve a list of people who are following us.
    get '/people/:id/followers' do
      person = ::Lotus::Person.find_by_id(params["id"])
      status 404 and return unless person

      followers = person.followers

      render :haml, :"people/followers", :locals => {:person => person,
                                                     :followers => followers}
    end

    # Follow a person
    post '/people/:id/following' do
      status 404 and return unless current_person &&
                                   current_person.id.to_s == params["id"]

      if params["author_id"]
        author = Author.find_by_id(params["author_id"])
      elsif params["discover"]
        author = Author.discover!(params["discover"])
      end

      status 404 and return unless author

      current_person.follow! author
      redirect '/'
    end

    # Unfollow a person
    delete '/people/:id/following/:followed_id' do
      status 404 and return unless current_person &&
                                   current_person.id.to_s == params["id"]

      current_person.unfollow! params["followed_id"]
      redirect '/'
    end

    # Favorite an activity
    post '/people/:id/favorites' do
      status 404 and return unless current_person &&
                                   current_person.id.to_s == params["id"]

      activity = ::Lotus::Activity.find_by_id(params["activity_id"])

      status 404 and return unless activity

      current_person.favorite! activity
      redirect '/'
    end

    # Share an activity
    post '/people/:id/shared' do
      status 404 and return unless current_person &&
                                   current_person.id.to_s == params["id"]

      activity = ::Lotus::Activity.find_by_id(params["activity_id"])

      status 404 and return unless activity

      current_person.share! activity
      redirect '/'
    end

    # External delivery to our own stream.
    post '/people/:id/timeline' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of followed activity streams.
    post '/people/:id/inbox' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of direct messages.
    post '/people/:id/direct' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # Creates a new activity.
    post '/people/:id/activities' do
      status 404 and return unless current_person &&
                                   current_person.id.to_s == params["id"]

      current_person.post!(:type => params["type"],
                           :verb => :post,
                           :actor => current_person.author,
                           :title => "New Post",
                           :content => params["content"],
                           :content_type => "text")

      redirect '/'
    end

    # Handle a salmon payload
    post '/people/:id/salmon' do
      person = ::Lotus::Person.find_by_id(params[:id])
      status 404 and return if person.nil?

      # Form the notification
      notification = ::Lotus::Notification.from_xml(request.body.read)

      # If it already exists, this will update
      activity = ::Lotus::Activity.find_from_notification(notification)

      if activity
        activity = activity.update_from_notification!(notification)

        # Failure to verify (Forbidden)
        status 403 and return if activity.nil?
        success = 200
      else
        activity = ::Lotus::Activity.create_from_notification!(notification)

        # Failure to verify (Bad Request)
        status 400 and return if activity.nil?
        success = 202
      end

      case activity.verb
      when :follow
        person.followed_by! nil
      when :unfollow
        person.unfollowed_by! identity.author
      when :post
        # TODO: determine who is mentioned, replied and deliver if this is
        #       "person"
      end

      headers["Location"] = activity.url
      status success
    end
  end
end
