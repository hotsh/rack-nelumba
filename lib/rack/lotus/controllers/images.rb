module Rack
  class Lotus
    # Retrieve a Lotus::Image
    get '/images/:id' do
      image = ::Lotus::Image.find_by_id(params["id"])
      status 404 and return if image.nil?

      # TODO: Allow for image content types
      # TODO: Allow for size retrieval
      render :haml, :"activities/image", :locals => {:image => image}
    end
  end
end
