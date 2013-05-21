# Represents a typical social experience. This contains a feed of our
# contributions, our consumable feed (timeline), our list of favorites,
# a list of things that mention us and replies to us. It keeps track of
# our social presence with who follows us and who we follow.
class Person
  include MongoMapper::Document

  # A Person can be Authorized to use this system.
  key :authorization_id, ObjectId
  belongs_to :authorization, :class_name => 'Authorization'

  # A Person has an associated Author. (However, not every Author has a Person)
  key :author_id, ObjectId
  belongs_to :author, :class_name => 'Author'

  # Our contributions.
  key :activities_id,    ObjectId
  belongs_to :activities, :class_name => 'Aggregate'

  # The combined contributions of ourself and others we follow.
  key :timeline_id,      ObjectId
  belongs_to :timeline, :class_name => 'Aggregate'

  # The things we like.
  key :favorites_id,     ObjectId
  belongs_to :favorites, :class_name => 'Aggregate'

  # The things we shared.
  key :shared_id,     ObjectId
  belongs_to :shared, :class_name => 'Aggregate'

  # Replies to our stuff.
  key :replies_id,       ObjectId
  belongs_to :replies, :class_name => 'Aggregate'

  # Stuff that mentions us.
  key :mentions_id,      ObjectId
  belongs_to :mentions, :class_name => 'Aggregate'

  # The people that follow us.
  key  :following_ids, Array
  many :following,     :in => :following_ids, :class_name => 'Author'

  # Who is aggregating this feed.
  key  :followers_ids, Array
  many :followers,     :in => :followers_ids, :class_name => 'Author'

  before_create :create_author
  before_create :create_aggregates

  private

  def create_author
    self.author = Author.create(:uri   => "/people/#{self.id}",
                                :uid   => "/people/#{self.id}",
                                :local => true)
  end

  def create_aggregates
    self.activities = create_aggregate
    self.timeline   = create_aggregate
    self.shared     = create_aggregate
    self.favorites  = create_aggregate
    self.replies    = create_aggregate
    self.mentions   = create_aggregate
  end

  def create_aggregate
    Aggregate.create(:person_id => self.id)
  end

  public

  # Updates so that we now follow the given Author.
  def follow!(author)
    if author.is_a? Identity
      author = author.author
    end

    # add the author from our list of followers
    self.following << author
    self.save

    # determine the feed to subscribe to
    self.timeline.follow! author.identity.outbox.feed

    # tell local users that somebody on this server is following them.
    if author.local?
      author.person.followed_by! self.author
    end

    # Add the activity
    self.activities.post!(:verb => :follow,
                          :actor_id => self.author.id,
                          :actor_type => 'Author',
                          :object_uid => author.id,
                          :object_type => 'Author')
  end

  # Updates so that we do not follow the given Author.
  def unfollow!(author)
    if author.is_a? Identity
      author = author.author
    end

    # remove the person from our list of followers
    self.following_ids.delete(author.id)
    self.save

    # unfollow their timeline feed
    self.timeline.unfollow! author.identity.outbox.feed

    # tell local users that somebody on this server has stopped following them.
    if author.local?
      author.person.unfollowed_by! self.author
    end

    # Add the activity
    self.activities.post!(:verb => :"stop-following",
                          :actor_id => self.author.id,
                          :actor_type => 'Author',
                          :object_uid => author.id,
                          :object_type => 'Author')
  end

  # Updates to show we are now followed by the given Author.
  def followed_by!(author)
    if author.is_a? Identity
      author = author.author
    end

    return if author.nil?

    # add them from our list
    self.followers << author
    self.save

    # determine their feed
    self.activities.followed_by! author.identity.inbox.feed
  end

  # Updates to show we are not followed by the given Author.
  def unfollowed_by!(author)
    if author.is_a? Identity
      author = author.author
    end

    return if author.nil?

    # remove them from our list
    self.followers_ids.delete(author.id)
    self.save

    # remove their feed as a syndicate of our activities
    self.activities.unfollowed_by! author.identity.inbox.feed
  end

  # Add the given Activity to our list of favorites.
  def favorite!(activity)
    self.favorites.repost! activity

    self.activities.post!(:verb => :favorite,
                          :actor_id => self.author.id,
                          :actor_type => 'Author',
                          :object_uid => activity.id,
                          :object_type => 'Activity')
  end

  # Remove the given Activity from our list of favorites.
  def unfavorite!(activity)
    self.favorites.delete! activity

    self.activities.post!(:verb => :unfavorite,
                          :actor_id => self.author.id,
                          :actor_type => 'Author',
                          :object_uid => activity.id,
                          :object_type => 'Activity')
  end

  # Add the given Activity to our list of those that mention us.
  def mentioned_by!(activity)
    self.mentions.repost! activity
  end

  # Add the given Activity to our list of those that are replies to our posts.
  def replied_by!(activity)
    self.replies.repost! activity
  end

  # Post a new Activity.
  def post!(activity)
    if activity.is_a? Hash
      activity["actor_id"] = self.author_id
      activity["actor_type"] = 'Author'

      activity["verb"] = :post unless activity["verb"]
      activity["type"] = :note unless activity["type"]

      # Create a new activity
      activity = Activity.create!(activity)
    end

    self.activities.post! activity
    self.timeline.repost! activity
  end

  # Repost an existing Activity.
  def share!(activity)
    self.timeline.repost! activity
    self.shared.repost!   activity

    self.activities.post!(:verb => :share,
                          :actor_id => self.author.id,
                          :actor_type => 'Author',
                          :object_uid => activity.id,
                          :object_type => 'Activity')
  end

  # Deliver an external Activity from somebody we follow.
  #
  # This goes in our timeline.
  def deliver!(activity)
    # Determine the original feed as duplicate it in our timeline
    author = Author.find(:id => activity.author.id)

    # Do not deliver if we do not follow the Author
    return false if author.nil?
    return false unless followings.include?(author)

    # We should know how to talk back to this person
    identity = Identity.find_by_author(author)
    return false if identity.nil?

    # Add to author's outbox feed
    identity.outbox.post! activity

    # Copy activity to timeline
    if activity.type == :note
      self.timeline.repost! activity
    end
  end

  # Receive an external Activity from somebody we don't know.
  #
  # Generally, will be a mention or reply. Shouldn't go into timeline.
  def receive!(activity)
  end

  # Deliver an activity from within the server
  def local_deliver!(activity)
    self.timeline.repost! activity
  end
end
