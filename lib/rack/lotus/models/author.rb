# This represents a person. They act by creating Activities. These Activities
# go into Feeds. Feeds are collected into Aggregates.
class Author
  include MongoMapper::Document

  # Every Author has a representation of their central Identity.
  one :identity

  # Local accounts have a Person, but remote Authors will not.
  one :person

  # Whether or not this Author is a representation of somebody generating
  # content on our server.
  key :local

  # Each Author has an Avatar icon that identifies them.
  one :avatar

  # A unique identifier for this author.
  key :uid

  # A nickname for this author.
  key :nickname

  # A Hash containing a representation of (typically) the Author's real name:
  #   :formatted         => The full name of the contact
  #   :family_name       => The family name. "Last name" in Western contexts.
  #   :given_name        => The given name. "First name" in Western contexts.
  #   :middle_name       => The middle name.
  #   :honorific_prefix  => "Title" in Western contexts. (e.g. "Mr." "Mrs.")
  #   :honorific_suffix  => "Suffix" in Western contexts. (e.g. "Esq.")
  key :extended_name

  # A URI that identifies this author and can be used to access a
  # canonical representation of this structure.
  key :uri

  # The email for this Author.
  key :email

  # The name for this Author.
  key :name

  # A Hash containing information about the organization this Author
  # represents:
  #   :name        => The name of the organization (e.g. company, school,
  #                   etc) This field is required. Will be used for sorting.
  #   :department  => The department within the organization.
  #   :title       => The title or role within the organization.
  #   :type        => The type of organization. Canonical values include
  #                   "job" or "school"
  #   :start_date  => A DateTime representing when the contact joined
  #                   the organization.
  #   :end_date    => A DateTime representing when the contact left the
  #                   organization.
  #   :location    => The physical location of this organization.
  #   :description => A free-text description of the role this contact
  #                   played in this organization.
  key :organization

  # A Hash containing the location of this Author:
  #   :formatted      => A formatted representating of the address. May
  #                     contain newlines.
  #   :street_address => The full street address. May contain newlines.
  #   :locality       => The city or locality component.
  #   :region         => The state or region component.
  #   :postal_code    => The zipcode or postal code component.
  #   :country        => The country name component.
  key :address

  # A Hash containing the account information for this Author:
  #   :domain   => The top-most authoriative domain for this account. (e.g.
  #                "twitter.com") This is the primary field. Is required.
  #                Used for sorting.
  #   :username => An alphanumeric username, typically chosen by the user.
  #   :userid   => A user id, typically assigned, that uniquely refers to
  #                the user.
  key :account

  # The Author's gender.
  key :gender

  # A biographical note.
  key :note

  # The name the Author wishes to be used in display.
  key :display_name

  # The preferred username for the Author.
  key :preferred_username

  # A Date indicating the Author's birthday.
  key :birthday

  # A Date indicating an anniversary.
  key :anniversary

  timestamps!

  # Create a new Author if the given Author is not found by its uid.
  def self.find_or_create_by_uid!(arg, *args)
    if arg.is_a? ::Lotus::Author
      uid = arg.id
    else
      uid = arg[:uid]
    end

    author = self.find(:uid => uid)
    return author if author

    begin
      author = create!(arg, *args)
    rescue
      author = self.find(:uid => uid) or raise
    end

    author
  end

  # Create a new Author from a Hash of values or a Lotus::Author.
  def self.create!(arg, *args)
    if arg.is_a? Lotus::Author
      arg = arg.to_hash
      arg[:uid] = arg[:id]
      arg.delete :id
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
                                    :author => saved_feed.authors.first)).author
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

  # Determines the name to use to refer to this Author in a view.
  def short_name
    if self.display_name
      self.display_name
    elsif self.name
      self.name
    elsif self.preferred_username
      self.preferred_username
    elsif self.nickname
      self.nickname
    else
      self.uid
    end
  end

  def remote?
    !self.local
  end

  def local?
    self.local
  end

  # Updates our avatar with the given url.
  def update_avatar!(url)
    Avatar.from_url!(self, url, :sizes => [[48, 48]])
  end
end
