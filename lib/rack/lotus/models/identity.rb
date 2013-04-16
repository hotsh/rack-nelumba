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

  key :outbox_id, ObjectId
  belongs_to :outbox, :class_name => 'Aggregate'

  timestamps!

  def self.find_by_identifier(identifier)
    matches  = identifier.match /^(?:.+\:)?([^@]+)@(.+)$/

    username = matches[1].downcase
    domain   = matches[2].downcase

    Identity.first(:username => username,
                   :domain => domain)
  end

  # Create a new Identity from a Hash of values or a Lotus::Identity.
  def self.create!(*args)
    hash = {}
    if args.length > 0
      hash = args.shift
    end

    if hash.is_a? Lotus::Identity
      hash = hash.to_hash
    end

    hash["username"] = hash["username"].downcase if hash["username"]
    hash["username"] = hash[:username].downcase if hash[:username]
    hash.delete :username

    hash["domain"] = hash["domain"].downcase if hash["domain"]
    hash["domain"] = hash[:domain].downcase if hash[:domain]
    hash.delete :domain

    hash = self.sanitize_params(hash)

    super hash, *args
  end

  # Create a new Identity from a Hash of values or a Lotus::Identity.
  def self.create(*args)
    self.create! *args
  end

  # Ensure params has only valid keys
  def self.sanitize_params(params)
    params.keys.each do |k|
      if k.is_a? Symbol
        params[k.to_s] = params[k]
        params.delete k
      end
    end

    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.include? k
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("_id")

    params
  end

  # Discover an identity from the given user identifier.
  def self.discover!(account)
    identity = Identity.find_by_identifier(account)
    return identity if identity

    identity = Lotus.discover_identity(account)
    return false unless identity

    self.create!(identity)
  end

  # Creates an immutable Lotus::Identity representation.
  def to_lotus
  end
end
