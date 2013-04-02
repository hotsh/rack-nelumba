# Represents a typical social experience. This contains a feed of our
# contributions, our consumable feed (timeline), our list of favorites,
# a list of things that mention us and replies to us. It keeps track of
# our social presence with who follows us and who we follow.
class Person
  include MongoMapper::Document

  # A Person can be Authorized to use this system.
  belongs_to :authorization

  # A Person has an associated Author. (However, not every Author has a Person)
  one :author

  # Our contributions.
  key :activities,    Aggregate

  # The combined contributions of ourself and others we follow.
  key :timeline,      Aggregate

  # The things we like.
  key :favorites,     Aggregate

  # Replies to our stuff.
  key :replies,       Aggregate

  # Stuff that mentions us.
  key :mentions,      Aggregate

  # The people that follow us.
  key  :following_ids, Array
  many :following,     :in => :following_ids, :class_name => 'Author'

  # Who is aggregating this feed.
  key  :followers_ids, Array
  many :followers,     :in => :followers_ids, :class_name => 'Author'

  # Updates so that we now follow the given Author.
  def follow!(person)
    # add the person from our list of followers
    self.following << person

    # determine the feed to subscribe to
    self.timeline.follow! person
  end

  # Updates so that we do not follow the given Author.
  def unfollow!(person)
    # remove the person from our list of followers
    self.following_ids.delete(person)

    # unfollow their timeline feed
    self.timeline.unfollow! person
  end

  # Updates to show we are now followed by the given Author.
  def followed_by!(person)
    # add them from our list
    self.followers << person

    # determine their feed

    # add their feed as a syndicate of our activities
    self.activities.followed_by! person
  end

  # Updates to show we are not followed by the given Author.
  def unfollowed_by!(person)
    # remove them from our list
    self.followers_ids.delete(person.id)

    # remove their feed as a syndicate of our activities
    self.activities.unfollowed_by! person
  end

  # Add the given Activity to our list of favorites.
  def favorite!(activity)
    self.favorites.post! activity
  end

  # Add the given Activity to our list of those that mention us.
  def mentioned_by!(activity)
    self.mentions.post! activity
  end

  # Add the given Activity to our list of those that are replies to our posts.
  def replied_by!(activity)
    self.replies.post! activity
  end

  # Post a new Activity.
  def post!(activity)
    self.activities.post! activity
    self.timeline.repost! activity
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
end
