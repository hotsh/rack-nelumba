# This represents an action taken by an Author.
class Activity
  include MongoMapper::Document

  # All Activities originate from one particular Feed.
  key :feed_id, ObjectId
  belongs_to :feed, :class_name => 'Feed'

  # Unique id for this Activity.
  key :uid

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
  key :actor_id, ObjectId
  key :actor_type, String

  # Determines what the action is acting upon.
  key :target_id, ObjectId
  key :target_type, String

  # Can attach an external object to this Activity.
  # It has a weird name because it complains if I use object_id
  key :object_uid, ObjectId
  key :object_type, String

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

  # Ensure that url and uid for the activity are set
  before_create :ensure_uid_and_url

  private

  # Ensure uid and url are established. If they don't exist, just use urls
  # that point to us for the sake of uniqueness.
  def ensure_uid_and_url
    unless self.uid && self.url
      self.uid = "/activities/#{self.id}"
      self.url = "/activities/#{self.id}"
      self.save
    end
  end

  public

  # Set the actor.
  def actor=(obj)
    self.actor_id   = obj.id
    self.actor_type = obj.class.to_s
  end

  # Get the actor.
  def actor
    klass = Kernel.const_get(self.actor_type.class) if self.actor_type
    klass.first_by_id(self.actor_id) if klass && self.actor_id
  end

  # Create a new Activity if the given Activity is not found by its id.
  def self.find_or_create_by_uid!(arg, *args)
    if arg.is_a? ::Lotus::Activity
      uid = arg.id
    else
      uid = arg[:uid]
    end

    activity = self.find(:uid => uid)
    return activity if activity

    begin
      activity = create!(arg, *args)
    rescue
      activity = self.find(:uid => uid) or raise
    end

    activity
  end

  # Create a new Activity from a Hash of values or a Lotus::Activity.
  def self.create!(arg, *args)
    if arg.is_a? Lotus::Activity
      arg = arg.to_hash

      arg[:uid] = arg[:id]
      arg.delete :id

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

  # Generates components of the description of the action taken by this
  # activity. This would be a good place for localization efforts.
  def human_description
    actor = "someone"
    case self.actor_type
    when 'Author'
      author = Author.find_by_id(self.actor_id)
      actor = author.short_name if author
    end

    verb = "did something to"
    case self.verb
    when :favorite
      verb = "favorited"
    when :follow
      verb = "followed"
    when :"stop-following"
      verb = "stopped following"
    when :unfavorite
      verb = "unfavorited"
    end

    object = "something"
    activity = self
    case self.object_type
    when 'Activity'
      embedded_activity = Activity.find_by_id(self.object_id)
      activity = embedded_activity if embedded_activity
    when 'Author'
      embedded_author = Author.find_by_id(self.object_id)
      object = embedded_author if embedded_author
    end

    object_author = nil
    unless object.is_a? Author
      object_author = Author.find_by_id(activity.actor_id) if activity.actor_type == 'Author'
      object_author = activity.feed.authors.first unless object_author
      object_author = object_author.short_name if object_author
    end

    if object.is_a? Author
      object = object.short_name
    elsif activity.type
      case activity.type
      when :note
        object = "status"
      else
        object = activity.type.to_s
      end
    end

    if object_author
      sentence = "#{actor} #{verb} #{object_author}'s #{object}"
    else
      sentence = "#{actor} #{verb} #{object}"
    end

    {
      :actor         => actor,
      :verb          => verb,
      :activity      => activity,
      :object        => object,
      :object_author => object_author,
      :sentence      => sentence
    }
  end
end
