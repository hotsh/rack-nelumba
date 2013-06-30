module Rack
  class Lotus
    # Retrieve a Lotus::Note
    get '/notes/:id' do
      note = ::Lotus::Note.find_by_id(params["id"])
      status 404 and return if note.nil?

      render :haml, :"activities/note", :locals => {:note => note}
    end
  end
end
