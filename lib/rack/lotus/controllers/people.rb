module Rack
  class Lotus
    # Get a listing of the people on this server.
    get '/people' do
      @people = Person.all
      haml :"people/index"
    end

    # Get the public profile for this person.
    get '/people/:id' do
      @person = Person.find_by_id(params[:id])
      status 404 and return if @person.nil?

      @author = @person.author
      status 404 and return if @author.nil?

      haml :"people/show"
    end

    # Creates a new activity.
    post '/people/:id/outbox' do
      p = Person.find_by_id(session[:person_id])
      status 404 and return unless p

      p.post!(:type => params["type"],
              :verb => :post,
              :actor => p.author,
              :title => "New Post",
              :content => params["content"],
              :content_type => "text")
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
