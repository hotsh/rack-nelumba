# This represents a feed aggregator. These entities wrap a feed with metadata
# representing how it interacts with the outside world. It has a single feed
# the manages the entries it aggregates. New entries can exist within the
# aggregate feed that do not exist elsewhere, but they can also be copies
# of entries in other feeds.
class Aggregate
  include MongoMapper::Document

  # The content of this aggregate is a Feed.
  one :feed

  # Aggregates generally belong to a person.
  key :person_id, ObjectId
  belongs_to :person, :class_name => 'Person'

  # The external feeds being aggregated.
  key  :following_ids, Array
  many :following,     :in => :following_ids, :class_name => 'Feed'

  # Who is aggregating this feed.
  key  :followers_ids, Array
  many :followers,     :in => :followers_ids, :class_name => 'Feed'

  # Subscription status.
  # Since subscriptions are done by the server, we only need to share one
  # secret/token pair for all users that follow this feed on the server.
  # This is done at the Feed level since people may want to follow your
  # "timeline", or your "favorites". Or People who use Lotus will ignore
  # the Person aggregate class and go with their own thing.
  key :subscription_secret
  key :verification_token

  # Log modification
  timestamps!

  before_create :create_feeds

  private

  def create_feeds
    feed = Feed.new
    feed.uid = "/feeds/#{feed.id}"
    feed.url = "/feeds/#{feed.id}"
    feed.author = self.person.author if self.person
    feed.aggregate_id = self.id
    feed.save
  end

  public

  # Follow the given feed. When a new post is placed in this feed, it
  # will be copied into ours.
  def follow!(feed)
    self.following << feed
    self.save

    # Subscribe to that feed on this server if not already.
  end

  # Unfollow the given feed. Our feed will no longer receive new posts from
  # the given feed.
  def unfollow!(feed)
    self.following_ids.delete(feed.id)
    self.save
  end

  # Denotes that the given feed will contain your posts.
  def followed_by!(feed)
    self.followers << feed
    self.save
  end

  # Denotes that the given feed will not contain your posts from now on.
  def unfollowed_by!(feed)
    self.followers_ids.delete(feed.id)
    self.save
  end

  # Add to the feed and tell subscribers.
  def post!(activity)
    feed.post! activity

    publish(activity)
  end

  # Remove the activity from the feed.
  def delete!(activity)
    feed.delete! activity
  end

  # Add a copy to our feed and tell subscribers.
  def repost!(activity)
    feed.repost! activity

    publish(activity)
  end

  # Publish an activity that is within our feed.
  def publish(activity)
    # Push to direct followers
    followers.each do |feed|
      feed.repost! activity
    end

    # Ping PuSH hubs
    feed.ping
  end
end
