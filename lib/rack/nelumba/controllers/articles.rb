module Rack
  class Nelumba
    # Retrieve a Nelumba::Article
    get '/articles/:id' do
      article = ::Nelumba::Article.find_by_id(params["id"])
      status 404 and return if article.nil?

      render :haml, :"activities/article", :locals => {:article => article}
    end
  end
end
