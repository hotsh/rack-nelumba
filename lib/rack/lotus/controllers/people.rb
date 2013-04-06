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

    # Get the public feed for somebody's timeline.
    get '/people/:id/favorites' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      @favorites = @person.favorites.feed.ordered
      haml :"people/show_favorites"
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

    # Favorite an activity
    post '/people/:id/favorites' do
      status 404 and return unless current_person.id.to_s == params["id"]

      activity = Activity.find_by_id(params["activity_id"])

      status 404 and return unless activity

      current_person.favorite! activity
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
