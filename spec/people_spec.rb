require_relative 'helper'
require_controller 'people'

class  Nelumba::Person;   end
class  Nelumba::Person;   end
class  Nelumba::Activity; end
class  Identity; end
module Nelumba;
  class Notification; end
  class Nelumba::Activity; end
end

describe Rack::Nelumba do
  before do
    # Do not render
    Rack::Nelumba.any_instance.stubs(:render).returns("html")
  end

  describe "People Controller" do
    describe "GET /people" do
      it "should query for all people" do
        Nelumba::Person.expects(:all)

        get '/people'
      end

      it "should pass an array of people to renderer" do
        Nelumba::Person.stubs(:all).returns("persons")
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_entry(:locals, {:people => "persons"})
        )

        get '/people'
      end

      it "should render people/index" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/index",
                                                       anything)

        get '/people'
      end
    end

    describe "GET /people/:id" do
      before do
        auth = stub('Authorization')
        @person = stub('Person')
        feed = stub('Feed')

        auth.stubs(:username).returns("foobar")
        feed.stubs(:ordered).returns("timeline")
        @person.stubs(:activities).returns(feed)
        @person.stubs(:id).returns("1234abcd")
        @person.stubs(:authorization).returns(auth)

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should contain an HTTP Link header that points to the XRD" do
        get '/people/1234abcd'
        last_response.headers["Link"].must_match /^<\/api\/lrdd\/foobar>; rel="lrdd"; type="application\/xrd\+xml"$/
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd'
      end

      it "should pass an array of links to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local_of_type(:links => Array)
        )

        get '/people/1234abcd'
      end

      it "should pass an json alternative link to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local_includes(:links, {:rel => 'alternate',
                                      :type => 'application/json',
                                      :href => '/people/1234abcd/activities'})
        )

        get '/people/1234abcd'
      end

      it "should pass an xml alternative link to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local_includes(:links, {:rel => 'alternate',
                                      :type => 'application/atom+xml',
                                      :href => '/people/1234abcd/activities'})
        )

        get '/people/1234abcd'
      end

      it "should pass an array of entries from their timeline to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:timeline => "timeline")
        )

        get '/people/1234abcd'
      end

      it "should render people/show" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/show",
                                                       anything)

        get '/people/1234abcd'
      end
    end

    describe "GET /people/:id/replies" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:replies).returns(feed)
        @person.stubs(:id).returns("1234abcd")
        feed.stubs(:ordered).returns("replies")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/replies'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/replies'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/replies'
      end

      it "should pass an array of entries from their replies to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:replies => "replies")
        )

        get '/people/1234abcd/replies'
      end

      it "should render people/replies" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/replies",
                                                       anything)

        get '/people/1234abcd/replies'
      end
    end

    describe "GET /people/:id/mentions" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:mentions).returns(feed)
        feed.stubs(:ordered).returns("mentions")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/mentions'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/mentions'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/mentions'
      end

      it "should pass an array of entries from their mentions to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:mentions => "mentions")
        )

        get '/people/1234abcd/mentions'
      end

      it "should render people/mentions" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/mentions",
                                                       anything)

        get '/people/1234abcd/mentions'
      end
    end

    describe "GET /people/:id/timeline" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:timeline).returns(feed)
        feed.stubs(:ordered).returns("timeline")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/timeline'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/timeline'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/timeline'
      end

      it "should pass an array of entries from their timeline to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:timeline => "timeline")
        )

        get '/people/1234abcd/timeline'
      end

      it "should render people/timeline" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/timeline",
                                                       anything)

        get '/people/1234abcd/timeline'
      end
    end

    describe "GET /people/:id/activities" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:activities).returns(feed)
        feed.stubs(:ordered).returns("activities")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/activities'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/activities'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/activities'
      end

      it "should pass an array of entries from their activities to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:activities => "activities")
        )

        get '/people/1234abcd/activities'
      end

      it "should render people/activities" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/activities",
                                                       anything)

        get '/people/1234abcd/activities'
      end
    end

    describe "GET /people/:id/favorites" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:favorites).returns(feed)
        feed.stubs(:ordered).returns("favorites")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/favorites'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/favorites'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/favorites'
      end

      it "should pass an array of entries from their favorites to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:favorites => "favorites")
        )

        get '/people/1234abcd/favorites'
      end

      it "should render people/favorites" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/favorites",
                                                       anything)

        get '/people/1234abcd/favorites'
      end
    end

    describe "GET /people/:id/shared" do
      before do
        @person = stub('Person')
        feed = stub('Feed')

        @person.stubs(:shared).returns(feed)
        feed.stubs(:ordered).returns("shared")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/shared'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/shared'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/shared'
      end

      it "should pass an array of entries from their shares to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:shared => "shared")
        )

        get '/people/1234abcd/shared'
      end

      it "should render people/shared" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/shared",
                                                       anything)

        get '/people/1234abcd/shared'
      end
    end

    describe "GET /people/:id/following" do
      before do
        @person = stub('Person')
        @person.stubs(:following).returns("following")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/following'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/following'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/following'
      end

      it "should pass an array of people they follow to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:following => "following")
        )

        get '/people/1234abcd/following'
      end

      it "should render people/following" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"people/following",
                                                       anything)

        get '/people/1234abcd/following'
      end
    end

    describe "GET /people/:id/followers" do
      before do
        @person = stub('Person')
        @person.stubs(:followers).returns("followers")

        Nelumba::Person.stubs(:find_by_id).returns(@person)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/followers'
        last_response.status.must_equal 404
      end

      it "should return 200 if the person is found" do
        get '/people/1234abcd/followers'
        last_response.status.must_equal 200
      end

      it "should pass person to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:person => @person)
        )

        get '/people/1234abcd/followers'
      end

      it "should pass an array of people that follow them to renderer" do
        Rack::Nelumba.any_instance.expects(:render).with(
          anything,
          anything,
          has_local(:followers => "followers")
        )

        get '/people/1234abcd/followers'
      end

      it "should render people/followers" do
        Nelumba::Person.stubs(:all)
        Rack::Nelumba.any_instance.expects(:render).with(anything,
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

        Nelumba::Activity.expects(:find_by_id).with("foo")

        post '/people/current_person/shared', "activity_id" => "foo"
      end

      it "should redirect if the person is found" do
        person = login_as "wilkie"
        person.stubs(:share!)

        Nelumba::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/shared'
        last_response.status.must_equal 302
      end

      it "should redirect to home if the person is found" do
        person = login_as "wilkie"
        person.stubs(:share!)

        Nelumba::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/shared'
        last_response.location.must_equal "http://example.org/"
      end

      it "should share the given activity" do
        person = login_as "wilkie"

        Nelumba::Activity.stubs(:find_by_id).returns("something")

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

        Nelumba::Activity.expects(:find_by_id).with("foo")

        post '/people/current_person/favorites', "activity_id" => "foo"
      end

      it "should redirect if the person is found" do
        person = login_as "wilkie"
        person.stubs(:favorite!)

        Nelumba::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/favorites'
        last_response.status.must_equal 302
        last_response.location.must_equal "http://example.org/"
      end

      it "should redirect home if the person is found" do
        person = login_as "wilkie"
        person.stubs(:favorite!)

        Nelumba::Activity.stubs(:find_by_id).returns("something")

        post '/people/current_person/favorites'
        last_response.location.must_equal "http://example.org/"
      end

      it "should favorite the given activity" do
        person = login_as "wilkie"

        Nelumba::Activity.stubs(:find_by_id).returns("something")

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

      it "should allow an author_id for known people" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Nelumba::Person.expects(:find_by_id).with("foobar")
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should allow an unknown author in discover parameter" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Nelumba::Person.expects(:discover!).with("foobar")
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

        Nelumba::Person.stubs(:find_by_id)
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.status.must_equal 404
      end

      it "should not follow an author if not found via author_id" do
        person = login_as "wilkie"
        person.expects(:follow!).never

        Nelumba::Person.stubs(:find_by_id)
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should return 404 if the author given by discover does not exist" do
        person = login_as "wilkie"
        person.stubs(:follow!)

        Nelumba::Person.stubs(:discover!)
        post '/people/current_person/following', "discover" => "foobar"
        last_response.status.must_equal 404
      end

      it "should not follow an author if not found via discover" do
        person = login_as "wilkie"
        person.expects(:follow!).never

        Nelumba::Person.stubs(:discover!)
        post '/people/current_person/following', "discover" => "foobar"
      end

      it "should follow a known author via author_id" do
        person = login_as "wilkie"
        person.expects(:follow!).with("somebody")

        Nelumba::Person.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
      end

      it "should follow an author via discover" do
        person = login_as "wilkie"
        person.expects(:follow!).with("somebody")

        Nelumba::Person.stubs(:discover!).returns("somebody")
        post '/people/current_person/following', "discover" => "someone"
      end

      it "should redirect with a known author via author_id" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Nelumba::Person.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.status.must_equal 302
      end

      it "should redirect home with a known author via author_id" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Nelumba::Person.stubs(:find_by_id).returns("somebody")
        post '/people/current_person/following', "author_id" => "foobar"
        last_response.location.must_equal "http://example.org/"
      end

      it "should redirect with an author via discover" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Nelumba::Person.stubs(:discover!).returns("somebody")
        post '/people/current_person/following', "discover" => "someone"
        last_response.status.must_equal 302
      end

      it "should redirect home with an author via discover" do
        person = login_as "wilkie"
        person.stubs(:follow!).with("somebody")

        Nelumba::Person.stubs(:discover!).returns("somebody")
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
        obj = mock('Nelumba::Note')
        Nelumba::Note.stubs(:new)
                   .with(has_entry(:text, "my words"))
                   .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "note",
                                                  "content" => "my words"
      end

      it "should create a Nelumba::Article for article types" do
        person = login_as "wilkie"
        obj = mock('Nelumba::Note')
        Nelumba::Article.stubs(:new)
                      .with(has_entry(:content, "my words"))
                      .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "article",
                                                  "content" => "my words"
      end

      it "should create a Nelumba::Note for note types" do
        person = login_as "wilkie"
        obj = mock('Nelumba::Note')
        Nelumba::Note.stubs(:new)
                   .with(has_entry(:text, "my words"))
                   .returns(obj)
        person.expects(:post!).with(has_entry(:object, obj))

        post '/people/current_person/activities', "type"    => "note",
                                                  "content" => "my words"
      end

      it "should pass along the correct author" do
        person = login_as "wilkie"
        person.expects(:post!).with(has_entry(:actor, person))

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
        feed = mock('Feed')

        @person.stubs(:activities).returns(feed)

        @person.stubs(:followed_by!)
        @person.stubs(:unfollowed_by!)

        Nelumba::Person.stubs(:find_by_id).returns(@person)

        activity = Nelumba::Activity.new
        activity.stubs(:verb).returns(:follow)
        activity.stubs(:id).returns("ID")

        @internal_activity = Nelumba::Activity.new
        @internal_activity.stubs(:verb).returns(:follow)
        @internal_activity.stubs(:url).returns("http://example.com/activities/1")
        Nelumba::Activity.stubs(:create!).returns(@internal_activity)
        Nelumba::Activity.stubs(:find_by_uid).returns(nil)
        Nelumba::Activity.stubs(:find_from_notification).returns(nil)
        Nelumba::Activity.stubs(:create_from_notification!).returns(@internal_activity)

        author = Nelumba::Person.new

        identity = Identity.new
        identity.stubs(:return_or_discover_public_key).returns("RSA_PUBLIC_KEY")
        identity.stubs(:discover_author!)
        identity.stubs(:author).returns(author)

        Nelumba::Notification.stubs(:from_xml).returns(@notification)
      end

      it "should return 404 if the person is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        post '/people/bogus/salmon'
        last_response.status.must_equal 404
      end

      it "should return 403 if the person exists and message is not updated" do
        Nelumba::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.stubs(:update_from_notification!).returns(nil)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 403
      end

      it "should update if the person is found and verified" do
        Nelumba::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.expects(:update_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
      end

      it "should return 200 if the person is found and message is updated" do
        Nelumba::Activity.stubs(:find_from_notification).returns(@internal_activity)
        @internal_activity.stubs(:update_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 200
      end

      it "should create if the person is found and verified" do
        Nelumba::Activity.expects(:create_from_notification!).returns(@internal_activity)

        post '/people/1234abcd/salmon', "foo"
      end

      it "should return 202 if the person is found and message is verified" do
        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 202
      end

      it "should return 400 when reciprient is found but the access is rejected" do
        Nelumba::Activity.stubs(:create_from_notification!).returns(nil)

        post '/people/1234abcd/salmon', "foo"
        last_response.status.must_equal 400
      end

      it "should return a Location HTTP header with the activity url" do
        post '/people/1234abcd/salmon', "foo"
        last_response.headers["Location"].must_equal @internal_activity.url
      end

      it "should handle the given payload" do
        Nelumba::Notification.expects(:from_xml)
                           .with("foo")
                           .returns(@notification)

        post '/people/1234abcd/salmon', "foo"
      end
    end

    describe "POST /people/discover" do
      it "should attempt to discover the author in 'account' field" do
        acct = "acct:wilkie@rstat.us"
        Nelumba::Person.expects(:discover!).with(acct).returns(nil)

        post '/people/discover', "account" => acct
      end

      it "should redirect to the author when it is known" do
        acct = "acct:wilkie@rstat.us"
        author = stub('Person')
        author.stubs(:id).returns("ID")
        Nelumba::Person.stubs(:discover!).with(acct).returns(author)

        post '/people/discover', "account" => acct
        last_response.status.must_equal 302
      end

      it "should return 404 when the author is not discovered" do
        acct = "acct:noexists@rstat.us"
        Nelumba::Person.stubs(:discover!).with(acct).returns(nil)

        post '/people/discover', "account" => acct
        last_response.status.must_equal 404
      end

      it "should redirect when the author is discovered but exists" do
        acct = "acct:wilkie@rstat.us"
        author = stub('::Nelumba::Person')
        author.stubs(:id).returns("ID")
        Nelumba::Person.stubs(:discover!).with(acct).returns(author)

        post '/people/discover', "account" => acct
        last_response.status.must_equal 302
      end

      it "should redirect to the author when discovered but exists" do
        acct = "acct:wilkie@rstat.us"
        author = stub('::Nelumba::Person')
        author.stubs(:id).returns("ID")
        Nelumba::Person.stubs(:discover!).with(acct).returns(author)

        post '/people/discover', "account" => acct
        last_response.location.must_equal "http://example.org/people/ID"
      end
    end

    describe "GET /people/:id/edit" do
      it "should return 404 when the author is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/edit'
        last_response.status.must_equal 404
      end

      it "should return 200 when the author is found" do
        Nelumba::Person.stubs(:find_by_id).returns(stub('author'))

        get '/people/1234abcd/edit'
        last_response.status.must_equal 200
      end
    end

    describe "POST /people/:id" do
      it "should return 404 when the author is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        post '/people/1234abcd'
        last_response.status.must_equal 404
      end

      it "should redirect when author is found and it is the logged in user" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_attributes!)

        Nelumba::Person.stubs(:find_by_id).returns(author)
        Nelumba::Person.stubs(:sanitize_params).returns({:id => author.id})

        login_as("wilkie", author)

        post "/people/#{author.id}"
        last_response.status.must_equal 302
      end

      it "should redirect to author when found and it is the logged in user" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_attributes!)

        Nelumba::Person.stubs(:find_by_id).returns(author)
        Nelumba::Person.stubs(:sanitize_params).returns({"id" => author.id})

        login_as("wilkie", author)

        post "/people/#{author.id}"
        last_response.location.must_equal "http://example.org/people/#{author.id}"
      end

      it "should not allow injection of data to update_attributes" do
        author = stub('Person')
        author.stubs(:id).returns("ID")

        Nelumba::Person.stubs(:find_by_id).returns(author)
        Nelumba::Person.stubs(:sanitize_params).returns("sanitized")

        author.expects(:update_attributes!).with("sanitized")

        login_as("wilkie", author)

        post "/people/#{author.id}", "foobar" => "moo"
      end

      it "should return 404 if the author, although exists, isn't logged on" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_attributes!)

        Nelumba::Person.stubs(:find_by_id).returns(author)
        Nelumba::Person.stubs(:sanitize_params).returns({:id => author.id})

        post "/people/#{author.id}"
        last_response.status.must_equal 404
      end

      it "should return 404 if another person then owner attempts to edit" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_attributes!)

        Nelumba::Person.stubs(:find_by_id).returns(author)
        Nelumba::Person.stubs(:sanitize_params).returns({:id => author.id})

        login_as("intruder")

        post "/people/#{author.id}"
        last_response.status.must_equal 404
      end
    end

    describe "GET /people/:id/avatar/edit" do
      it "should return 404 when the author is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        get '/people/1234abcd/avatar/edit'
        last_response.status.must_equal 404
      end

      it "should return 200 when the author is found" do
        Nelumba::Person.stubs(:find_by_id).returns(stub('author'))

        get '/people/1234abcd/avatar/edit'
        last_response.status.must_equal 200
      end
    end

    describe "POST /people/:id/avatar" do
      it "should return 404 when the author is not found" do
        Nelumba::Person.stubs(:find_by_id).returns(nil)

        post '/people/1234abcd/avatar'
        last_response.status.must_equal 404
      end

      it "should redirect when author is found and it is the logged in user" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_avatar!)

        Nelumba::Person.stubs(:find_by_id).returns(author)

        login_as("wilkie", author)

        post "/people/#{author.id}/avatar"
        last_response.status.must_equal 302
      end

      it "should redirect to author when found and it is the logged in user" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_avatar!)

        Nelumba::Person.stubs(:find_by_id).returns(author)

        login_as("wilkie", author)

        post "/people/#{author.id}/avatar"
        last_response.location.must_equal "http://example.org/people/#{author.id}"
      end

      it "should update the avatar with the given url" do
        author = stub('Person')
        author.stubs(:id).returns("ID")

        Nelumba::Person.stubs(:find_by_id).returns(author)

        author.expects(:update_avatar!).with("AVATAR_URL")

        login_as("wilkie", author)

        post "/people/#{author.id}/avatar", "avatar_url" => "AVATAR_URL"
      end

      it "should return 404 if the author, although exists, isn't logged on" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_avatar!)

        Nelumba::Person.stubs(:find_by_id).returns(author)

        post "/people/#{author.id}/avatar"
        last_response.status.must_equal 404
      end

      it "should return 404 if another person then owner attempts to edit" do
        author = stub('Person')
        author.stubs(:id).returns("ID")
        author.stubs(:update_avatar!)

        Nelumba::Person.stubs(:find_by_id).returns(author)

        login_as("intruder")

        post "/people/#{author.id}/avatar"
        last_response.status.must_equal 404
      end
    end
  end
end
