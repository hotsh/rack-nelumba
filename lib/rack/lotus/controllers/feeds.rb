module Rack
  class Lotus
    # Retrieve the public feed.
    get '/feeds/:id' do
      feed = Feed.find_by_id(params[:id])
      status 404 and return if feed.nil?
    end

    # Add an activity to the given feed if you own it.
    post '/feeds/:id' do
      p = Person.find_by_id(session[:person_id])
      if p.nil? || p.activities.feed.id != params[:id]
        status 404
        return
      end

      puts "Place activity"
      puts params["content"]
    end
  end
end
