module Rack
  class Lotus < Sinatra::Base
    # Login form
    get '/login' do
      haml :"authorizations/login"
    end

    # Authenticate
    post '/login' do
      authorization = Authorization.first(:username => params["username"])
      if authorization && authorization.authenticated?(params["password"])
        session[:user_id] = authorization._id

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
      haml :"authorizations/new"
    end

    # Create a new account
    post '/authorizations' do
      Authorization.sanitize_params(params)

      if Authorization.find_by_username(params[:username])
        puts "#{params[:username]} already taken."
        status 404
        return
      end

      # Create authorization
      authorization = Authorization.create!(params)

      # Sign in
      session[:user_id]   = authorization._id
      session[:person_id] = authorization.person._id

      # Allow user to edit author
      @author = authorization.author
      haml :"authors/edit"
    end
  end
end
