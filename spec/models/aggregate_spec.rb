require_relative 'helper'
require_model 'aggregate'

describe Aggregate do
  describe "Schema" do
    it "should have a person_id" do
      Aggregate.keys.keys.must_include "person_id"
    end

    it "should have a following_ids array" do
      Aggregate.keys.keys.must_include "following_ids"
    end

    it "should have many following" do
      Aggregate.has_many?(:following).must_equal true
    end

    it "should have a followers_ids array" do
      Aggregate.keys.keys.must_include "followers_ids"
    end

    it "should have many followers" do
      Aggregate.has_many?(:followers).must_equal true
    end

    it "should have one feed" do
      Aggregate.has_one?(:feed).must_equal true
    end

    it "should have a subscription_secret" do
      Aggregate.keys.keys.must_include "subscription_secret"
    end

    it "should have a verification_token" do
      Aggregate.keys.keys.must_include "verification_token"
    end

    it "should have a person_id" do
      Aggregate.keys.keys.must_include "person_id"
    end

    it "should belong to person" do
      Aggregate.belongs_to?(:person).must_equal true
    end

    it "should have a created_at" do
      Aggregate.keys.keys.must_include "created_at"
    end

    it "should have a updated_at" do
      Aggregate.keys.keys.must_include "updated_at"
    end
  end

  describe "create" do
    it "should create a feed for this aggregate" do
      aggregate = Aggregate.new
      feed = Feed.new
      Feed.expects(:new).returns(feed)
      feed.stubs(:save)

      aggregate.run_callbacks :create
    end

    it "should set the feed's uid and url" do
      aggregate = Aggregate.new
      feed = Feed.new
      Feed.stubs(:new).returns(feed)
      feed.stubs(:save)

      feed.expects(:uid=).with("/feeds/#{feed.id}")
      feed.expects(:url=).with("/feeds/#{feed.id}")

      aggregate.run_callbacks :create
    end

    it "should set the feed's author when local author" do
      aggregate = Aggregate.new
      feed = Feed.new
      Feed.stubs(:new).returns(feed)
      feed.stubs(:save)

      person = Person.new
      person.stubs(:author).returns(Author.new)
      aggregate.stubs(:person).returns(person)
      feed.expects(:author=).with(person.author)

      aggregate.run_callbacks :create
    end

    it "should associate the feed with the aggregate" do
      aggregate = Aggregate.new
      feed = Feed.new
      Feed.stubs(:new).returns(feed)
      feed.stubs(:save)

      feed.expects(:aggregate_id=).with(aggregate.id)

      aggregate.run_callbacks :create
    end
  end

  describe "#follow!" do
    it "should add the given feed to the following list" do
      aggregate = Aggregate.new
      aggregate.stubs(:save)

      feed = Feed.new
      feed.stubs(:save)

      aggregate.follow! feed

      aggregate.following_ids.must_include feed.id
    end

    it "should save" do
      aggregate = Aggregate.new
      feed = Feed.new
      feed.stubs(:save)

      aggregate.expects(:save)

      aggregate.follow! feed
    end
  end

  describe "#unfollow!" do
    it "should remove the given feed from the following list" do
      aggregate = Aggregate.new
      aggregate.stubs(:save)

      feed = Feed.new
      feed.stubs(:save)

      aggregate.unfollow! feed

      aggregate.following_ids.wont_include feed.id
    end

    it "should save" do
      aggregate = Aggregate.new
      feed = Feed.new
      feed.stubs(:save)

      aggregate.expects(:save)

      aggregate.unfollow! feed
    end
  end

  describe "#followed_by!" do
    it "should add the given feed to the followers list" do
      aggregate = Aggregate.new
      aggregate.stubs(:save)

      feed = Feed.new
      feed.stubs(:save)

      aggregate.followed_by! feed

      aggregate.followers_ids.must_include feed.id
    end

    it "should save" do
      aggregate = Aggregate.new
      feed = Feed.new
      feed.stubs(:save)

      aggregate.expects(:save)

      aggregate.followed_by! feed
    end
  end

  describe "#unfollowed_by!" do
    it "should remove the given feed from the followers list" do
      aggregate = Aggregate.new
      aggregate.stubs(:save)

      feed = Feed.new
      feed.stubs(:save)

      aggregate.unfollowed_by! feed

      aggregate.followers_ids.wont_include feed.id
    end

    it "should save" do
      aggregate = Aggregate.new
      feed = Feed.new
      feed.stubs(:save)

      aggregate.expects(:save)

      aggregate.unfollowed_by! feed
    end
  end

  describe "#post!" do
    before do
      @aggregate = Aggregate.new
      @aggregate.stubs(:feed).returns(Feed.new)
      @aggregate.stubs(:publish)
    end

    it "should post the activity to the feed" do
      activity = Activity.new
      @aggregate.feed.expects(:post!).with(activity)
      @aggregate.post! activity
    end

    it "should publish the feed" do
      activity = Activity.new
      @aggregate.expects(:publish).with(activity)
      @aggregate.post! activity
    end
  end

  describe "#delete!" do
    it "should delete the activity in the feed" do
      aggregate = Aggregate.new
      aggregate.stubs(:feed).returns(Feed.new)

      activity = Activity.new
      aggregate.feed.expects(:delete!).with(activity)
      aggregate.delete! activity
    end
  end

  describe "#repost!" do
    before do
      @aggregate = Aggregate.new
      @aggregate.stubs(:feed).returns(Feed.new)
      @aggregate.stubs(:publish)
    end

    it "should repost the activity to the feed" do
      activity = Activity.new
      @aggregate.feed.expects(:repost!).with(activity)
      @aggregate.repost! activity
    end

    it "should publish the feed" do
      activity = Activity.new
      @aggregate.expects(:publish).with(activity)
      @aggregate.repost! activity
    end
  end

  describe "#publish" do
    it "should repost in every feed that follows this aggregate" do
      activity = Activity.new

      aggregate = Aggregate.new
      feeds = [Feed.new, Feed.new, Feed.new]

      feeds.each do |f|
        f.expects(:repost!).with(activity)
      end

      aggregate.stubs(:followers).returns(feeds)
      aggregate.publish activity
    end
  end
end
