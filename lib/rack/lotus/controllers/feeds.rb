module Rack
  class Lotus
    # Retrieve the public feed.
    get '/feeds/:id' do
      feed = Feed.find_by_id(params[:id])
      status 404 and return if feed.nil?
    end

    # Add an activity to the given feed if you own it.
    post '/feeds/:id' do
      feed = Feed.find_by_id(params[:id])
      status 404 and return if feed.nil?
    end
  end
end
