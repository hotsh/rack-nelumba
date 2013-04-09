module Rack
  class Lotus
    # List all Authors known on the system
    get '/authors' do
      @authors = Author.all
      haml :"authors/index"
    end

    # Get a field to discover a new Author.
    get '/authors/discover' do
      haml :"authors/discover"
    end

    # Discover a new Author.
    post '/authors/discover' do
      author = nil
      if params["account"]
        author = Lotus::discover_author(params["account"])
      end

      if author
        existing_author = Author.find(:uri => author.uri)
        if existing_author
          author = existing_author
        else
          author = Author.create!(Author.sanitize_params(author.to_hash))
        end
        redirect "/authors/#{author._id}"
      else
        status 404
      end
    end

    # List a known Author
    get '/authors/:id' do
      @author = Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/show"
      end
    end

    # Edit a known Author
    get '/authors/:id/edit' do
      @author = Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/edit"
      end
    end

    # Update a known Author
    post '/authors/:id' do
      @author = Author.find_by_id(params[:id])
      if @author.nil? || current_person.nil? || (@author._id != current_person.author._id)
        # Do not allow creation
        status 404
      else
        Author.sanitize_params(params)
        @author.update_attributes!(params)

        redirect "/authors/#{params[:id]}"
      end
    end

    # Edit the author avatar
    get '/authors/:id/avatar/edit' do
      @author = Author.find_by_id(params[:id])
      if @author.nil?
        status 404
      else
        haml :"authors/edit_avatar"
      end
    end

    # Update an avatar for a known Author
    post '/authors/:id/avatar' do
      @author = Author.find_by_id(params[:id])
      if @author.nil? || current_person.nil? || (@author._id != current_person.author._id)
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
