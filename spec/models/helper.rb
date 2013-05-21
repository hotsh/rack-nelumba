require_relative '../helper'

# Convenience function to load the model source.
def require_model(name)
  require_relative "../../lib/rack/lotus/models/#{name}"
end

module Lotus
  class  Identity;     end
  class  Activity;     end
  class  Author;       end
  class  Feed;         end
  class  Subscription; end
  class  Notification; end
  module Crypto;       end
end

require 'mongo_mapper'

module ActiveSupport::Callbacks::ClassMethods
  def callbacks
    return @callbacks if @callbacks

    @callbacks ||= {}
    [:create, :save].each do |method|
      self.send(:"_#{method}_callbacks").each do |callback|
        @callbacks[:"#{callback.kind}_#{method}"] ||= []
        @callbacks[:"#{callback.kind}_#{method}"] << callback.raw_filter
      end
    end
    @callbacks
  end

  def before_create_callbacks
    callbacks[:before_create]
  end

  def after_create_callbacks
    callbacks[:after_create]
  end
end

module MongoMapper::Plugins::Associations::ClassMethods
  def has_one?(id)
    association = self.associations[id]
    return nil unless association

    association.is_a? MongoMapper::Plugins::Associations::OneAssociation
  end

  def belongs_to?(id)
    association = self.associations[id]
    return nil unless association

    association.is_a? MongoMapper::Plugins::Associations::BelongsToAssociation
  end

  def has_many?(id)
    association = self.associations[id]
    return nil unless association

    association.is_a? MongoMapper::Plugins::Associations::ManyAssociation
  end
end

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
