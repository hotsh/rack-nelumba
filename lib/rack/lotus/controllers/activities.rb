module Rack
  class Lotus
    # Retrieve the public activity.
    get '/activities/:id' do
      activity = ::Lotus::Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?

      if request.preferred_type('text/html')
        render :haml, :"activities/show", :locals => {
          :activity => activity
        }
      elsif request.preferred_type('application/json')
        content_type 'application/json'
        activity.to_json
      elsif request.preferred_type('application/atom+xml') ||
            request.preferred_type('application/xml')
        content_type 'application/atom+xml'
        activity.to_atom
      else
        status 406
      end
    end

    # Update the given activity if you own it.
    put '/activities/:id' do
      activity = ::Lotus::Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?
    end
  end
end
