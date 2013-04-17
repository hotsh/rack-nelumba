require_relative 'helper'
require_model 'author'

describe Author do
  describe "Schema" do
    it "should have a local key" do
      Author.keys.keys.must_include "local"
    end

    it "should have a uid" do
      Author.keys.keys.must_include "uid"
    end

    it "should have a nickname" do
      Author.keys.keys.must_include "nickname"
    end

    it "should have an extended_name" do
      Author.keys.keys.must_include "extended_name"
    end

    it "should have a uri" do
      Author.keys.keys.must_include "uri"
    end

    it "should have an email" do
      Author.keys.keys.must_include "email"
    end

    it "should have a name" do
      Author.keys.keys.must_include "name"
    end

    it "should have an organization" do
      Author.keys.keys.must_include "organization"
    end

    it "should have an address" do
      Author.keys.keys.must_include "address"
    end

    it "should have a gender" do
      Author.keys.keys.must_include "gender"
    end

    it "should have a note" do
      Author.keys.keys.must_include "note"
    end

    it "should have a display_name" do
      Author.keys.keys.must_include "display_name"
    end

    it "should have a preferred_username" do
      Author.keys.keys.must_include "preferred_username"
    end

    it "should have a birthday" do
      Author.keys.keys.must_include "birthday"
    end

    it "should have an anniversary" do
      Author.keys.keys.must_include "anniversary"
    end

    it "should have a created_at" do
      Author.keys.keys.must_include "created_at"
    end

    it "should have a updated_at" do
      Author.keys.keys.must_include "updated_at"
    end
  end

  describe "find_or_create_by_uid!" do
    it "should allow Lotus::Author to be given" do
      author = Lotus::Author.new
      author.stubs(:id).returns("UID")

      Author.expects(:first).with(has_entry(:uid, "UID")).returns(author)

      Author.find_or_create_by_uid! author
    end

    it "should allow a uid to be passed" do
      Author.expects(:first).with(has_entry(:uid, "UID")).returns(Author.create)

      Author.find_or_create_by_uid! :uid => "UID"
    end

    it "should return the existing Author object for the Lotus::Author" do
      author = Lotus::Author.new
      author.stubs(:id).returns("UID")

      matching = Author.create(:uid => author.id)

      Author.find_or_create_by_uid!(author).id.must_equal matching.id
    end

    it "should return the existing Author object for the given uid" do
      matching = Author.create(:uid => "UID")

      Author.find_or_create_by_uid!(:uid => "UID").id.must_equal matching.id
    end

    it "should create a new Author when the Author is not found" do
      Author.expects(:create!)
      Author.find_or_create_by_uid! :uid => "unknown"
    end

    it "should return a new Author when the Author is not found" do
      Author.stubs(:create!).returns("author")
      Author.find_or_create_by_uid!(:uid => "unknown").must_equal "author"
    end

    it "should account for race condition where entry was created after find" do
      Author.stubs(:first).returns(nil).then.returns("author")
      Author.stubs(:create!).raises("")
      Author.find_or_create_by_uid!(:uid => "UID").must_equal "author"
    end
  end

  describe "create!" do
    it "should take a Lotus::Author" do
      author = Lotus::Author.new
      author.stubs(:to_hash).returns({:id => "UID"})

      Author.create!(author).uid.must_equal "UID"
    end

    it "should allow a hash of values" do
      Author.create!(:uid => "UID").uid.must_equal "UID"
    end

    it "should not store arbitrary fields" do
      Author.create!(:foobar => "bar").serializable_hash.keys
        .wont_include "foobar"
    end
  end

  describe "discover!" do
    it "should create an identity when author is discovered" do
      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      identity.stubs(:author).returns({})
      Identity.stubs(:find_by_identifier).returns(nil)
      Lotus.stubs(:discover_identity).with("wilkie@rstat.us").returns(identity)

      feed = Lotus::Feed.new
      Lotus.stubs(:discover_feed).with(identity).returns(feed)

      saved_feed = stub('Feed')
      author = stub('Author')
      saved_feed.stubs(:authors).returns([author])
      Feed.stubs(:create!).with(feed).returns(saved_feed)

      Identity.expects(:create!).returns(identity)

      Author.discover! "wilkie@rstat.us"
    end

    it "should return false if identity cannot be discovered" do
      Lotus.stubs(:discover_identity).returns(nil)

      Author.discover!("bogus@rstat.us").must_equal false
    end

    it "should return false if feed cannot be discovered" do
      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      Identity.stubs(:find_by_identifier).returns(nil)
      Lotus.stubs(:discover_identity).returns(identity)
      Lotus.stubs(:discover_feed).returns(nil)

      Author.discover!("bogus@rstat.us").must_equal false
    end

    it "should return Author if does not exist" do
      author = stub('Author')
      Identity.stubs(:find_by_identifier).returns(nil)

      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      identity.stubs(:author).returns(author)
      Lotus.stubs(:discover_identity).with("wilkie@rstat.us").returns(identity)

      feed = Lotus::Feed.new
      Lotus.stubs(:discover_feed).with(identity).returns(feed)

      saved_feed = stub('Feed')
      saved_feed.stubs(:authors).returns([author])
      Feed.stubs(:create!).with(feed).returns(saved_feed)

      Identity.stubs(:create!).returns(identity)

      Author.discover!("wilkie@rstat.us").must_equal author
    end

    it "should return existing Author if it can" do
      author = stub('Author')

      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      identity.stubs(:author).returns(author)

      Identity.stubs(:find_by_identifier).returns(identity)
      Lotus.stubs(:discover_identity).with("wilkie@rstat.us").returns(nil)

      Author.discover!("wilkie@rstat.us").must_equal author
    end

    it "should assign the Identity outbox to the discovered feed" do
      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      identity.stubs(:author).returns({})
      Identity.stubs(:find_by_identifier).returns(nil)
      Lotus.stubs(:discover_identity).with("wilkie@rstat.us").returns(identity)

      feed = Lotus::Feed.new
      Lotus.stubs(:discover_feed).with(identity).returns(feed)

      saved_feed = stub('Feed')
      author = stub('Author')
      saved_feed.stubs(:authors).returns([author])
      Feed.stubs(:create!).with(feed).returns(saved_feed)

      Identity.expects(:create!)
        .with(has_entry(:outbox, saved_feed))
        .returns(identity)

      Author.discover! "wilkie@rstat.us"
    end

    it "should assign the Identity author to the discovered author" do
      identity = Lotus::Identity.new
      identity.stubs(:to_hash).returns({})
      identity.stubs(:author).returns({})
      Identity.stubs(:find_by_identifier).returns(nil)
      Lotus.stubs(:discover_identity).with("wilkie@rstat.us").returns(identity)

      feed = Lotus::Feed.new
      Lotus.stubs(:discover_feed).with(identity).returns(feed)

      saved_feed = stub('Feed')
      author = stub('Author')
      saved_feed.stubs(:authors).returns([author])
      Feed.stubs(:create!).with(feed).returns(saved_feed)

      Identity.expects(:create!)
        .with(has_entry(:author, author))
        .returns(identity)

      Author.discover! "wilkie@rstat.us"
    end
  end

  describe "#discover_feed!" do
    it "should use Lotus to discover a feed from the identity" do
      author = Author.create

      Identity.create(:author_id => author.id)

      lotus_identity = Lotus::Identity.new
      Identity.any_instance.stubs(:to_lotus).returns(lotus_identity)

      Lotus.expects(:discover_feed).with(lotus_identity)

      author.discover_feed!
    end
  end

  describe "sanitize_params" do
    it "should allow extended name" do
      Author.sanitize_params({:extended_name => {}})
        .keys.must_include "extended_name"
    end

    it "should allow extended name's formatted field" do
      hash = {"extended_name" => {:formatted => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:formatted]
        .must_equal "foobar"
    end

    it "should allow extended name's given_name field" do
      hash = {"extended_name" => {:given_name => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:given_name]
        .must_equal "foobar"
    end

    it "should allow extended name's family_name field" do
      hash = {"extended_name" => {:family_name => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:family_name]
        .must_equal "foobar"
    end

    it "should allow extended name's honorific_prefix field" do
      hash = {"extended_name" => {:honorific_prefix => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:honorific_prefix]
        .must_equal "foobar"
    end

    it "should allow extended name's honorific_suffix field" do
      hash = {"extended_name" => {:honorific_suffix => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:honorific_suffix]
        .must_equal "foobar"
    end

    it "should allow extended name's middle_name field" do
      hash = {"extended_name" => {:middle_name => "foobar"}}
      Author.sanitize_params(hash)["extended_name"][:middle_name]
        .must_equal "foobar"
    end

    it "should allow organization" do
      Author.sanitize_params({"organization" => {}})
        .keys.must_include "organization"
    end

    it "should allow organization's name field" do
      hash = {"organization" => {:name => "foobar"}}
      Author.sanitize_params(hash)["organization"][:name]
        .must_equal "foobar"
    end

    it "should allow organization's department field" do
      hash = {"organization" => {:department => "foobar"}}
      Author.sanitize_params(hash)["organization"][:department]
        .must_equal "foobar"
    end

    it "should allow organization's title field" do
      hash = {"organization" => {:title => "foobar"}}
      Author.sanitize_params(hash)["organization"][:title]
        .must_equal "foobar"
    end

    it "should allow organization's type field" do
      hash = {"organization" => {:type => "foobar"}}
      Author.sanitize_params(hash)["organization"][:type]
        .must_equal "foobar"
    end

    it "should allow organization's start_date field" do
      hash = {"organization" => {:start_date => "foobar"}}
      Author.sanitize_params(hash)["organization"][:start_date]
        .must_equal "foobar"
    end

    it "should allow organization's end_date field" do
      hash = {"organization" => {:end_date => "foobar"}}
      Author.sanitize_params(hash)["organization"][:end_date]
        .must_equal "foobar"
    end

    it "should allow organization's description field" do
      hash = {"organization" => {:description => "foobar"}}
      Author.sanitize_params(hash)["organization"][:description]
        .must_equal "foobar"
    end

    it "should allow address" do
      Author.sanitize_params({"address" => {}})
        .keys.must_include "address"
    end

    it "should allow address's formatted field" do
      hash = {"address" => {:formatted => "foobar"}}
      Author.sanitize_params(hash)["address"][:formatted]
        .must_equal "foobar"
    end

    it "should allow address's street_address field" do
      hash = {"address" => {:street_address => "foobar"}}
      Author.sanitize_params(hash)["address"][:street_address]
        .must_equal "foobar"
    end

    it "should allow address's locality field" do
      hash = {"address" => {:locality => "foobar"}}
      Author.sanitize_params(hash)["address"][:locality]
        .must_equal "foobar"
    end

    it "should allow address's region field" do
      hash = {"address" => {:region => "foobar"}}
      Author.sanitize_params(hash)["address"][:region]
        .must_equal "foobar"
    end

    it "should allow address's country field" do
      hash = {"address" => {:country => "foobar"}}
      Author.sanitize_params(hash)["address"][:country]
        .must_equal "foobar"
    end

    it "should allow address's postal_code field" do
      hash = {"address" => {:postal_code => "foobar"}}
      Author.sanitize_params(hash)["address"][:postal_code]
        .must_equal "foobar"
    end

    it "should allow Author keys" do
      hash = {}
      Author.keys.keys.each do |k|
        next if ["extended_name", "organization", "address", "_id"].include? k
        hash[k] = "foobar"
      end

      hash = Author.sanitize_params(hash)

      Author.keys.keys.each do |k|
        next if ["extended_name", "organization", "address", "_id"].include? k
        hash[k].must_equal "foobar"
      end
    end

    it "should convert symbols to strings" do
      hash = {}
      Author.keys.keys.each do |k|
        next if ["extended_name", "organization", "address", "_id"].include? k
        hash[k.intern] = "foobar"
      end

      hash = Author.sanitize_params(hash)

      Author.keys.keys.each do |k|
        next if ["extended_name", "organization", "address", "_id"].include? k
        hash[k].must_equal "foobar"
      end
    end

    it "should not allow _id" do
      hash = {"_id" => "bogus"}
      hash = Author.sanitize_params(hash)
      hash.keys.wont_include "_id"
    end

    it "should not allow arbitrary keys" do
      hash = {:bogus => "foobar"}

      hash = Author.sanitize_params(hash)

      hash.keys.wont_include :bogus
    end
  end

  describe "#short_name" do
    it "should use display_name over all else" do
      author = Author.create(:display_name => "display",
                             :name => "name",
                             :preferred_username => "preferred",
                             :nickname => "nickname",
                             :uid => "unique")

      author.short_name.must_equal "display"
    end

    it "should use name over all else when display name doesn't exist" do
      author = Author.create(:name => "name",
                             :preferred_username => "preferred",
                             :nickname => "nickname",
                             :uid => "unique")

      author.short_name.must_equal "name"
    end

    it "should use preferred_username when name and display_name don't exist" do
      author = Author.create(:preferred_username => "preferred",
                             :nickname => "nickname",
                             :uid => "unique")

      author.short_name.must_equal "preferred"
    end

    it "should use nickname when it exists and others do not" do
      author = Author.create(:nickname => "nickname",
                             :uid => "unique")

      author.short_name.must_equal "nickname"
    end

    it "should use uid when all else fails" do
      author = Author.create(:uid => "unique")

      author.short_name.must_equal "unique"
    end
  end

  describe "#remote?" do
    it "should return the negation of the local field" do
      Author.create(:local => true).remote?.must_equal false
      Author.create(:local => false).remote?.must_equal true
    end
  end

  describe "#local?" do
    it "should return the local field" do
      Author.create(:local => true).local?.must_equal true
      Author.create(:local => false).local?.must_equal false
    end
  end

  describe "#update_avatar!" do
    it "should pass through the url to Avatar.from_url!" do
      Avatar.expects(:from_url!).with(anything, "avatar_url", anything)

      author = Author.create
      author.update_avatar! "avatar_url"
    end

    it "should pass through author instance to Avatar.from_url!" do
      author = Author.create

      Avatar.expects(:from_url!).with(author, anything, anything)

      author.update_avatar! "avatar_url"
    end

    it "should pass through appropriate avatar size" do
      Avatar.expects(:from_url!)
        .with(anything, anything, has_entry(:sizes, [[48, 48]]))

      author = Author.create
      author.update_avatar! "avatar_url"
    end
  end
end
