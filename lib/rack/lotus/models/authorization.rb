# This represents how a Person can authenticate to act on our server.
# This is attached to an Identity and an Author. Use this to allow an
# Author to generate Activities on this server.
class Authorization
  require 'bcrypt'
  require 'json'
  require 'nokogiri'

  include MongoMapper::Document

  key :username,        String

  one :person

  key :identity,        Identity
  key :author,          Author

  key :private_key,     String

  key :hashed_password, String

  validates_presence_of :username
  validates_presence_of :identity
  validates_presence_of :author
  validates_presence_of :hashed_password

  timestamps!

  # Generate a Hash containing this person's LRDD meta info.
  def self.lrdd(username)
    username = params[:acct].match /(?:acct\:)?([^@]+)(?:@([^@]+))?$/
    username = username[1] if username
    if username.nil?
      return nil
    end

    # Find the person
    auth = Authorization.find_by_username(/#{Regexp.escape(username)}/i)
    if auth.nil?
      return nil
    end

    url       = "http#{auth.identity.ssl ? "s" : ""}://#{auth.identity.domain}"
    feed_id   = auth.identity.outbox._id
    person_id = auth.person._id

    {
      :subject => "acct:#{username}@#{domain}",
      :expires => "#{(Time.now.utc.to_date >> 1).xmlschema}Z",
      :aliases => [
        "#{url}/profile/#{username}",
        "#{url}/feeds/#{feed_id}"
      ],
      :links => [
        {:rel  => "http://webfinger.net/rel/profile-page",
         :href => "#{url}/profile/#{username}"},
        {:rel  => "http://schemas.google.com/g/2010#updates-from",
         :href => "#{url}/feeds/#{feed_id}"},
        {:rel  => "salmon",
         :href => "#{url}/people/#{person_id}/salmon"},
        {:rel  => "http://salmon-protocol.org/ns/salmon-replies",
         :href => "#{url}/people/#{person_id}/salmon"},
        {:rel  => "http://salmon-protocol.org/ns/salmon-replies",
         :href =>"#{url}/people/#{person_id}/salmon"},
        {:rel  => "magic-public-key",
         :href => "data:application/magic-public-key,#{identity.public_key}"}

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
  def password=
  end

  # Cleanup any unexpected keys.
  def self.sanitize_params(params)
    # Delete unknown keys
    params.keys.each do |k|
      unless self.keys.keys.map.include?(k) and !(k == "password")
        params.delete(k)
      end
    end

    # Delete immutable fields
    params.delete("id")
    params.delete("_id")
  end

  # Create a new Authorization.
  def self.create!(params)
    params["hashed_password"] = self.hash_password(params["password"])
    params.delete("password")

    params["author"] = Author.create!(:uri => "/authorizations/:id",
                                      :id => "/authorizations/:id",
                                      :nickname => params["username"],
                                      :preferred_username => params["username"])

    params["identity"] = Identity.create!(:username => params["username"],
                                          :domain => "www.example.com",
                                          :author => params["author"],
                                          :public_key => "foo")

    params["person"] = Person.create!

    authorization = super(params)

    authorization.author.update_attributes!(:id  => "/authorizations/#{authorization.id}",
                                            :uri => "/authorizations/#{authorization.id}")

    authorization.identity.update_attributes!(:salmon_endpoint => "/authorizations/#{authorization.id}/salmon",
                                              :dialback_endpoint => "/authorizations/#{authorization.id}/dialback",
                                              :activity_inbox_endpoint => "/authorizations/#{authorization.id}/activity_inbox",
                                              :activity_outbox_endpoint => "/authorizations/#{authorization.id}/activity_outbox",
                                              :profile_page => "/authorizations/#{authorization.id}")

    authorization
  end
end
