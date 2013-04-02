module Rack
  class Lotus
    # Get the public profile for this person.
    get '/people/:id' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      haml :"people/show"
    end

    # External delivery of our own stream.
    post '/people/:id/feed' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of followed activity streams.
    post '/people/:id/inbox' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end

    # External delivery of direct messages.
    post '/people/:id/delivery' do
      person = Person.find_by_id(params[:id])
      status 404 and return if person.nil?
    end
  end
end
