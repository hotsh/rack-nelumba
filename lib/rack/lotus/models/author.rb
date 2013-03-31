# This represents a person. They act by creating Activities. These Activities
# go into Feeds. Feeds are collected into Aggregates.
class Author
  include MongoMapper::Document

  belongs_to :identity

  key :id
  key :nickname
  key :extended_name
  key :uri
  key :email
  key :name
  key :organization
  key :address
  key :account
  key :gender
  key :note
  key :display_name
  key :preferred_username
  key :birthday
  key :anniversary

  one :embedded_avatar

  timestamps!

  # Create a new Author if the given Author is not found by its id.
  def self.find_or_create_by_id!(arg, *args)
    if arg.is_a? ::Lotus::Author
      id = arg.id
    else
      id = arg[:id]
    end

    author = self.find(:id => id)
    return author if author

    begin
      author = create!(arg, *args)
    rescue
      author = self.find(:id => id) or raise
    end

    author
  end

  # Create a new Author from a Hash of values or a Lotus::Author.
  def self.create!(arg, *args)
    if arg.is_a? Lotus::Author
      arg = arg.to_hash
    end

    super arg, *args
  end

  # Discover an Author by the given feed location or account.
  def self.discover!(author_identifier)
    identity = Lotus.discover_identity(author_identifier)
    return false unless identity

    feed = Lotus.discover_feed(identity)
    return false unless feed

    saved_feed = Feed.create!(feed)
    Identity.create!(identity.merge(:outbox => saved_feed,
                                    :author => saved_feed.authors.first))
  end

  # Discover and populate the associated activity feed for this author.
  def discover_feed!
    feed = Lotus.discover_feed(self.identity.to_lotus)
  end

  def self.sanitize_params(params)
    # Delete unknown subkeys
    if params["extended_name"]
      params["extended_name"].keys.each do |k|
        if ["formatted", "given_name", "family_name", "honorific_prefix",
            "honorific_suffix", "middle_name"].include?(k)
          params["extended_name"][(k.to_sym rescue k)] =
            params["extended_name"].delete(k)
        else
          params["extended_name"].delete(k)
        end
      end
    end

    if params["organization"]
      params["organization"].keys.each do |k|
        if ["name", "department", "title", "type", "start_date", "end_date",
            "description"].include?(k)
          params["organization"][(k.to_sym rescue k)] =
            params["organization"].delete(k)
        else
          params["organization"].delete(k)
        end
      end
    end

    if params["address"]
      params["address"].keys.each do |k|
        if ["formatted", "street_address", "locality", "region", "country",
            "postal_code"].include?(k)
          params["address"][(k.to_sym rescue k)] =
            params["address"].delete(k)
        else
          params["address"].delete(k)
        end
      end
    end

    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.include?(k) ||
             self.keys.keys.map(&:intern).include?(k)
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("_id")

    params
  end
end
