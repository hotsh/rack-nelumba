module Rack
  class Lotus
    # Retrieve a Lotus::Image
    get '/images/:id' do
      image = ::Lotus::Image.find_by_id(params["id"])
      status 404 and return if image.nil?

      # TODO: Allow for size retrieval

      if request.preferred_type('text/*')
        render :haml, :"activities/image", :locals => {:image => image}
      elsif request.preferred_type('image/*')
        content_type image.content_type
        image.full_image
      end
    end
  end
end
