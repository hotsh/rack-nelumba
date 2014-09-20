require_relative 'helper'
require_controller 'authorizations'

class  Nelumba::Authorization; end
module Nelumba;         end

describe Rack::Nelumba do
  before do
    # Do not render
    Rack::Nelumba.any_instance.stubs(:render).returns("html")
  end

  describe "Authorizations Controller" do
    describe "GET /login" do
      it "should render authorizations/login" do
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"authorizations/login",
                                                       anything)

        get '/login'
      end
    end

    describe "POST /login" do
      before do
        @auth = stub('Authorization')
        @auth.stubs(:authenticated?).returns(false)
        @auth.stubs(:id).returns("ID")
        person = stub('Person')
        person.stubs(:id).returns("PID")
        @auth.stubs(:person).returns(person)
        Nelumba::Authorization.stubs(:first).returns(@auth)

        @session = stub('session')
        @session.stubs(:[]=).with(:user_id, "ID")
        @session.stubs(:[]=).with(:person_id, "PID")
        Rack::Nelumba.any_instance.stubs(:session).returns(@session)
      end

      it "should log in when given a valid username/password" do
        @auth.stubs(:authenticated?).returns(true)

        @session.expects(:[]=).with(:user_id, "ID")
        @session.expects(:[]=).with(:person_id, "PID")

        post '/login', "password" => "foobar", "username" => "wilkie"
      end

      it "should return 404 when the username does not exist" do
        Nelumba::Authorization.stubs(:first).returns(nil)

        post '/login', "password" => "foobar", "username" => "bogus"

        last_response.status.must_equal 404
      end

      it "should not login when the username does not exist" do
        Nelumba::Authorization.stubs(:first).returns(nil)

        @session.expects(:[]=).never

        post '/login', "password" => "foobar", "username" => "bogus"

        last_response.status.must_equal 404
      end

      it "should return 404 when the password is incorrect" do
        @auth.stubs(:authenticated?).returns(false)

        post '/login', "password" => "bogus", "username" => "wilkie"

        last_response.status.must_equal 404
      end

      it "should not login when the password is incorrect" do
        @session.expects(:[]=).never

        @auth.stubs(:authenticated?).returns(false)

        post '/login', "password" => "bogus", "username" => "wilkie"
      end

      it "should redirect when login is successful" do
        @auth.stubs(:authenticated?).returns(true)

        post '/login', "password" => "foobar", "username" => "wilkie"

        last_response.status.must_equal 302
      end

      it "should redirect to home when login is successful" do
        @auth.stubs(:authenticated?).returns(true)

        post '/login', "password" => "foobar", "username" => "wilkie"

        last_response.location.must_equal "http://example.org/"
      end
    end

    describe "GET /logout" do
      it "should nullify the user_id session key" do
        session = stub('session')
        session.stubs(:[]=)
        session.expects(:[]=).with(:user_id, nil)
        Rack::Nelumba.any_instance.stubs(:session).returns(session)

        get '/logout'
      end

      it "should nullify the person_id session key" do
        session = stub('session')
        session.stubs(:[]=)
        session.expects(:[]=).with(:person_id, nil)
        Rack::Nelumba.any_instance.stubs(:session).returns(session)

        get '/logout'
      end

      it "should redirect" do
        Rack::Nelumba.any_instance.stubs(:session).returns({})
        get '/logout'

        last_response.status.must_equal 302
      end

      it "should redirect to home" do
        Rack::Nelumba.any_instance.stubs(:session).returns({})
        get '/logout'

        last_response.location.must_equal "http://example.org/"
      end
    end

    describe "GET /authorizations/new" do
      it "should render authorizations/login" do
        Rack::Nelumba.any_instance.expects(:render).with(anything,
                                                       :"authorizations/new",
                                                       anything)

        get '/authorizations/new'
      end
    end

    describe "POST /authorizations" do
      it "should return 404 if the username is already taken" do
        Nelumba::Authorization.stubs(:find_by_username).returns("something")

        post '/authorizations', "username" => "taken", "password" => "foobar"

        last_response.status.must_equal 404
      end

      it "should create an account for the given username when unique" do
        Nelumba::Authorization.stubs(:find_by_username).returns(nil)
        Rack::Nelumba.any_instance.stubs(:session).returns({})
        auth = stub('Authorization')
        auth.stubs(:id).returns("ID")
        person = stub('Person')
        person.stubs(:id).returns("PID")
        author = stub('Author')
        author.stubs(:id)
        person.stubs(:author).returns(author)
        auth.stubs(:person).returns(person)

        Nelumba::Authorization.expects(:create!)
                     .with(has_entry("username" => "wilkie"))
                     .returns(auth)

        post '/authorizations', "username" => "wilkie", "password" => "foobar"
      end

      it "should create an account for the given password" do
        Nelumba::Authorization.stubs(:find_by_username).returns(nil)
        Rack::Nelumba.any_instance.stubs(:session).returns({})
        auth = stub('Authorization')
        auth.stubs(:id).returns("ID")
        person = stub('Person')
        person.stubs(:id).returns("PID")
        author = stub('Author')
        author.stubs(:id)
        person.stubs(:author).returns(author)
        auth.stubs(:person).returns(person)

        Nelumba::Authorization.expects(:create!)
                     .with(has_entry("password" => "foobar"))
                     .returns(auth)

        post '/authorizations', "username" => "wilkie", "password" => "foobar"
      end

      it "should login the new account upon creation" do
        Nelumba::Authorization.stubs(:find_by_username).returns(nil)
        auth = stub('Authorization')
        auth.stubs(:id).returns("ID")
        person = stub('Person')
        person.stubs(:id).returns("PID")
        author = stub('Author')
        author.stubs(:id)
        person.stubs(:author).returns(author)
        auth.stubs(:person).returns(person)

        Nelumba::Authorization.stubs(:create!).returns(auth)

        session = stub('session')
        session.expects(:[]=).with(:user_id, "ID")
        session.expects(:[]=).with(:person_id, "PID")
        Rack::Nelumba.any_instance.stubs(:session).returns(session)

        post '/authorizations', "username" => "wilkie", "password" => "foobar"
      end

      it "should redirect when account is created" do
        Nelumba::Authorization.stubs(:find_by_username).returns(nil)
        Rack::Nelumba.any_instance.stubs(:session).returns({})
        auth = stub('Authorization')
        auth.stubs(:id).returns("ID")
        person = stub('Person')
        person.stubs(:id).returns("PID")
        author = stub('Author')
        author.stubs(:id)
        person.stubs(:author).returns(author)
        auth.stubs(:person).returns(person)

        Nelumba::Authorization.stubs(:create!).returns(auth)

        post '/authorizations', "username" => "wilkie", "password" => "foobar"

        last_response.status.must_equal 302
      end

      it "should redirect to author edit for new account upon creation" do
        Nelumba::Authorization.stubs(:find_by_username).returns(nil)
        Rack::Nelumba.any_instance.stubs(:session).returns({})

        auth = stub('Authorization')
        auth.stubs(:id).returns("ID")

        person = stub('Person')
        person.stubs(:id).returns("PID")

        auth.stubs(:person).returns(person)

        Nelumba::Authorization.stubs(:create!).returns(auth)

        post '/authorizations', "username" => "wilkie", "password" => "foobar"

        last_response.location.must_equal "http://example.org/people/PID/edit"
      end
    end
  end
end
