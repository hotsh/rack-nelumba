# This represents a collection of activities.
class Feed
  include MongoMapper::Document

  # An Aggregate handles subscriptions to this Feed.
  belongs_to :aggregate

  # A unique identifier for this Feed.
  key :id

  # A URL for this Feed that can be used to retrieve a representation.
  key :url

  key :categories,   :default => []

  # The type of rights one has to this feed generally for human display.
  key :rights

  # The title of this feed.
  key :title

  # The representation of the title. (e.g. "html")
  key :title_type

  # The subtitle of the feed.
  key :subtitle

  # The representation of the subtitle. (e.g. "html")
  key :subtitle_type

  # An array of Authors that contributed to this Feed.
  key  :contributors_ids, Array, :default => []
  many :contributors,     :class_name => 'Author', :in => :contributors_ids

  # An Array of Authors that create the content in this Feed.
  key  :authors_ids,  Array, :default => []
  many :authors,      :class_name => 'Author', :in => :authors_ids

  # An Array of Activities that are contained in this Feed.
  key :entries_ids,  Array
  many :entries,     :class_name => 'Activity', :in => :entries_ids

  # An Array of hubs that are used to balance subscriptions to this Feed.
  key :hubs,         Array, :default => []

  # A salmon url for this Feed.
  key :salmon_url

  # A Hash containing information about the entity that is generating content
  # for this Feed when it isn't a person.
  key :generator

  # Feeds may have an icon to represent them.
  key :icon, :class_name => 'Avatar'

  # Feeds may have an image they use as a logo.
  #key :logo, :class_name => 'Photo'

  # TODO: Normalize the first 100 or so activities. I dunno.
  key :normalized

  # Log modification
  timestamps!

  # Create a new Feed if the given Feed is not found by its id.
  def self.find_or_create_by_id!(arg, *args)
    if arg.is_a? ::Lotus::Feed
      uid = arg.id
    else
      uid = arg[:uid]
    end

    feed = self.find(:uid => uid)
    return feed if author

    begin
      feed = create!(arg, *args)
    rescue
      feed = self.find(:uid => uid) or raise
    end

    feed
  end

  # Create a new Feed from a Hash of values or a Lotus::Feed.
  def self.create!(arg, *args)
    if arg.is_a? ::Lotus::Feed
      arg = arg.to_hash

      arg[:uid] = arg[:id]
      arg.delete :id

      arg[:authors].map! do |a|
        Author.find_or_create_by_uid!(a, :safe => true)
      end

      arg[:contributors].map! do |a|
        Author.find_or_create_by_uid!(a, :safe => true)
      end

      arg[:entries].map! do |a|
        Activity.find_or_create_by_uid!(a, :safe => true)
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
