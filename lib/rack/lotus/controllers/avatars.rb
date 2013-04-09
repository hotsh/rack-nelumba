module Rack
  class Lotus
    # Get the avatar
    get '/avatars/:id/:size' do
      avatar = Avatar.find_by_id(params[:id])
      status 404 and return unless avatar

      size = params["size"].split('x')

      content_type avatar.content_type
      avatar.read(size)
    end
  end
end
