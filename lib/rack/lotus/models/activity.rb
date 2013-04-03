# This represents an action taken by an Author.
class Activity
  include MongoMapper::Document

  # All Activities originate from one particular Feed.
  one :feed

  # Unique id for this Activity.
  key :id

  # Unique url for this activity that can be used to retrieve a representation
  # of this Activity.
  key :url

  # Determines what type of object this Activity represents. Standard types
  # include:
  #   :article, :audio, :bookmark, :comment, :file, :folder, :group,
  #   :list, :note, :person, :photo, :"photo-album", :place, :playlist,
  #   :product, :review, :service, :status, :video
  key :type

  # Determines the action this Activity represents. Standard types include:
  #   :favorite, :follow, :like, :"make-friend", :join, :play,
  #   :post, :save, :share, :tag, :update
  key :verb

  # Determines what is acting.
  key :actor

  # Determines what the action is acting upon.
  key :target

  # The title of the Activity.
  key :title

  # The content of the Activity.
  key :content

  # Determines what representation the content is in. (e.g. "html")
  key :content_type

  # Contains the source of this Activity if it is a repost or otherwise copied
  # from another Feed.
  key :source, :class_name => 'Feed'

  # Contains the Activity this Activity is a response of.
  key :in_reply_to, :class_name => 'Activity'

  # Log modification
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
