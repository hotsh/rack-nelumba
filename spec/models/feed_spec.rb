require_relative 'helper'
require_model 'feed'

describe Feed do
  describe "Schema" do
    it "should have a url" do
      Feed.keys.keys.must_include "url"
    end

    it "should have a uid" do
      Feed.keys.keys.must_include "uid"
    end

    it "should have categories" do
      Feed.keys.keys.must_include "categories"
    end

    it "should default categories to []" do
      Feed.new.categories.must_equal []
    end

    it "should have a rights field" do
      Feed.keys.keys.must_include "rights"
    end

    it "should have a title" do
      Feed.keys.keys.must_include "title"
    end

    it "should have a title_type" do
      Feed.keys.keys.must_include "title_type"
    end

    it "should have a subtitle" do
      Feed.keys.keys.must_include "subtitle"
    end

    it "should have a subtitle_type" do
      Feed.keys.keys.must_include "subtitle_type"
    end

    it "should have contributors_ids" do
      Feed.keys.keys.must_include "contributors_ids"
    end

    it "should have authors_ids" do
      Feed.keys.keys.must_include "authors_ids"
    end

    it "should have entries_ids" do
      Feed.keys.keys.must_include "entries_ids"
    end

    it "should have a generator" do
      Feed.keys.keys.must_include "generator"
    end

    it "should have a created_at" do
      Feed.keys.keys.must_include "created_at"
    end

    it "should have a updated_at" do
      Feed.keys.keys.must_include "updated_at"
    end
  end

  describe "find_or_create_by_uid!" do
    it "should return the existing Feed" do
      feed = Feed.create!(:uid => "UID")

      Feed.find_or_create_by_uid!(:uid => "UID").id.must_equal feed.id
    end

    it "should return the existing Feed via Lotus::Feed" do
      feed = Feed.create!(:uid => "UID")

      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:id).returns("UID")

      Feed.find_or_create_by_uid!(lotus_feed).id.must_equal feed.id
    end

    it "should create when the Feed is not found" do
      Feed.expects(:create!).with({:uid => "UID"})
      Feed.find_or_create_by_uid!(:uid => "UID")
    end

    it "should create via Lotus::Feed when the Feed is not found" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:id).returns("UID")

      Feed.expects(:create!).with(lotus_feed)
      Feed.find_or_create_by_uid!(lotus_feed)
    end

    it "should account for race condition where entry was created after find" do
      Feed.stubs(:first).returns(nil).then.returns("feed")
      Feed.stubs(:create!).raises("")
      Feed.find_or_create_by_uid!(:uid => "UID").must_equal "feed"
    end
  end

  describe "#initialize" do
    it "should allow a Lotus::Feed" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:to_hash).returns({:id => "UID",
                                          :authors => [],
                                          :contributors => [],
                                          :entries => []})

      Feed.new(lotus_feed).uid.must_equal "UID"
    end

    it "should find or create Authors for those given in Lotus::Feed" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:to_hash).returns({:id => "UID",
                                          :authors => [{:uid => "author UID",
                                                        :url => "author URL"}],
                                          :contributors => [],
                                          :entries => []})

      author = Author.new
      Author.expects(:find_or_create_by_uid!).returns(author)

      Feed.new(lotus_feed)
    end

    it "should find or create Authors for contributors given in Lotus::Feed" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:to_hash).returns({:id => "UID",
                                          :contributors => [
                                            {:uid => "author UID",
                                             :url => "author URL"}],
                                          :authors => [],
                                          :entries => []})

      author = Author.new
      Author.expects(:find_or_create_by_uid!).returns(author)

      Feed.new(lotus_feed)
    end

    it "should find or create Authors for contributors given in Lotus::Feed" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:to_hash).returns({:id => "UID",
                                          :contributors => [],
                                          :authors => [],
                                          :entries => [{:uid => "UID",
                                                        :url => "URL"}]})

      activity = Activity.new
      Activity.expects(:find_or_create_by_uid!).returns(activity)

      Feed.new(lotus_feed)
    end
  end

  describe "discover!" do
    it "should use Lotus to discover the feed given by the url" do
      Lotus.expects(:discover_feed).with("feed_url")
      Feed.discover!("feed_url")
    end

    it "should return false when the feed cannot be discovered" do
      Lotus.stubs(:discover_feed).returns(nil)
      Feed.discover!("feed_url").must_equal false
    end

    it "should create a new feed when the discovered feed does not exist" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:id).returns("UID")
      Lotus.stubs(:discover_feed).returns(lotus_feed)

      Feed.expects(:create!).with(lotus_feed)
      Feed.discover!("feed_url")
    end

    it "should return a known feed when url matches given" do
      feed = Feed.new
      Feed.stubs(:first).with(has_entry(:url, "feed_url")).returns(feed)

      Feed.discover!("feed_url").must_equal feed
    end

    it "should return a known feed when uids match" do
      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:id).returns("UID")
      Lotus.stubs(:discover_feed).returns(lotus_feed)

      feed = Feed.new
      Feed.stubs(:first).with(has_entry(:url, "feed_url")).returns(nil)
      Feed.stubs(:first).with(has_entry(:uid, "UID")).returns(feed)
      Lotus.stubs(:discover_feed).returns(lotus_feed)

      Feed.discover!("feed_url").must_equal feed
    end
  end

  describe "#post!" do
    it "should allow a Hash to be given" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.stubs(:save)

      hash = {}
      Activity.expects(:create!).with(hash).returns(activity)

      feed.post! hash
    end

    it "should allow a Lotus::Activity to be given" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.stubs(:save)

      lotus_activity = Lotus::Activity.new
      Activity.expects(:create!).with(lotus_activity).returns(activity)

      feed.post! lotus_activity
    end

    it "should save the association to this feed" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.expects(:feed_id=).with(feed.id)
      activity.expects(:save)

      feed.post! activity
    end

    it "should add the activity to the entries" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.stubs(:save)

      feed.post! activity

      feed.entries_ids.must_include activity.id
    end

    it "should save" do
      feed = Feed.new

      activity = Activity.new
      activity.stubs(:save)

      feed.expects(:save)

      feed.post! activity
    end
  end

  describe "#repost!" do
    it "should simply add the activity to entries" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.stubs(:save)

      feed.repost! activity

      feed.entries_ids.must_include activity.id
    end

    it "should save" do
      feed = Feed.new

      activity = Activity.new
      activity.stubs(:save)

      feed.expects(:save)

      feed.repost! activity
    end
  end

  describe "#delete!" do
    it "should remove the given activity from entries" do
      feed = Feed.new
      feed.stubs(:save)

      activity = Activity.new
      activity.stubs(:save)

      feed.entries << activity

      feed.delete! activity
      feed.entries_ids.wont_include activity.id
    end

    it "should save" do
      feed = Feed.new

      activity = Activity.new
      activity.stubs(:save)

      feed.entries << activity

      feed.expects(:save)
      feed.delete! activity
    end
  end

  describe "#merge!" do
    it "should update base attributes" do
      feed = Feed.new
      feed.stubs(:save)
      feed.stubs(:save!)

      lotus_feed = Lotus::Feed.new
      lotus_feed.stubs(:authors).returns([])
      lotus_feed.stubs(:contributors).returns([])
      lotus_feed.stubs(:entries).returns([])
      lotus_feed.stubs(:to_hash).returns({:rights => "NEW RIGHTS",
                                          :url => "NEW URL",
                                          :subtitle => "NEW SUBTITLE"})

      feed.merge! lotus_feed

      feed.subtitle.must_equal "NEW SUBTITLE"
    end
  end

  describe "#ordered" do
    it "should return a query for the entries in descending order" do
      feed = Feed.new
      feed.stubs(:save)
      feed.entries_ids = ["id1", "id2"]

      query = stub('Plucky')
      query.expects(:order)
        .with(has_entry(:created_at, :desc))
        .returns("ordered")

      Activity
        .expects(:where)
        .with(has_entry(:id, ["id1", "id2"]))
        .returns(query)

      feed.ordered.must_equal "ordered"
    end
  end
end
