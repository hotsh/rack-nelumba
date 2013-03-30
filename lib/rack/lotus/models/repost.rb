class Repost
  include MongoMapper::Document

  key :entry, Activity
  key :feed,  Feed
end
