module Rack
  class Lotus
    # Retrieve the public feed.
    get '/feeds/:id' do
      @feed = Feed.find_by_id(params[:id])
      @activities = @feed.entries
      status 404 and return if @feed.nil?

      haml :"feeds/show"
    end

    # Add an activity to the given feed if you own it.
    post '/feeds/:id' do
      feed = Feed.first_by_id(params["id"])
      status 404 and return unless feed

      status 404 and return unless feed.aggregate && feed.aggregate.person.id.to_s == session[:person_id]

      feed.create_activity!(:type => params["type"],
                            :verb => :post,
                            :actor => p.author,
                            :title => "New Post",
                            :content => params["content"],
                            :content_type => "text")
    end
  end
end
