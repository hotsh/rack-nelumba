# This represents how a Person can authenticate to act on our server.
# This is attached to an Identity and a Person. Use this to allow an
# Author to generate Activities on this server.
class Authorization
  require 'bcrypt'
  require 'json'
  require 'nokogiri'

  include MongoMapper::Document

  # An Authorization involves a Person.
  one :person

  # An Authorization involves an Identity.
  key :identity_id, ObjectId
  belongs_to :identity, :class_name => 'Identity'

  # You authorize with a username
  key :username,        String

  # A private key can verify that external information originated with this
  # account.
  key :private_key,     String

  # A password can authenticate you if you are manually signing in as a human
  # being. The password is hashed to prevent information leaking.
  key :hashed_password, String

  # You must have enough credentials to be able to log into the system:
  validates_presence_of :username
  validates_presence_of :identity
  validates_presence_of :hashed_password

  before_validation :create_person_and_identity, :on => :create

  # Log modification
  timestamps!

  private

  def create_person_and_identity
    person = Person.create(:authorization_id => self.id)
    person.author.update_attributes(:nickname => username,
                                    :name => username,
                                    :display_name => username,
                                    :preferred_username => username)
    person.author.save

    keypair = ::Lotus::Crypto.new_keypair

    self.identity = Identity.create!(
      :username => self.username,
      :domain => "www.example.com",
      :author => person.author,
      :public_key => keypair.public_key,
      :salmon_endpoint => "/people/#{person.id}/salmon",
      :dialback_endpoint => "/people/#{person.id}/dialback",
      :activity_inbox_endpoint => "/people/#{person.id}/inbox",
      :activity_outbox_endpoint => "/people/#{person.id}/outbox",
      :profile_page => "/people/#{person.id}",
      :outbox_id => person.activities.id
    )
    self.identity_id = self.identity.id

    self.private_key = keypair.private_key
  end

  public

  # Generate a Hash containing this person's LRDD meta info.
  def self.lrdd(username)
    username = username.match /(?:acct\:)?([^@]+)(?:@([^@]+))?$/
    username = username[1] if username
    if username.nil?
      return nil
    end

    # Find the person
    auth = Authorization.find_by_username(/#{Regexp.escape(username)}/i)
    return nil unless auth

    domain    = auth.identity.domain
    url       = "http#{auth.identity.ssl ? "s" : ""}://#{auth.identity.domain}"
    feed_id   = auth.identity.outbox.id
    person_id = auth.person.id

    {
      :subject => "acct:#{username}@#{domain}",
      :expires => "#{(Time.now.utc.to_date >> 1).xmlschema}Z",
      :aliases => [
        "#{url}#{auth.identity.profile_page}",
        "#{url}/feeds/#{feed_id}"
      ],
      :links => [
        {:rel  => "http://webfinger.net/rel/profile-page",
         :href => "#{url}/people/#{person_id}"},
        {:rel  => "http://schemas.google.com/g/2010#updates-from",
         :href => "#{url}/feeds/#{feed_id}"},
        {:rel  => "salmon",
         :href => "#{url}/people/#{person_id}/salmon"},
        {:rel  => "http://salmon-protocol.org/ns/salmon-replies",
         :href => "#{url}/people/#{person_id}/salmon"},
        {:rel  => "http://salmon-protocol.org/ns/salmon-mention",
         :href => "#{url}/people/#{person_id}/salmon"},
        {:rel  => "magic-public-key",
         :href => "data:application/magic-public-key,#{auth.identity.public_key}"}

        # TODO: ostatus subscribe
        #{:rel      => "http://ostatus.org/schema/1.0/subscribe",
        # :template => "#{url}/subscriptions?url={uri}&_method=post"}
      ]
    }
  end

  # Generate a String containing the json representation of this person's LRDD.
  def self.jrd(username)
    lrdd = self.lrdd(username)
    return nil if lrdd.nil?

    lrdd.to_json
  end

  # Generate a String containing the XML representaton of this person's LRDD.
  def self.xrd(username)
    lrdd = self.lrdd(username)
    return nil if lrdd.nil?

    # Build xml
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.XRD("xmlns"     => 'http://docs.oasis-open.org/ns/xri/xrd-1.0',
              "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance') do
        xml.Subject lrdd[:subject]
        xml.Expires lrdd[:expires]

        lrdd[:aliases].each do |alias_name|
          xml.Alias alias_name
        end

        lrdd[:links].each do |link|
          xml.Link link
        end
      end
    end

    # Output
    builder.to_xml
  end

  # Create a hash of the password.
  def self.hash_password(password)
    BCrypt::Password.create(password, :cost => Application::BCRYPT_ROUNDS)
  end

  # Determine if the given password matches the account.
  def authenticated?(password)
    BCrypt::Password.new(hashed_password) == password
  end

  # :nodoc: Do not allow the password to be set at any cost.
  def password=(value)
  end

  # Cleanup any unexpected keys.
  def self.sanitize_params(params)
    params.keys.each do |k|
      if k.is_a? Symbol
        params[k.to_s] = params[k]
        params.delete k
      end
    end

    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.map.include?(k)
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("id")
    params.delete("_id")

    params
  end

  # Create a new Authorization.
  def initialize(*args)
    params = {}
    params = args.shift if args.length > 0

    params["hashed_password"] = Authorization.hash_password(params["password"])
    params = Authorization.sanitize_params(params)

    super params, *args
  end
end
