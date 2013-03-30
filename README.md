# Rack-Lotus

**WORK IN PROGRESS**

This is a federation framework built on top of Rack. This should work on top of
a Sinatra or Rails application in order to provide a wide userbase and high
amount of social interaction while allowing self-hosting, decentralization and
replication of content. See the [Lotus project](https://github.com/hotsh/lotus)
for more information.

This project builds off of the afforementioned Lotus project. The base project
is simply immutable structures that are the result of querying a federated
service. Therefore, build a server with this, and a client with the base found
above.

## Database Backends

Currently, Lotus supports only MongoDB through MongoMapper.

## Usage

Add the following to your Gemfile:

`gem 'rack-lotus'`

Bundle your application:

`bundle install`

And add the following to your config.ru or within your application:

`use Rack::Lotus`

## API

The minimum API that all Lotus applications will have:

### People and the Social Graph

`GET  /people/:id` - The profile for the person with the given id. (HTML)

`GET  /people/:id/feed` - The outbox for activities performed by this person. (Atom/JSON)

`POST /people/:id/inbox` - The inbox for activities POST'd by those this person follows. (Atom/JSON)

`POST /people/:id/direct` - The place where activities can be POST'd by those this person does not know. (Atom/JSON)

### Low-Level Subscriptions

`GET  /subscriptions/:id` - Retrieves information about the given subscription. (Atom/JSON)

### Activities

`GET  /activities/:id` - Retrieve the given activity. (Atom/JSON)

`PUT  /activities/:id` - Update the given activity if you are the author. (Atom/JSON)

### Feeds

`GET  /feeds/:id` - Retrieve the given feed. (Atom/JSON)

`POST /feeds/:id` - Post new content to this feed. (Atom/JSON)

### Authors

`GET  /authors/:id` - Retrieve the given author. (Atom/JSON)

`PUT  /authors/:id` - Update the given author if you are the owner. (Atom/JSON)

### OAuth 1.0

`GET  /oauth/request_token` - Acquire OAuth request token

`POST /oauth/authorize`     - Authorize OAuth request token

`GET  /oauth/access_token`  - Turn a request token into an access token
