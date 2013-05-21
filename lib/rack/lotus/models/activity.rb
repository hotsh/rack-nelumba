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
    klass = Kernel.const_get(self.actor_type) if self.actor_type
    klass.find_by_id(self.actor_id) if klass && self.actor_id
  end

  # Set the object.
  def object=(obj)
    if obj.nil?
      self.object_uid = nil
      self.object_type = nil
    else
      self.object_uid  = obj.id
      self.object_type = obj.class.to_s
    end
  end

  # Get the object.
  def object
    return self unless self.object_type

    klass = Kernel.const_get(self.object_type) if self.object_type
    klass.find_by_id(self.object_uid) if klass && self.object_uid
  end

  # Create a new Activity if the given Activity is not found by its id.
  def self.find_or_create_by_uid!(arg, *args)
    if arg.is_a? ::Lotus::Activity
      uid = arg.id
    else
      uid = arg[:uid]
    end

    activity = self.first(:uid => uid)
    return activity if activity

    begin
      activity = create!(arg, *args)
    rescue
      activity = self.first(:uid => uid) or raise
    end

    activity
  end

  # Create a new Activity from a Hash of values or a Lotus::Activity.
  def self.create!(*args)
    hash = {}
    if args.length > 0
      hash = args.shift
    end

    if hash.is_a? Lotus::Activity
      hash = hash.to_hash

      hash[:uid] = hash[:id]
      hash.delete :id

      hash.delete :author
      hash.delete :in_reply_to
    end

    super hash, *args
  end

  # Create a new Activity from a Hash of values or a Lotus::Activity.
  def self.create(*args)
    self.create! *args
  end

  # Discover a feed by the given activity location.
  def self.discover!(activity_identifier)
    activity = Activity.first(:url => activity_identifier)
    return activity if activity

    activity = Lotus.discover_activity(activity_identifier)
    return false unless activity

    existing = Activity.first(:uid => activity.id)
    return existing if existing

    self.create!(activity)
  end

  # Yields the parts of speech for the activity. Returns a hash with the
  # following:
  #
  # :verb         => The action being performed by the subject.
  # :subject      => The entity performing the action.
  # :object       => The object the action is being applied to. Could be an
  #                    Author or Activity
  # :object_type  => How to interpret the object of the action.
  # :object_owner => The entity that owns the object of the action.
  # :when         => The Date when the activity took place.
  # :activity     => A reference to the original Activity.
  def parts_of_speech
    object_owner = nil
    object_owner = self.object.actor if self.object.respond_to?(:actor)
    object_owner = self.object if self.object.is_a?(Author)
    object_owner = self.actor unless self.object_type

    {
      :verb         => self.verb || :post,
      :object       => self.object,
      :object_type  => self.type || :note,
      :object_owner => object_owner,
      :subject      => self.actor,
      :when         => self.updated_at,
      :activity     => self
    }
  end

  def self.find_from_notification(notification)
    Activity.first(:uid => notification.activity.id)
  end

  def self.create_from_notification!(notification)
    # We need to verify the payload
    identity = Identity.discover!(notification.account)
    if notification.verified? identity.return_or_discover_public_key
      # Then add it to our feed in the appropriate place
      identity.discover_author!
      internal_activity = Activity.find_from_notification(notification)

      # If it already exists, update it
      if internal_activity
        internal_activity.update_from_notification(notification, true)
      else
        internal_activity = Activity.create!(notification.activity)
        internal_author = Author.find_or_create_by_uid!(
                            notification.activity.actor.id)

        internal_activity.actor = internal_author
        internal_activity.save
        internal_activity
      end
    else
      nil
    end
  end

  def update_from_notification(notification, force = false)
    # Do not allow another actor to change an existing activity
    if self.actor && self.actor.uri != notification.activity.actor.uri
      return nil
    end

    # We need to verify the payload
    identity = Identity.discover!(notification.account)
    if force or notification.verified?(identity.return_or_discover_public_key)
      # Then add it to our feed in the appropriate place
      identity.discover_author!

      attributes = notification.activity.to_hash
      attributes.delete :id

      self.update_attributes!(attributes)

      self
    else
      nil
    end
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
    self_distinction = "their own"
    case self.verb
    when :favorite
      verb = "favorited"
    when :follow
      verb = "followed"
      self_distinction = "themselves"
    when :"stop-following"
      verb = "stopped following"
      self_distinction = "themselves"
    when :unfavorite
      verb = "unfavorited"
    when :share
      verb = "shared"
    when :post
      verb = "posted"
      self_distinction = "a"
    end

    object = "something"
    activity = self
    case self.object_type
    when 'Activity'
      embedded_activity = Activity.find_by_id(self.object_uid)
      activity = embedded_activity if embedded_activity
    when 'Author'
      embedded_author = Author.find_by_id(self.object_uid)
      object = embedded_author if embedded_author
    end

    object_author = nil
    unless object.is_a? Author
      object_author = Author.find_by_id(activity.actor_id) if activity.actor_type == 'Author'
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

    if object_author != actor
      sentence = "#{actor} #{verb} #{object_author}'s #{object}"
    else
      # Correct self_distinction if needed
      sentence = "#{actor} #{verb} #{self_distinction} #{object}"
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
