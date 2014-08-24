module Rack
  class Lotus
    # Retrieve a Lotus::Image
    get '/images/:id' do
      image = ::Lotus::Image.find_by_id(params["id"])
      status 404 and return if image.nil?

      format = request.preferred_type(['image/*', 'text/html'])

      case format
      when "image/*"
        content_type image.content_type

        if params["width"] && params["height"]
          size = [params["width"].to_i, params["height"].to_i]
          ret = image.image(size)
          if ret.nil?
            status 404
          end
          ret
        else
          image.full_image
        end
      when 'text/html'
        render :haml, :"activities/image", :locals => {:image => image}
      else
        status 406
      end
    end

    # Explicitly get the full size of the raw image
    get '/images/:id/full' do
      image = ::Lotus::Image.find_by_id(params["id"])
      status 404 and return if image.nil?

      content_type image.content_type
      image.full_image
    end
  end
end
