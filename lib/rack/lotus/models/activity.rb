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

  # Create a new Activity if the given Activity is not found by its id.
  def self.find_or_create_by_id!(arg, *args)
    if arg.is_a? ::Lotus::Activity
      id = arg.id
    else
      id = arg[:id]
    end

    activity = self.find(:id => id)
    return activity if author

    begin
      activity = create!(arg, *args)
    rescue
      activity = self.find(:id => id) or raise
    end

    activity
  end

  # Create a new Activity from a Hash of values or a Lotus::Activity.
  def self.create!(arg, *args)
    if arg.is_a? Lotus::Activity
      arg = arg.to_hash

      arg.delete :author
      arg.delete :in_reply_to
    end

    super arg, *args
  end

  # Discover a feed by the given activity location.
  def self.discover!(activity_identifier)
    activity = Lotus.discover_activity(activity_identifier)
    return false unless activity

    self.create!(activity)
  end
end
