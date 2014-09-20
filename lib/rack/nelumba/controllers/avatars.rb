module Rack
  class Nelumba
    # Get the avatar
    get '/avatars/:id/:size' do
      avatar = ::Nelumba::Avatar.find_by_id(params[:id])
      status 404 and return unless avatar

      size = params["size"].split('x').map(&:to_i)
      status 404 and return if size.length != 2

      content_type avatar.content_type
      ret = avatar.read(size)

      status 404 and return unless ret
      ret
    end
  end
end
