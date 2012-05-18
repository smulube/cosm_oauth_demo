# Cosm OAuth Feed Viewer

Simple little Sinatra app which uses OAuth 2 to obtain an access token for a
user's account at (Cosm)[https://cosm.com], and uses that to render a list of
the user's feeds.

## Requirements

* Ruby 1.8.7+
* Rubygems
* Bundler

## Tests

Shh, this is just a quick hack so these don't exist yet.

## Deployment

The app was developed to be deployed on Heroku, but it's a simple little
Sinatra app, so could be deployed however you like.

The one bit of Heroku particularness is the use of ENV variables to hold the
app client id and secret.  This actually works pretty well, but you'll need to
make sure the ENV variables are properly set when running the app locally, or
you'll see some weird behaviour. You can either set these environment variables
manually, or use the .env file and run the app using `foreman`.

So to run first check out the app, then run:

    $ bundle install

Copy .env.template into .env, and fill it with the appropriate values. Note to
get a valid client_id and secret, you'll have to register your app on Cosm.
Once registered you can run your app locally like this:

    $ foreman start
