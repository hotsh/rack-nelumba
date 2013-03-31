# This represents a collection of activities.
class Feed
  include MongoMapper::Document

  key :id
  key :url
  key :categories,   :default => []
  key :rights
  key :title
  key :title_type
  key :subtitle
  key :subtitle_type
  key :icon
  key :logo
  key :generator
  key :contributors, Array, :default => []
  key :authors,      Array, :default => []
  key :entries_ids,  Array
  many :entries,      :class_name => 'Activity', :in => :entries_ids
  key :hubs,         Array, :default => []
  key :salmon_url

  # Subscription status.
  # Since subscriptions are done by the server, we only need to share one
  # secret/token pair for all users that follow this feed on the server.
  key :subscription_secret
  key :verification_token

  # TODO: Normalize the first 100 or so activities. I dunno.
  key :normalized

  timestamps!

  # Create a new Feed if the given Feed is not found by its id.
  def self.find_or_create_by_id!(arg, *args)
    if arg.is_a? ::Lotus::Feed
      id = arg.id
    else
      id = arg[:id]
    end

    feed = self.find(:id => id)
    return feed if author

    begin
      feed = create!(arg, *args)
    rescue
      feed = self.find(:id => id) or raise
    end

    feed
  end

  # Create a new Feed from a Hash of values or a Lotus::Feed.
  def self.create!(arg, *args)
    if arg.is_a? ::Lotus::Feed
      arg = arg.to_hash

      arg[:authors].map! do |a|
        Author.find_or_create_by_id!(a, :safe => true)
      end

      arg[:contributors].map! do |a|
        Author.find_or_create_by_id!(a, :safe => true)
      end

      arg[:entries].map! do |a|
        Activity.find_or_create_by_id!(a, :safe => true)
      end
    end

    super arg, *args
  end

  # Discover a feed by the given feed location or account.
  def self.discover!(feed_identifier)
    feed = ::Lotus.discover_feed(feed_identifier)
    return false unless feed

    self.create!(feed)
  end

  # Adds activity to the feed.
  def post!(activity)
    activity.feed = self
    activity.save

    self.entries << activity
    self.save
  end

  # Reposts an activity from another feed.
  def repost!(activity)
    self.entries << activity
    self.save
  end

  # Merges the information in the given feed with this one.
  def merge!(feed)
    # Merge metadata
    meta_data = feed.to_hash
    meta_data.delete :entries
    meta_data.delete :authors
    meta_data.delete :contributors
    self.update_attributes!(meta_data)

    # Merge new/updated authors
    feed.authors.each do |author|
    end

    # Merge new/updated activities
    feed.entries.each do |activity|
    end
  end

  # Pings the hub or owner of this feed
  def ping
    self.hubs.each do |h|
      puts "PING #{h}"
    end
  end
end
