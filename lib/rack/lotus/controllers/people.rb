module Rack
  class Lotus
    # Get a listing of the people on this server.
    get '/people' do
      @people = Person.all
      haml :"people/index"
    end

    # Get the public profile for this person.
    get '/people/:id' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      @timeline = @person.activities.feed.ordered
      haml :"people/show"
    end

    # Get the public feed for somebody's favorites.
    get '/people/:id/favorites' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      @favorites = @person.favorites.feed.ordered
      haml :"people/show_favorites"
    end

    # Get the public feed for somebody's feed of shared posts.
    get '/people/:id/shared' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      @shared = @person.shared.feed.ordered
      haml :"people/show_shared"
    end

    # Creates a new activity.
    post '/people/:id/outbox' do
      status 404 and return unless current_person.id.to_s == params["id"]

      if params["activity_id"]
        # Repost
        activity = Activity.find_by_id(params["activity_id"])
        status 404 and return unless activity
        current_person.repost! activity
      else
        # New
        current_person.post!(:type => params["type"],
                             :verb => :post,
                             :actor => current_person.author,
                             :title => "New Post",
                             :content => params["content"],
                             :content_type => "text")
      end

      redirect '/'
    end

    # Retrieve list of people we follow
    get '/people/:id/following' do
      person = Person.find_by_id(params["id"])
      status 404 and return unless person

      @following = person.following

      haml :"people/following"
    end

    # Retrieve a list of people who are following us.
    get '/people/:id/followers' do
      person = Person.find_by_id(params["id"])
      status 404 and return unless person

      @followers = person.followers

      haml :"people/followers"
    end

    # Follow a person
    post '/people/:id/following' do
      status 404 and return unless current_person
      status 404 and return unless current_person.id.to_s == params["id"]

      if params["author_id"]
        author = Author.find_by_id(params["author_id"])
      elsif params["discover"]
        author = Author.discover!(params["discover"])
      end

      status 404 and return unless author

      current_person.follow! author
    end

    # Unfollow a person
    delete '/people/:id/following/:followed_id' do
      status 404 and return unless current_person
      status 404 and return unless current_person.id.to_s == params["id"]

      current_person.unfollow! params["followed_id"]
    end

    # Favorite an activity
    post '/people/:id/favorites' do
      status 404 and return unless current_person.id.to_s == params["id"]

      activity = Activity.find_by_id(params["activity_id"])

      status 404 and return unless activity

      current_person.favorite! activity
    end

    # Share an activity
    post '/people/:id/shared' do
      status 404 and return unless current_person.id.to_s == params["id"]

      activity = Activity.find_by_id(params["activity_id"])

      status 404 and return unless activity

      current_person.share! activity
    end

    # External delivery to our own stream.
    post '/people/:id/timeline' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of followed activity streams.
    post '/people/:id/inbox' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of direct messages.
    post '/people/:id/direct' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end
  end
end
