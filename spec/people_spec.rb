require_relative 'helper'
require_controller 'people'

class  Lotus::Author;   end
class  Lotus::Person;   end
class  Lotus::Activity; end
class  Identity; end
module Lotus;
  class Notification; end
  class Lotus::Activity; end
end

describe Rack::Lotus do
  before do
    # Do not render
    Rack::Lotus.any_instance.stubs(:render).returns("html")
  end

  describe "People Controller" do
    describe "GET /people" do
      it "should query for all people" do
        Lotus::Person.expects(:all)

        get '/people'
      end

      it "should pass an array of people to renderer" do
        Lotus::Person.stubs(:all).returns("persons")
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_entry(:locals, {:people => "persons"})
        )

        get '/people'
      end

      it "should render people/index" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/index",
                                                       anything)

        get '/people'
      end
    end

    describe "GET /people/:id" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:activities).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("timeline")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd'
      end

      it "should pass an array of entries from their timeline to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:timeline => "timeline")
        )

        get '/people/1234abcd'
      end

      it "should render people/show" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/show",
                                                       anything)

        get '/people/1234abcd'
      end
    end

    describe "GET /people/:id/replies" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:replies).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("replies")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/replies'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/replies'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/replies'
      end

      it "should pass an array of entries from their replies to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:replies => "replies")
        )

        get '/people/1234abcd/replies'
      end

      it "should render people/replies" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/replies",
                                                       anything)

        get '/people/1234abcd/replies'
      end
    end

    describe "GET /people/:id/mentions" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:mentions).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("mentions")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/mentions'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/mentions'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/mentions'
      end

      it "should pass an array of entries from their mentions to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:mentions => "mentions")
        )

        get '/people/1234abcd/mentions'
      end

      it "should render people/mentions" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/mentions",
                                                       anything)

        get '/people/1234abcd/mentions'
      end
    end

    describe "GET /people/:id/timeline" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:timeline).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("timeline")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/timeline'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/timeline'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/timeline'
      end

      it "should pass an array of entries from their timeline to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:timeline => "timeline")
        )

        get '/people/1234abcd/timeline'
      end

      it "should render people/timeline" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/timeline",
                                                       anything)

        get '/people/1234abcd/timeline'
      end
    end

    describe "GET /people/:id/activities" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:activities).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("activities")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/activities'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/activities'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/activities'
      end

      it "should pass an array of entries from their activities to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:activities => "activities")
        )

        get '/people/1234abcd/activities'
      end

      it "should render people/activities" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/activities",
                                                       anything)

        get '/people/1234abcd/activities'
      end
    end

    describe "GET /people/:id/favorites" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:favorites).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("favorites")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/favorites'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/favorites'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/favorites'
      end

      it "should pass an array of entries from their favorites to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:favorites => "favorites")
        )

        get '/people/1234abcd/favorites'
      end

      it "should render people/favorites" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/favorites",
                                                       anything)

        get '/people/1234abcd/favorites'
      end
    end

    describe "GET /people/:id/shared" do
      before do
        @person = stub('Person')
        aggregate = stub('Aggregate')
        feed = stub('Feed')

        @person.stubs(:shared).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)
        feed.stubs(:ordered).returns("shared")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/shared'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/shared'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/shared'
      end

      it "should pass an array of entries from their shares to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:shared => "shared")
        )

        get '/people/1234abcd/shared'
      end

      it "should render people/shared" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/shared",
                                                       anything)

        get '/people/1234abcd/shared'
      end
    end

    describe "GET /people/:id/following" do
      before do
        @person = stub('Person')
        @person.stubs(:following).returns("following")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/following'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/following'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/following'
      end

      it "should pass an array of people they follow to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:following => "following")
        )

        get '/people/1234abcd/following'
      end

      it "should render people/following" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/following",
                                                       anything)

        get '/people/1234abcd/following'
      end
    end

    describe "GET /people/:id/followers" do
      before do
        @person = stub('Person')
        @person.stubs(:followers).returns("followers")

        Lotus::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/followers'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/followers'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/followers'
      end

      it "should pass an array of people that follow them to renderer" do
        Rack::Lotus.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:followers => "followers")
        )

        get '/people/1234abcd/followers'
      end

      it "should render people/followers" do
        Lotus::Person.stubs(:all)
        Rack::Lotus.any_instance.expects(:render).with(anything,
                                                       :"people/followers",
                                                       anything)

        get '/people/1234abcd/followers'
      end
    end

    describe "POST /people/:id/shared" do
      it "should return 404 if nobody is logged in" do
        post '/people/current_person/shared'
        last_response.status.must_equal 404
      end

      it "should return 404 if different person is logged in" do
        login_as "wilkie"

        post '/people/asdf/shared'
        last_response.status.must_equal 404
      end

      it "should return 404 if activity doesn't exist" do
        login_as "wilkie"

        post '/people/asdf/shared'
        last_response.status.must_equal 404
      end

      it "should look up the activity from the given activity_id parameter" do
        login_as "wilkie"

        Lotus::Activity.expects(:find_by_id).with("foo")

        post '/people/current_person/shared', "activity_id" => "foo"
      end

      it "should redirect if the person is found" do
        person = login_as "wilkie"
        person.stubs(:share!)

        Lotus::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/shared'
        last_response.status.must_equal 302
      end

      it "should redirect to home if the person is found" do
        person = login_as "wilkie"
        person.stubs(:share!)

        Lotus::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/shared'
        last_response.location.must_equal "http://example.org/"
      end

      it "should share the given activity" do
        person = login_as "wilkie"

        Lotus::Activity.stubs(:find_by_id).returns("something")

        person.expects(:share!).with("something")

        post '/people/current_person/shared'
      end
    end

    describe "POST /people/:id/favorites" do
      it "should return 404 if nobody is logged in" do
        post '/people/current_person/favorites'
        last_response.status.must_equal 404
      end

      it "should return 404 if different person is logged in" do
        login_as "wilkie"

        post '/people/asdf/favorites'
        last_response.status.must_equal 404
      end

      it "should return 404 if activity doesn't exist" do
        login_as "wilkie"

        post '/people/asdf/favorites'
        last_response.status.must_equal 404
      end

      it "should look up the activity from the given activity_id parameter" do
        login_as "wilkie"

        Lotus::Activity.expects(:find_by_id).with("foo")

        post '/people/current_person/favorites', "activity_id" => "foo"
      end

      it "should redirect if the person is found" do
        person = login_as "wilkie"
        person.stubs(:favorite!)

        Lotus::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/favorites'
        last_response.status.must_equal 302
        last_response.location.must_equal "http://example.org/"
      end

      it "should redirect home if the person is found" do
        person = login_as "wilkie"
        person.stubs(:favorite!)

        Lotus::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/favorites'
        last_response.location.must_equal "http://example.org/"
      end

      it "should favorite the given activity" do
        person = login_as "wilkie"

        Lotus::Activity.stubs(:find_by_id).returns("something")

        person.expects(:favorite!).with("something")

        post '/people/current_person/favorites'
      end
    end

    describe "POST /people/:id/following" do
      it "should return 404 if nobody is logged in" do
        post '/people/current_person/following'
        last_response.status.must_equal 404
      end

      it "should return 404 if different person is logged in" do
        login_as "wilkie"

        post '/people/asdf/following'
        last_response.status.must_equal 404
      end

      it "should allow an author_id for known authors" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Lotus::Author.expects(:find_by_id).with("foobar")
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should allow an unknown author in discover parameter" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Lotus::Author.expects(:discover!).with("foobar")
        post '/people/current_person/following', "discover" => "foobar"
      end

      it "should return 404 when no parameters are given" do
        person = login_as "wilkie"

        post '/people/current_person/following'
        last_response.status.must_equal 404
      end

      it "should not follow anybody if no parameters are given" do
        person = login_as "wilkie"
        person.expects(:follow!).never

        post '/people/current_person/following'
      end

      it "should return 404 if the author given by author_id does not exist" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Lotus::Author.stubs(:find_by_id)
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.status.must_equal 404
      end

      it "should not follow an author if not found via author_id" do
        person = login_as "wilkie"
        person.expects(:follow!).never

        Lotus::Author.stubs(:find_by_id)
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should return 404 if the author given by discover does not exist" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Lotus::Author.stubs(:discover!)
        post '/people/current_person/following', "discover" => "foobar"
        last_response.status.must_equal 404
      end

      it "should not follow an author if not found via discover" do
        person = login_as "wilkie"
        person.expects(:follow!).never

        Lotus::Author.stubs(:discover!)
        post '/people/current_person/following', "discover" => "foobar"
      end

      it "should follow a known author via author_id" do
        person = login_as "wilkie"
        person.expects(:follow!).with("somebody")

        Lotus::Author.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should follow an author via discover" do
        person = login_as "wilkie"
        person.expects(:follow!).with("somebody")

        Lotus::Author.stubs(:discover!).returns("somebody")
        post '/people/current_person/following', "discover" => "someone"
      end

      it "should redirect with a known author via author_id" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Lotus::Author.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.status.must_equal 302
      end

      it "should redirect home with a known author via author_id" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Lotus::Author.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.location.must_equal "http://example.org/"
      end

      it "should redirect with an author via discover" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Lotus::Author.stubs(:discover!).returns("somebody")
        post '/people/current_person/following', "discover" => "someone"
        last_response.status.must_equal 302
      end

      it "should redirect home with an author via discover" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Lotus::Author.stubs(:discover!).returns("somebody")
        post '/people/current_person/following', "discover" => "someone"
        last_response.location.must_equal "http://example.org/"
      end
    end

    describe "POST /people/:id/activities" do
      it "should return 404 if nobody is logged in" do
        post '/people/current_person/activities'
        last_response.status.must_equal 404
      end

      it "should return 404 if different person is logged in" do
        login_as "wilkie"

        post '/people/asdf/activities'
        last_response.status.must_equal 404
      end

      it "should post an activitiy" do
        person = login_as "wilkie"
        person.expects(:post!)

        post '/people/current_person/activities'
      end

      it "should redirect when it posts an activity" do
        person = login_as "wilkie"
        person.stubs(:post!)

        post '/people/current_person/activities'
        last_response.status.must_equal 302
      end

      it "should redirect home when it posts an activity" do
        person = login_as "wilkie"
        person.stubs(:post!)

        post '/people/current_person/activities'
        last_response.location.must_equal "http://example.org/"
      end

      it "should pass along the type when given" do
        person = login_as "wilkie"
        person.expects(:post!).with(has_entry(:type, "thing"))

        post '/people/current_person/activities', "type" => "thing"
      end

      it "should pass along the created object" do
        person = login_as "wilkie"
        obj = mock('Lotus::Note')
        Lotus::Note.stubs(:new)
                   .with(has_entry(:text, "my words"))
                   .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "note",
                                                  "content" => "my words"
      end

      it "should create a Lotus::Article for article types" do
        person = login_as "wilkie"
        obj = mock('Lotus::Note')
        Lotus::Article.stubs(:new)
                      .with(has_entry(:content, "my words"))
                      .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "article",
                                                  "content" => "my words"
      end

      it "should create a Lotus::Note for note types" do
        person = login_as "wilkie"
        obj = mock('Lotus::Note')
        Lotus::Note.stubs(:new)
                   .with(has_entry(:text, "my words"))
                   .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "note",
                                                  "content" => "my words"
      end

      it "should pass along the correct author" do
        person = login_as "wilkie"
        person.expects(:post!).with(has_entry(:actor, person.author))

        post '/people/current_person/activities'
      end

      it "should set the verb to post" do
        person = login_as "wilkie"
        person.expects(:post!).with(has_entry(:verb, :post))

        post '/people/current_person/activities'
      end
    end

    describe "POST /people/:id/salmon" do
      before do
        @person = mock('Person')
        aggregate = mock('Aggregate')
        feed = mock('Feed')

        @person.stubs(:activities).returns(aggregate)
        aggregate.stubs(:feed).returns(feed)

        @person.stubs(:followed_by!)
        @person.stubs(:unfollowed_by!)

        Lotus::Person.stubs(:find_by_id).returns(@person)

        activity = Lotus::Activity.new
        activity.stubs(:verb).returns(:follow)
        activity.stubs(:id).returns("ID")

        @internal_activity = Lotus::Activity.new
        @internal_activity.stubs(:verb).returns(:follow)
        @internal_activity.stubs(:url).returns("http://example.com/activities/1")
        Lotus::Activity.stubs(:create!).returns(@internal_activity)
        Lotus::Activity.stubs(:find_by_uid).returns(nil)
        Lotus::Activity.stubs(:find_from_notification).returns(nil)
        Lotus::Activity.stubs(:create_from_notification!).returns(@internal_activity)

        author = Lotus::Author.new

        identity = Identity.new
        identity.stubs(:return_or_discover_public_key).returns("RSA_PUBLIC_KEY")
        identity.stubs(:discover_author!)
        identity.stubs(:author).returns(author)

        Lotus::Notification.stubs(:from_xml).returns(@notification)
      end

      it "should return 404 if the person is not found" do
        Lotus::Person.stubs(:find_by_id).returns(nil)

        post '/people/bogus/salmon'
        last_response.status.must_equal 404
      end

      it "should return 403 if the person exists and message is not updated" do
        Lotus::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.stubs(:update_from_notification!).returns(nil)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 403
      end

      it "should update if the person is found and verified" do
        Lotus::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.expects(:update_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
      end

      it "should return 200 if the person is found and message is updated" do
        Lotus::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.stubs(:update_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 200
      end

      it "should create if the person is found and verified" do
        Lotus::Activity.expects(:create_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
      end

      it "should return 202 if the person is found and message is verified" do
        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 202
      end

      it "should return 400 when reciprient is found but the access is rejected" do
        Lotus::Activity.stubs(:create_from_notification!).returns(nil)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 400
      end

      it "should return a Location HTTP header with the activity url" do
        post '/people/1234abcd/salmon', "foo"
        last_response.headers["Location"].must_equal @internal_activity.url
      end

      it "should handle the given payload" do
        Lotus::Notification.expects(:from_xml)
                           .with("foo")
                           .returns(@notification)

        post '/people/1234abcd/salmon', "foo"
      end
    end
  end
end
