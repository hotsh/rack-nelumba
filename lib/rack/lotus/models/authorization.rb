# This represents how a Person can authenticate to act on our server.
# This is attached to an Identity and an Author. Use this to allow an
# Author to generate Activities on this server.
class Authorization
  require 'bcrypt'

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
