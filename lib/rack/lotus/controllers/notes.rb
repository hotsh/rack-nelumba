module Rack
  class Lotus
    # Retrieve a Lotus::Note
    get '/notes/:id' do
      note = ::Lotus::Note.find_by_id(params["id"])
      status 404 and return if note.nil?

      render :haml, :"activities/notes/show", :locals => {:note => note}
    end

    get '/notes/new' do
      # Must be logged in
      status 404 and return if !current_person

      render :haml, :"activities/notes/new", :locals => {:note => note}
    end
  end
end
