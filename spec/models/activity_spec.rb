require_relative 'helper'
require_model 'activity'

describe Activity do
  describe "Schema" do
    it "should have a feed_id" do
      Activity.keys.keys.must_include "feed_id"
    end

    it "should have a uid" do
      Activity.keys.keys.must_include "uid"
    end

    it "should have a url" do
      Activity.keys.keys.must_include "url"
    end

    it "should have a type" do
      Activity.keys.keys.must_include "type"
    end

    it "should have an actor_id" do
      Activity.keys.keys.must_include "actor_id"
    end

    it "should have an actor_type" do
      Activity.keys.keys.must_include "actor_type"
    end

    it "should have a target_id" do
      Activity.keys.keys.must_include "target_id"
    end

    it "should have a target_type" do
      Activity.keys.keys.must_include "target_type"
    end

    it "should have an object_uid" do
      Activity.keys.keys.must_include "object_uid"
    end

    it "should have an object_type" do
      Activity.keys.keys.must_include "object_type"
    end

    it "should have a title" do
      Activity.keys.keys.must_include "title"
    end

    it "should have a content" do
      Activity.keys.keys.must_include "content"
    end

    it "should have a content_type" do
      Activity.keys.keys.must_include "content_type"
    end

    it "should have a source" do
      Activity.keys.keys.must_include "source"
    end

    it "should have an in_reply_to" do
      Activity.keys.keys.must_include "in_reply_to"
    end

    it "should have a created_at" do
      Activity.keys.keys.must_include "created_at"
    end

    it "should have a updated_at" do
      Activity.keys.keys.must_include "updated_at"
    end
  end

  describe "create!" do
    it "should assign default uid" do
      activity = Activity.new
      activity.run_callbacks :create

      activity.uid.must_equal "/activities/#{activity.id}"
    end

    it "should assign default url" do
      activity = Activity.new
      activity.run_callbacks :create

      activity.url.must_equal "/activities/#{activity.id}"
    end
  end

  describe "#actor=" do
    it "should assign actor_id to the id of a given Author" do
      activity = Activity.new
      actor = Author.new

      activity.actor = actor

      activity.actor_id.must_equal actor.id
    end

    it "should assign actor_id to the id of a given Activity" do
      activity = Activity.new
      actor = Activity.new

      activity.actor = actor

      activity.actor_id.must_equal actor.id
    end

    it "should assign actor_type appropriately for a given Author" do
      activity = Activity.new
      actor = Author.new

      activity.actor = actor

      activity.actor_type.must_equal "Author"
    end

    it "should assign actor_type appropriately for a given Activity" do
      activity = Activity.new
      actor = Activity.new

      activity.actor = actor

      activity.actor_type.must_equal "Activity"
    end
  end

  describe "#actor" do
    it "should retrieve a stored Author" do
      actor = Author.create
      activity = Activity.new(:actor_id => actor.id,
                              :actor_type => "Author")

      activity.actor.id.must_equal actor.id
      activity.actor.class.must_equal Author
    end

    it "should retrieve a stored Activity" do
      actor = Activity.create
      activity = Activity.new(:actor_id => actor.id,
                              :actor_type => "Activity")

      activity.actor.id.must_equal actor.id
      activity.actor.class.must_equal Activity
    end
  end

  describe "find_or_create_by_uid!" do
    it "should return the existing Activity" do
      activity = Activity.create!(:uid => "UID",
                                  :url => "URL")

      Activity.find_or_create_by_uid!(:uid => "UID").id.must_equal activity.id
    end

    it "should return the existing Activity via Lotus::Activity" do
      activity = Activity.create!(:uid => "UID",
                                  :url => "URL")

      lotus_activity = Lotus::Activity.new
      lotus_activity.stubs(:id).returns("UID")

      Activity.find_or_create_by_uid!(lotus_activity).id.must_equal activity.id
    end

    it "should create when the Activity is not found" do
      Activity.expects(:create!).with({:uid => "UID"})
      Activity.find_or_create_by_uid!(:uid => "UID")
    end

    it "should create via Lotus::Activity when the Activity is not found" do
      lotus_activity = Lotus::Activity.new
      lotus_activity.stubs(:id).returns("UID")

      Activity.expects(:create!).with(lotus_activity)
      Activity.find_or_create_by_uid!(lotus_activity)
    end

    it "should account for race condition where entry was created after find" do
      Activity.stubs(:first).returns(nil).then.returns("activity")
      Activity.stubs(:create!).raises("")
      Activity.find_or_create_by_uid!(:uid => "UID").must_equal "activity"
    end
  end

  describe "discover!" do
    it "should call out to Lotus to discover the given Activity" do
      Lotus.expects(:discover_activity).with("activity_url")
      Activity.discover!("activity_url")
    end

    it "should return false when the Activity cannot be discovered" do
      Lotus.stubs(:discover_activity).returns(false)
      Activity.discover!("activity_url").must_equal false
    end

    it "should return the existing Activity if it is found by url" do
      activity = Activity.create!(:url => "activity_url",
                                  :uid => "uid")
      Activity.discover!("activity_url").id.must_equal activity.id
    end

    it "should return the existing Activity if uid matches" do
      activity = Activity.create!(:url => "activity_url",
                                  :uid => "ID")

      lotus_activity = Lotus::Activity.new
      lotus_activity.stubs(:id).returns("ID")

      Lotus.stubs(:discover_activity).returns(lotus_activity)
      Activity.discover!("alternative_url").id.must_equal activity.id
    end

    it "should create a new Activity from the discovered Lotus::Activity" do
      lotus_activity = Lotus::Activity.new
      lotus_activity.stubs(:id).returns("ID")

      Lotus.stubs(:discover_activity).returns(lotus_activity)
      Activity.expects(:create!).returns("new_activity")
      Activity.discover!("alternative_url")
    end

    it "should return the new Activity from the discovered Lotus::Activity" do
      lotus_activity = Lotus::Activity.new
      lotus_activity.stubs(:id).returns("ID")

      Lotus.stubs(:discover_activity).returns(lotus_activity)
      Activity.stubs(:create!).returns("new_activity")
      Activity.discover!("alternative_url").must_equal "new_activity"
    end
  end

  describe "#parts_of_speech" do
    it "should yield the verb" do
      activity = Activity.create(:verb => :follow)

      activity.parts_of_speech[:verb].must_equal :follow
    end

    it "should yield a default verb of :post" do
      activity = Activity.create

      activity.parts_of_speech[:verb].must_equal :post
    end

    it "should yield the type as object_type" do
      activity = Activity.create(:type => :person)

      activity.parts_of_speech[:object_type].must_equal :person
    end

    it "should yield a default type as :note" do
      activity = Activity.create

      activity.parts_of_speech[:object_type].must_equal :note
    end

    it "should yield the object when it is an Author" do
      author = Author.create(:nickname => "wilkie")
      activity = Activity.create(:object => author)

      activity.parts_of_speech[:object].nickname.must_equal "wilkie"
    end

    it "should yield the object when it is an Activity" do
      object_activity = Activity.create(:verb => :follow)
      activity = Activity.create(:object => object_activity)

      activity.parts_of_speech[:object].verb.must_equal :follow
    end

    it "should yield the object as self when object isn't embedded" do
      activity = Activity.create

      activity.parts_of_speech[:object].must_equal activity
    end

    it "should yield the object owner as actor of embedded Activity" do
      author = Author.create(:nickname => "wilkie")
      object_activity = Activity.create(:verb  => :follow,
                                        :actor => author)
      activity = Activity.create(:object => object_activity)

      activity.parts_of_speech[:object_owner].nickname.must_equal "wilkie"
    end

    it "should yield the object owner as the embedded Author" do
      author = Author.create(:nickname => "wilkie")
      activity = Activity.create(:object => author)

      activity.parts_of_speech[:object_owner].nickname.must_equal "wilkie"
    end

    it "should yield the object owner as actor when object isn't embedded" do
      author = Author.create(:nickname => "wilkie")
      activity = Activity.create(:actor => author)

      activity.parts_of_speech[:object_owner].nickname.must_equal "wilkie"
    end

    it "should yield a nil value for object owner if no other possiblity" do
      activity = Activity.create

      activity.parts_of_speech[:object_owner].must_equal nil
    end

    it "should yield the subject as the actor" do
      author = Author.create(:nickname => "wilkie")
      activity = Activity.create(:actor => author)

      activity.parts_of_speech[:subject].nickname.must_equal "wilkie"
    end

    it "should yield when as the modified date" do
      activity = Activity.create

      activity.parts_of_speech[:when].must_equal activity.updated_at
    end
  end
end
