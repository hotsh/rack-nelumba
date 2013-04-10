module Rack
  class Lotus
    # Login form
    get '/login' do
      render :haml, :"authorizations/login"
    end

    # Authenticate
    post '/login' do
      authorization = Authorization.first(:username => /#{Regexp.escape(params["username"])}/i)
      if authorization && authorization.authenticated?(params["password"])
        session[:user_id]   = authorization.id
        session[:person_id] = authorization.person.id

        redirect '/'
      else
        status 404
      end
    end

    # Logout and reset session
    get '/logout' do
      session[:user_id]   = nil
      session[:person_id] = nil

      redirect '/'
    end

    # List a form for a new account
    get '/authorizations/new' do
      render :haml, :"authorizations/new"
    end

    # Create a new account
    post '/authorizations' do
      username = params["username"]
      password = params["password"]

      if Authorization.find_by_username /^#{Regexp.escape(username)}$/i
        status 404
        return
      end

      # Create authorization
      authorization = Authorization.create!(params)

      # Sign in
      session[:user_id]   = authorization.id
      session[:person_id] = authorization.person.id

      # Allow user to edit author
      redirect "/authors/#{authorization.person.author.id}/edit"
    end
  end
end
