require_relative 'helper'
require_model 'authorization'

require 'xml'

module Application
  BCRYPT_ROUNDS = 1234
end

def create_authorization(params)
  Authorization.stubs(:hash_password).returns("hashed")
  authorization = Authorization.new(params)

  author = Author.new
  author.stubs(:save).returns(true)
  author.stubs(:update_attributes).returns(true)

  person = Person.new
  person.stubs(:save).returns(true)
  person.stubs(:author).returns(author)
  person.stubs(:activities).returns(Aggregate.new)

  authorization.stubs(:person).returns(person)

  outbox = Aggregate.new

  identity = Identity.new
  identity.stubs(:domain).returns "example.com"
  identity.stubs(:profile_page).returns "/people/#{person.id}"
  identity.stubs(:save).returns(true)
  identity.stubs(:author).returns(author)
  identity.stubs(:outbox).returns(outbox)

  author.stubs(:identity).returns(identity)
  authorization.stubs(:identity).returns(identity)
  Identity.stubs(:create!).returns(identity)

  Person.stubs(:create).returns(person)

  keypair = Struct.new(:public_key, :private_key).new("PUBKEY", "PRIVKEY")
  Lotus::Crypto.stubs(:new_keypair).returns(keypair)

  authorization
end

describe Authorization do
  describe "Schema" do
    it "should have one person" do
      Authorization.has_one?(:person).must_equal true
    end

    it "should have an identity_id" do
      Authorization.keys.keys.must_include "identity_id"
    end

    it "should belong to a identity" do
      Authorization.belongs_to?(:identity).must_equal true
    end

    it "should have a username" do
      Authorization.keys.keys.must_include "username"
    end

    it "should have a private_key" do
      Authorization.keys.keys.must_include "private_key"
    end

    it "should have a hashed_password" do
      Authorization.keys.keys.must_include "hashed_password"
    end

    it "should have an updated_at" do
      Authorization.keys.keys.must_include "updated_at"
    end

    it "should have a created_at" do
      Authorization.keys.keys.must_include "created_at"
    end

    it "should not have a password" do
      Authorization.keys.keys.wont_include "password"
    end
  end

  describe "create" do
    before do
      Authorization.stubs(:hash_password).returns("hashed")
      @authorization = Authorization.new

      author = Author.new
      author.stubs(:save).returns(true)
      author.stubs(:update_attributes).returns(true)

      @person = Person.new
      @person.stubs(:save).returns(true)
      @person.stubs(:author).returns(author)
      @person.stubs(:activities).returns(Aggregate.new)
      @person.stubs(:timeline).returns(Aggregate.new)

      identity = Identity.new
      identity.stubs(:save).returns(true)
      identity.stubs(:author).returns(author)

      author.stubs(:identity).returns(identity)
      Identity.stubs(:create!).returns(identity)

      keypair = Struct.new(:public_key, :private_key).new("PUBKEY", "PRIVKEY")
      Lotus::Crypto.stubs(:new_keypair).returns(keypair)

      Person.stubs(:create).returns(@person)
    end

    it "should create a person" do
      Person.expects(:create)
            .with(:authorization_id => @authorization.id)
            .returns(@person)

      @authorization.save
    end

    it "should set the new person's author attributes to the username" do
      @person.author.expects(:update_attributes)
                    .with(has_entries(:nickname           => "wilkie",
                                      :name               => "wilkie",
                                      :display_name       => "wilkie",
                                      :preferred_username => "wilkie"))
                    .returns(true)

      @authorization.username = "wilkie"
      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity" do
      Identity.expects(:create!)
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with the generated public key" do
      Identity.expects(:create!)
              .with(has_entry(:public_key, "PUBKEY"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with the given username" do
      Identity.expects(:create!)
              .with(has_entry(:username, "wilkie"))
              .returns(@person)

      @authorization.username = "wilkie"
      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with the new person's author" do
      Identity.expects(:create!)
              .with(has_entry(:author_id, @person.author.id))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's salmon endpoint" do
      Identity.expects(:create!)
              .with(has_entry(:salmon_endpoint, "/people/#{@person.id}/salmon"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's dialback endpoint" do
      Identity.expects(:create!)
              .with(has_entry(:dialback_endpoint,
                              "/people/#{@person.id}/dialback"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's activity inbox endpoint" do
      Identity.expects(:create!)
              .with(has_entry(:activity_inbox_endpoint,
                              "/people/#{@person.id}/inbox"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's activity outbox endpoint" do
      Identity.expects(:create!)
              .with(has_entry(:activity_outbox_endpoint,
                              "/people/#{@person.id}/outbox"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's activity outbox endpoint" do
      Identity.expects(:create!)
              .with(has_entry(:activity_outbox_endpoint,
                              "/people/#{@person.id}/outbox"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity with person's profile page" do
      Identity.expects(:create!)
              .with(has_entry(:profile_page, "/people/#{@person.id}"))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity associated with the person's timeline" do
      Identity.expects(:create!)
              .with(has_entry(:inbox_id, @person.timeline.id))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should create an Identity associated with the person's activities" do
      Identity.expects(:create!)
              .with(has_entry(:outbox_id, @person.activities.id))
              .returns(@person)

      Authorization.create!(:username => "wilkie",
                            :password => "foobar")
    end

    it "should associate a new Identity with this Authorization" do
      @authorization = Authorization.create!(:username => "wilkie",
                                             :password => "foobar")

      @authorization.identity_id.must_equal @person.author.identity.id
    end

    it "should store the private key" do
      @authorization = Authorization.create!(:username => "wilkie",
                                             :password => "foobar")

      @authorization.private_key.must_equal "PRIVKEY"
    end
  end

  describe "lrdd" do
    it "returns nil when the username cannot be found" do
      Authorization.stubs(:find_by_username).returns(nil)
      Authorization.lrdd("bogus@example.com").must_equal nil
    end

    it "should contain a subject matching their webfinger" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:subject]
                   .must_equal "acct:wilkie@example.com"
    end

    it "should contain an alias to the profile" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:aliases]
        .must_include "http://example.com/people/#{authorization.person.id}"
    end

    it "should contain an alias to the profile" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:aliases]
        .must_include "http://example.com/people/#{authorization.person.id}"
    end

    it "should contain an alias to the feed" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:aliases].must_include(
        "http://example.com/feeds/#{authorization.identity.outbox.id}")
    end

    it "should contain profile-page link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      person_id = authorization.person.id

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include({:rel  => "http://webfinger.net/rel/profile-page",
                       :href => "http://example.com/people/#{person_id}"})
    end

    it "should contain updates-from link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      feed_id = authorization.identity.outbox.id

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include({:rel  => "http://schemas.google.com/g/2010#updates-from",
                       :href => "http://example.com/feeds/#{feed_id}"})
    end

    it "should contain salmon link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      person_id = authorization.person.id

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include(:rel  => "salmon",
                      :href => "http://example.com/people/#{person_id}/salmon")
    end

    it "should contain salmon-replies link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      person_id = authorization.person.id

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include(:rel  => "http://salmon-protocol.org/ns/salmon-replies",
                      :href => "http://example.com/people/#{person_id}/salmon")
    end

    it "should contain salmon-mention link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      person_id = authorization.person.id

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include(:rel  => "http://salmon-protocol.org/ns/salmon-mention",
                      :href => "http://example.com/people/#{person_id}/salmon")
    end

    it "should contain magic-public-key link" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")
      person_id = authorization.person.id

      authorization.identity.public_key = "PUBLIC_KEY"

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:links]
        .must_include(:rel  => "magic-public-key",
                      :href => "data:application/magic-public-key,PUBLIC_KEY")
    end

    it "should contain an expires link that is 1 month away from retrieval" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")

      check_date = Date.new(2012, 1, 1)
      Date.any_instance.expects(:>>).with(1).returns(check_date)

      Authorization.stubs(:find_by_username).returns(authorization)
      Authorization.lrdd("wilkie@example.com")[:expires].must_equal(
        "#{check_date.xmlschema}Z")
    end
  end

  describe "jrd" do
    it "should simply take the lrdd and run to_json" do
      lrdd_hash = {}
      Authorization.stubs(:lrdd).with("wilkie@example.com").returns(lrdd_hash)
      lrdd_hash.stubs(:to_json).returns("JSON")

      Authorization.jrd("wilkie@example.com").must_equal "JSON"
    end

    it "should return nil when lrdd returns nil" do
      Authorization.stubs(:lrdd).returns(nil)
      Authorization.jrd("bogus@example.com").must_equal nil
    end
  end

  describe "xrd" do
    before do
      @authorization = create_authorization("username" => "wilkie",
                                            "password" => "foobar")

      Authorization.stubs(:lrdd).returns(:subject => "Subject",
                                         :expires => "Date",
                                         :aliases => ["alias_a",
                                                      "alias_b"],
                                         :links   => [
                                           {:rel  => "a rel",
                                            :href => "a href"},
                                           {:rel  => "b rel",
                                            :href => "b href"}])

      @xrd = Authorization.xrd("wilkie@example.com")

      @xml = XML::Parser.string(@xrd).parse
    end

    it "should return nil when lrdd returns nil" do
      Authorization.stubs(:lrdd).returns(nil)
      Authorization.xrd("bogus@example.com").must_equal nil
    end

    it "should publish a version of 1.0" do
      @xrd.must_match /^<\?xml[^>]*\sversion="1\.0"/
    end

    it "should encode in utf-8" do
      @xrd.must_match /^<\?xml[^>]*\sencoding="UTF-8"/
    end

    it "should contain the XRD namespace" do
      @xml.root.namespaces
               .find_by_href('http://docs.oasis-open.org/ns/xri/xrd-1.0').to_s
               .must_equal 'http://docs.oasis-open.org/ns/xri/xrd-1.0'
    end

    it "should contain the xsi namespace" do
      @xml.root.namespaces
               .find_by_prefix('xsi').to_s
               .must_equal 'xsi:http://www.w3.org/2001/XMLSchema-instance'
    end

    it "should contain the <Subject>" do
      @xml.root.find_first('xmlns:Subject',
                           'xmlns:http://docs.oasis-open.org/ns/xri/xrd-1.0')
        .content.must_equal Authorization.lrdd("wilkie@example.com")[:subject]
    end

    it "should contain the <Expires>" do
      @xml.root.find_first('xmlns:Expires',
                           'xmlns:http://docs.oasis-open.org/ns/xri/xrd-1.0')
        .content.must_equal Authorization.lrdd("wilkie@example.com")[:expires]
    end

    it "should contain the <Alias> tags" do
      aliases = Authorization.lrdd("wilkie@example.com")[:aliases]
      @xml.root.find('xmlns:Alias',
                  'xmlns:http://docs.oasis-open.org/ns/xri/xrd-1.0').each do |t|
        index = aliases.index(t.content)
        index.wont_equal nil

        aliases.delete_at index
      end
    end

    it "should contain the <Link> tags" do
      links = Authorization.lrdd("wilkie@example.com")[:links]
      @xml.root.find('xmlns:Link',
                  'xmlns:http://docs.oasis-open.org/ns/xri/xrd-1.0').each do |t|
        link = {:rel  => t.attributes.get_attribute('rel').value,
                :href => t.attributes.get_attribute('href').value}
        index = links.index(link)
        index.wont_equal nil

        links.delete_at index
      end
    end
  end

  describe "hash_password" do
    it "should call bcrypt with the application specified number of rounds" do
      BCrypt::Password.expects(:create).with(anything, has_entry(:cost, 1234))
      Authorization.hash_password("foobar")
    end

    it "should call bcrypt with the given password" do
      BCrypt::Password.expects(:create).with("foobar", anything)
      Authorization.hash_password("foobar")
    end

    it "should return the hashed password" do
      BCrypt::Password.expects(:create).returns("hashed!")
      Authorization.hash_password("foobar").must_equal "hashed!"
    end
  end

  describe "#authenticated?" do
    it "should compare the given password with the stored password" do
      authorization = create_authorization("username" => "wilkie",
                                           "password" => "foobar")

      checker = stub('String')
      BCrypt::Password.stubs(:new).with("hashed").returns(checker)

      checker.expects(:==).with("foobar")
      authorization.authenticated?("foobar")
    end
  end

  describe "sanitize_params" do
    it "should allow Authorization keys" do
      hash = {}
      Authorization.keys.keys.each do |k|
        next if ["_id"].include? k
        hash[k] = "foobar"
      end

      hash = Authorization.sanitize_params(hash)

      Authorization.keys.keys.each do |k|
        next if ["_id"].include? k
        hash[k].must_equal "foobar"
      end
    end

    it "should remove password key" do
      hash = {"password" => "foobar"}
      hash = Authorization.sanitize_params(hash)
      hash.keys.wont_include "password"
    end

    it "should convert symbols to strings" do
      hash = {}
      Authorization.keys.keys.each do |k|
        next if ["_id"].include? k
        hash[k.intern] = "foobar"
      end

      hash = Authorization.sanitize_params(hash)

      Authorization.keys.keys.each do |k|
        next if ["_id"].include? k
        hash[k].must_equal "foobar"
      end
    end

    it "should not allow _id" do
      hash = {"_id" => "bogus"}
      hash = Authorization.sanitize_params(hash)
      hash.keys.wont_include "_id"
    end

    it "should not allow arbitrary keys" do
      hash = {:bogus => "foobar"}

      hash = Authorization.sanitize_params(hash)

      hash.keys.wont_include :bogus
    end
  end
end
