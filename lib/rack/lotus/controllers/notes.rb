module Rack
  class Lotus
    # Retrieve a Lotus::Article
    get '/articles/:id' do
      article = Lotus::Article.find_by_id(params["id"])
      status 404 and return if article.nil?

      render :haml, :"activities/article", :locals => {:article => article}
    end
  end
end
