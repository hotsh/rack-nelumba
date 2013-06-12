module Rack
  class Lotus
    # List all Lotus::Authors known on the system
    get '/authors' do
      @authors = ::Lotus::Author.all
      haml :"authors/index"
    end

    # Get a field to discover a new Lotus::Author.
    get '/authors/discover' do
      haml :"authors/discover"
    end

    # Discover a new Lotus::Author.
    post '/authors/discover' do
      author = nil
      if params["account"]
        author = ::Lotus::discover_author(params["account"])
      end

      if author
        existing_author = ::Lotus::Author.find(:uri => author.uri)
        if existing_author
          author = existing_author
        else
          author = ::Lotus::Author.create!(author)
        end
        redirect "/authors/#{author._id}"
      else
        status 404
      end
    end

    # List a known Lotus::Author
    get '/authors/:id' do
      @author = ::Lotus::Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/show"
      end
    end

    # Edit a known Lotus::Author
    get '/authors/:id/edit' do
      @author = ::Lotus::Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/edit"
      end
    end

    # Update a known Lotus::Author
    post '/authors/:id' do
      params = params() # Can't pass it unless it is a hash

      @author = ::Lotus::Author.find_by_id(params[:id])
      if @author.nil? || current_person.nil? || (@author.id != current_person.author.id)
        # Do not allow creation
        status 404
      else
        params = ::Lotus::Author.sanitize_params(params)
        @author.update_attributes!(params)

        redirect "/authors/#{@author.id}"
      end
    end

    # Edit the author avatar
    get '/authors/:id/avatar/edit' do
      @author = ::Lotus::Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/edit_avatar"
      end
    end

    # Update an avatar for a known Lotus::Author
    post '/authors/:id/avatar' do
      @author = ::Lotus::Author.find_by_id(params[:id])
      if @author.nil? || current_person.nil? || (@author.id != current_person.author.id)
        # Do not allow creation
        status 404
      else
        url = params["avatar_url"]
        @author.update_avatar!(url)

        redirect "/authors/#{params[:id]}"
      end
    end
  end
end
