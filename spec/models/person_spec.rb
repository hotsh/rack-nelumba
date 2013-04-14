require_relative 'helper'
require_model 'person'

describe Person do
  describe "Schema" do
    it "should have an authorization id" do
      Person.attributes.keys.must_include :authorization_id
    end

    it "should have an author id" do
      Person.attributes.keys.must_include :author_id
    end

    it "should have an activities id" do
      Person.attributes.keys.must_include :activities_id
    end

    it "should have a timeline id" do
      Person.attributes.keys.must_include :timeline_id
    end

    it "should have a favorites id" do
      Person.attributes.keys.must_include :favorites_id
    end

    it "should have a shared id" do
      Person.attributes.keys.must_include :shared_id
    end

    it "should have a replies id" do
      Person.attributes.keys.must_include :replies_id
    end

    it "should have a mentions id" do
      Person.attributes.keys.must_include :mentions_id
    end

    it "should have a following_ids array" do
      Person.attributes.keys.must_include :following_ids
    end

    it "should have a followers_ids array" do
      Person.attributes.keys.must_include :followers_ids
    end
  end

  describe "#create" do
    it "should create an author upon creation" do
      author = stub('Author')
      Author.stubs(:create).returns(author)
      Person.any_instance.expects(:author=).with(author)

      Person.create
    end

    it "should create an activities aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:activities=).with(aggregate)

      Person.create
    end

    it "should create a timeline aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:timeline=).with(aggregate)

      Person.create
    end

    it "should create a shared aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:shared=).with(aggregate)

      Person.create
    end

    it "should create a favorites aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:favorites=).with(aggregate)

      Person.create
    end

    it "should create a replies aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:replies=).with(aggregate)

      Person.create
    end

    it "should create a mentions aggregate upon creation" do
      aggregate = stub('Aggregate')
      aggregate.stubs(:id)
      Aggregate.stubs(:create).returns(aggregate)
      Person.any_instance.expects(:mentions=).with(aggregate)

      Person.create
    end
  end

  describe "#follow!" do
    it "should add the given Author to the following list" do
      person = Person.create
      author = Author.create
      identity = Identity.create(:outbox_id => Aggregate.create.id,
                                 :author_id => author.id)

      person.follow! author
      person.following_ids.must_include author.id
    end
  end

  describe "#unfollow!" do
    it "should remove the given Author from the following list" do
      person = Person.create
      author = Author.create
      identity = Identity.create(:outbox_id => Aggregate.create.id,
                                 :author_id => author.id)

      person.follow! author
      person.unfollow! author

      person.following_ids.wont_include author.id
    end
  end

  describe "#followed_by!" do
    it "should add the given Author to our followers list" do
      person = Person.create
      author = Author.create
      identity = Identity.create(:outbox_id => Aggregate.create.id,
                                 :author_id => author.id)

      person.followed_by! author
      person.followers_ids.must_include author.id
    end
  end

  describe "#unfollowed_by!" do
    it "should add the given Author to our followers list" do
      person = Person.create
      author = Author.create
      identity = Identity.create(:outbox_id => Aggregate.create.id,
                                 :author_id => author.id)

      person.unfollowed_by! author
      person.followers_ids.wont_include author.id
    end
  end

  describe "#favorite!" do
    it "should repost the given activity to our favorites aggregate" do
      person = Person.create
      activity = Activity.create

      person.favorites.expects(:repost!).with(activity)
      person.favorite! activity
    end

    it "should post an activity to our activities with favorite verb" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!).with(has_entry(:verb, :favorite))
      person.favorite! activity
    end

    it "should post an activity to our activities with our author as actor" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!)
        .with(has_entries(:actor_id   => person.author.id,
                          :actor_type => 'Author'))

      person.favorite! activity
    end

    it "should post an activity to our activities with favorited activity" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!)
        .with(has_entries(:object_uid  => activity.id,
                          :object_type => 'Activity'))

      person.favorite! activity
    end
  end

  describe "#unfavorite!" do
    it "should delete the activity from the favorites aggregate" do
      person = Person.create
      activity = Activity.create

      person.favorites.expects(:delete!).with(activity)
      person.unfavorite! activity
    end

    it "should post an activity to our activities with unfavorite verb" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!).with(has_entry(:verb, :unfavorite))
      person.unfavorite! activity
    end

    it "should post an activity to our activities with our author as actor" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!)
        .with(has_entries(:actor_id   => person.author.id,
                          :actor_type => 'Author'))

      person.unfavorite! activity
    end

    it "should post an activity to our activities with favorited activity" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!)
        .with(has_entries(:object_uid  => activity.id,
                          :object_type => 'Activity'))

      person.unfavorite! activity
    end
  end

  describe "#mentioned_by!" do
    it "should repost the activity to our mentions aggregate" do
      person = Person.create
      activity = Activity.create

      person.mentions.expects(:repost!).with(activity)
      person.mentioned_by! activity
    end
  end

  describe "#replied_by!" do
    it "should repost the activity to our replies aggregate" do
      person = Person.create
      activity = Activity.create

      person.replies.expects(:repost!).with(activity)
      person.replied_by! activity
    end
  end

  describe "#post!" do
    it "should post the activity to our activities aggregate" do
      person = Person.create
      activity = Activity.create

      person.activities.expects(:post!).with(activity)
      person.post! activity
    end

    it "should repost the activity to our timeline" do
      person = Person.create
      activity = Activity.create

      person.timeline.expects(:repost!).with(activity)
      person.post! activity
    end

    it "should create an activity if passed a hash" do
      person = Person.create
      activity = {:content => "Hello"}

      Activity.expects(:create!).with(activity).returns(
        Activity.create(activity))
      person.post! activity
    end
  end

  describe "#share!" do
    it "should repost the activity to our timeline aggregate" do
      person = Person.create
      activity = Activity.create

      person.timeline.expects(:repost!).with(activity)
      person.share! activity
    end

    it "should repost the activity to our shared aggregate" do
      person = Person.create
      activity = Activity.create

      person.shared.expects(:repost!).with(activity)
      person.share! activity
    end
  end
end
