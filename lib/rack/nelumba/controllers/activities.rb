module Rack
  class Nelumba
    # Retrieve the public activity.
    get '/activities/:id' do
      activity = ::Nelumba::Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?

      format = request.preferred_type(['text/html', 'application/json', 'application/atom+xml', 'application/xml'])

      case format
      when 'application/json'
        content_type 'application/json'
        activity.to_json
      when 'application/atom+xml',
           'application/xml'
        content_type 'application/atom+xml'
        activity.to_atom
      when 'text/html'
        render :haml, :"activities/show", :locals => {
          :activity => activity
        }
      else
        status 406
      end
    end

    # Update the given activity if you own it.
    put '/activities/:id' do
      activity = ::Nelumba::Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?
    end
  end
end
