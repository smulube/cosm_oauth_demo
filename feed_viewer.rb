require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'oj'
require 'cosm_oauth'

configure do
  use Rack::Session::Cookie, :key => 'cosm-oauth-test.session',
                             :domain => ENV['DOMAIN'],
                             :path => '/',
                             :expire_after => 2592000,
                             :secret => ENV['COOKIE_SECRET']

  use Rack::Logger, Logger::INFO
end

helpers do
  def logger
    request.logger
  end
end

# Runs before all requests
before do
  # Initialize client object (with client id, secret and redirect_uri)
  @client = Cosm::OAuth::Client.new(:client_id => ENV['CLIENT_ID'],
                                    :client_secret => ENV['CLIENT_SECRET'],
                                    :redirect_uri => to("/oauth/callback"))

  # Set it's access rights if we have them in the session
  @client.access_token = session[:access_token]
  @client.user = session[:user]

  logger.info("Client: #{@client.inspect}")
end

get '/' do
  redirect("/feeds") if @client.authorized?
  erb :index
end

get '/feeds' do
  redirect("/") unless @client.authorized?

  response = @client.get("feeds.json", { :user => @client.user, :per_page => 1000, :content => "summary" })

  @feeds = Oj.load(response)

  erb :feeds
end

# Redirect to Cosm to authorize the app
get '/oauth/authorize' do
  redirect(@client.authorization_url)
end

# We get redirected here from Cosm on both success and failure
get '/oauth/callback' do
  if request.params["error"]
    flash[:error] = "User denied access"
    redirect("/")
  else
    # Extract temporary code
    code = request.params["code"]

    logger.info("Fetching access token")

    @client.fetch_access_token(code)

    logger.info("Access token: #{@client.access_token}")
    logger.info("User: #{@client.user}")

    if @client.authorized?
      # Capture out our user id and access_token
      session[:user] = @client.user
      session[:access_token] = @client.access_token

      redirect("/feeds")
    else
      flash[:error] = "Unable to obtain access_token"

      redirect("/")
    end
  end
end

get '/oauth/logout' do
  session.clear
  flash[:notice] = "Logged out"
  redirect "/"
end
