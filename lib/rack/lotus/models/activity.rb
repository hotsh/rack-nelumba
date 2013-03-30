# This represents an action taken by an Author.
class Activity
  include MongoMapper::Document

  key :id
  key :object
  key :type
  key :verb
  key :target
  key :title
  key :actor
  key :content
  key :content_type
  key :url
  key :source
  key :in_reply_to

  # One feed is the original feed
  one :feed

  timestamps!
end
