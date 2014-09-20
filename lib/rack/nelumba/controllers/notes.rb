module Rack
  class Nelumba
    # Retrieve a form to create a new Nelumba::Note
    get '/notes/new' do
      # Must be logged in
      status 404 and return if !current_person

      render :haml, :"activities/notes/new"
    end

    # Retrieve a Nelumba::Note
    get '/notes/:id' do
      note = ::Nelumba::Note.find_by_id(params["id"])
      status 404 and return if note.nil?

      render :haml, :"activities/notes/show", :locals => {:note => note}
    end
  end
end
