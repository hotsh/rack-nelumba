require_relative '../helper'

# Convenience function to load the model source.
def require_model(name)
  require_relative "../../lib/rack/lotus/models/#{name}"
end

module Lotus
  class Identity;     end
  class Activity;     end
  class Author;       end
  class Feed;         end
  class Subscription; end
end

require 'mongo_mapper'

require_model 'person'
require_model 'identity'
require_model 'author'
require_model 'feed'
require_model 'aggregate'
require_model 'avatar'
require_model 'activity'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = "rack-lotus-test"

class MiniTest::Unit::TestCase
  def teardown
    MongoMapper.database.collections.each do |collection|
      collection.remove unless collection.name.match /^system\./
    end
  end
end
