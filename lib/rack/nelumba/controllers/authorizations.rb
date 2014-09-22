module Rack
  class Nelumba
    # Login form
    get '/login' do
      render :haml, :"authorizations/login"
    end

    # Authenticate
    post '/login' do
      authorization = ::Nelumba::Authorization.first(:username => /#{Regexp.escape(params["username"])}/i)
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

      if ::Nelumba::Authorization.find_by_username /^#{Regexp.escape(username)}$/i
        status 404
        return
      end

      # Create authorization
      params[:domain] = request.host
      params[:port]   = request.port == 80 ? nil : request.port
      params[:ssl]    = request.ssl?
      authorization = ::Nelumba::Authorization.create!(params)

      # Sign in
      session[:user_id]   = authorization.id
      session[:person_id] = authorization.person.id

      # Allow user to edit author
      redirect "/people/#{authorization.person.id}/edit"
    end
  end
end
