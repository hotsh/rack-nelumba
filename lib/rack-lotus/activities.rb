module Rack
  require 'sinatra'

  class Lotus < Sinatra::Base
    # Retrieve the public activity.
    get '/activities/:id' do
      activity = Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?
    end

    # Update the given activity if you own it.
    put '/activities/:id' do
      activity = Activity.find_by_id(params[:id])
      status 404 and return if activity.nil?
    end
  end
end
