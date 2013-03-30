# This represents a feed aggregator. These entities wrap a feed with metadata
# representing how it interacts with the outside world. It has a single feed
# the manages the entries it aggregates. New entries can exist within the
# aggregate feed that do not exist elsewhere, but they can also be copies
# of entries in other feeds.
class Aggregate
  include MongoMapper::Document

  # The content of this aggregate.
  key  :feed,          Feed

  # The external feeds being aggregated.
  key  :following_ids, Array
  many :following,     :in => :following_ids, :class_name => 'Feed'

  # Who is aggregating this feed.
  key  :followers_ids, Array
  many :followers,     :in => :followers_ids, :class_name => 'Feed'

  timestamps!

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

    # Push to direct followers
    followers.each do |f|
      puts "PUSH TO #{f}"
    end

    # Ping PuSH hubs
    feed.ping
  end

  def repost!(activity)
    feed.repost! activity

    # Push to direct followers
    followers.each do |f|
      puts "PUSH TO #{f}"
    end

    # Ping PuSH hubs
    feed.ping
  end
end
