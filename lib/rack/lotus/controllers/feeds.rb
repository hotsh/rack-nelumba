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
      p = Person.find_by_id(session[:person_id])
      if p.nil? || p.activities.feed.id.to_s != params[:id]
        status 404
        return
      end

      p.activities.feed.create_activity!(:type => params["type"],
                                         :verb => :post,
                                         :actor => p.author,
                                         :title => "New Post",
                                         :content => params["content"],
                                         :content_type => "text")
    end
  end
end
