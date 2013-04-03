# This represents the information necessary to talk to an Author that is
# external to our node, or it represents how to talk to us.
# An Identity stores endpoints that are used to push or pull Activities from.
class Identity
  include MongoMapper::Document

  belongs_to :author
  key :author_id, ObjectId

  key :username
  key :ssl
  key :domain

  key :public_key
  key :salmon_endpoint
  key :dialback_endpoint
  key :activity_inbox_endpoint
  key :activity_outbox_endpoint
  key :profile_page

  key :outbox, :class_name => 'Feed'

  timestamps!

  # Create a new Identity from a Hash of values or a Lotus::Identity.
  def self.create!(arg, *args)
    if arg.is_a? Lotus::Identity
      arg = arg.to_hash
    end

    super arg, *args
  end

  # Ensure params has only valid keys
  def self.sanitize_params(params)
    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.map.include? k
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("_id")
  end

  # Discover an identity from the given user identifier.
  def self.discover!(account)
    identity = Lotus.discover_identity(account)
    return false unless identity

    self.create!(identity)
  end

  # Creates an immutable Lotus::Identity representation.
  def to_lotus
  end
end
