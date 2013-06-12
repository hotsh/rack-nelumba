module Rack
  class Lotus
    # Retrieve the public feed.
    get '/feeds/:id' do
      feed = ::Lotus::Feed.find_by_id(params[:id])
      status 404 and return unless feed

      render :haml, :"feeds/show", :locals => {:feed => feed,
                                               :activities => feed.entries}
    end
  end
end
