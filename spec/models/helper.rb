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

TEST_TYPE = :dsl

if TEST_TYPE == :vanilla
  require 'mongo_mapper'

  require_model 'person'
  require_model 'identity'
  require_model 'author'
  require_model 'feed'
  require_model 'aggregate'
  require_model 'avatar'
  require_model 'activity'

  # A "normal" Mongo execution
  MongoMapper.connection = Mongo::Connection.new('localhost')
  MongoMapper.database = "rack-lotus-test"

  class MiniTest::Unit::TestCase
    def teardown
      MongoMapper.database.collections.each do |collection|
        collection.remove unless collection.name.match /^system\./
      end
    end
  end
elsif TEST_TYPE == :dsl
  # Simply executes the MongoMapper DSL
  class MiniTest::Unit::TestCase
    def teardown
      MongoMapper.destroy_all
    end
  end

  class ObjectId; end

  class Collection
    def initialize(klass, instance, in_key, ids)
      @klass = klass
      @in_key = in_key
      @instance = instance
      @ids = ids
    end

    def each(&blk)
      @ids.map{|id| @klass.find_by_id(id)}.each(&blk)
    end

    def <<(value)
      if value.is_a? Hash
        value = @klass.create(value)
      end

      @ids << value.id
      @instance.send(:"#{@in_key}=", @ids)
    end
  end

  module Mongo
    class Grid
      def clear
        @@id = 0
        @@storage = {}
      end

      def get(id)
        @@storage ||= {}
        @@storage[id]
      end

      def put(data, options)
        @@id ||= 0
        id = options[:_id] || "__#{@@id}"
        @@id += 1
        @@storage ||= {}
        @@storage[id] = data
      end
    end
  end

  # null MongoMapper DB driver
  # Just define DSL I use... nothing else... drastically speeds up tests
  module MongoMapper
    def self.add_model(model); @@models ||= []; @@models << model; end
    def self.destroy_all; (@@models || []).each{|m|m.destroy_all}; end

    def self.database; "test-database"; end

    module Document
      module Includes
        def _next_id; @id ||= 0; @id += 1; end
        def _entries; @entries ||= {}; end
        def all; @entries.values; end
        def validations; @validations ||= {}; end
        def destroy_all; @entries = {}; @id = 0; end

        def find(hash)
          @entries ||= {}
          @entries.values.select do |v|
            v.send(hash.first[0]) == hash.first[1]
          end
        end

        def first(hash); self.find(hash).first; end

        def find_by_id(id); @entries ||= {}; @entries[id]; end

        def keys; @keys ||= {}; end

        def types; @types ||= {}; end

        def key(name, *args)
          name = name.to_s
          @keys  ||= {}; @types ||= {}

          @keys[name]  = nil

          if args.length > 0
            first = args.shift
            unless first.is_a? Hash
              @types[name] = first
              first = args.shift
            end
            hash = first
            if hash && hash[:default]
              @keys[name] = hash[:default]
            end
          end

          self.class_eval do
            define_method(name){@values[name]}

            define_method(:"#{name}="){|value| @values[name] = value}
          end
        end

        def belongs_to(*args)
          if args.last.is_a? Hash
            if args.last[:class_name]
              class_name = args.last[:class_name]
              require_model class_name.downcase
            end
          end

          class_name ||= args.first.to_s.capitalize

          unless Kernel.constants.include? class_name
            require_model class_name.downcase
          end

          klass = Kernel.const_get(class_name)

          name = args.first.to_s

          key(name, klass)

          self.class_eval do
            define_method(name) do
              @values[name]
            end

            define_method(:"#{name}=") do |value|
              @values[name] = value
              @values["#{name}_id"] = value.id
            end

            define_method(:"#{name}_id=") do |value|
              @values[name] = klass.find_by_id(value)
              @values["#{name}_id"] = value
            end
          end
        end

        def many(*args)
          name = args.first.to_s
          in_key = "#{name}_ids"
          if args.last.is_a? Hash
            if args.last[:class_name]
              class_name = args.last[:class_name]
              require_model class_name.downcase
            end

            in_key = args.last[:in].to_s if args.last[:in]
          end

          class_name ||= args.first.to_s.capitalize

          klass = Kernel.const_get(class_name)

          key name, klass

          @keys[name] = []
          @keys[in_key] = []

          self.class_eval do
            define_method(name) do
              Collection.new(klass, self, in_key, @values[in_key])
            end
          end
        end

        def timestamps!
          key :created_at, Date
          key :updated_at, Date
        end

        def one(*args)
          name = args.first
          require_model name.to_s.downcase
          klass = Kernel.const_get(name.to_s.capitalize)
          key(name, klass)

          self.class_eval do
            define_method(name) do
              klass.first(:"#{self.class.to_s.downcase}_id" => self.id)
            end
          end
        end

        def validates_presence_of(name)
        end

        VALIDATIONS = [
          :before_validation,
          :after_validation,
          :before_save,
          :before_create,
          :after_create,
          :after_save
        ]

        VALIDATIONS.each do |method|
          define_method(method) do |*args|
            @validations ||= {}
            @validations[method] ||= []
            if args.empty?
              @validations[method]
            else
              @validations[method] << args.first
            end
          end
        end

        def create(*args)
          self.new *args
        end

        def create!(*args)
          self.new *args
        end
      end

      def self.included(mod)
        MongoMapper.add_model mod
        mod.class_eval do
          extend Includes

          key :_id, ObjectId

          def initialize(*args)
            id = self.class._next_id
            self.class._entries[id] = self

            @values = {}
            self.class.keys.each do |k, v|
              @values[k] = v
            end

            self._id = id

            Includes::VALIDATIONS.each do |method|
              next unless self.class.validations[method]
              self.class.validations[method].each do |callback|
                self.send(callback)
              end
            end

            self.update_attributes(args.first) if args.first
          end

          def id
            self._id
          end

          def save
            # heh.
          end

          def save!
            self.save
          end

          def update_attributes(hash)
            hash.each do |k, v|
              self.send(:"#{k}=", v)
            end
          end
        end
      end
    end
  end

  # Extra
  class Symbol
    def desc
    end
  end
end
