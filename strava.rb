require 'sinatra'
require 'tilt/erb'
require 'oauth2'
require 'data_mapper'

client = OAuth2::Client.new(ENV['STRAVA_APP_ID'], ENV['STRAVA_SECRET'], :site => 'https://www.strava.com/oauth/authorize')

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
	include DataMapper::Resource

	property :id, Serial
	property :access_token, String, index: true
	property :firstname, String
	property :lastname, String
	property :email, String
	property :send_email, Boolean
end

DataMapper.finalize

DataMapper.auto_upgrade!

get '/' do

	@user = nil

	@auth_url = client.auth_code.authorize_url(:redirect_uri => ENV['BASE_URL'] + 'callback')

	@access_token = request.cookies['access_token']

	if @access_token
		@user = User.first( access_token: @access_token )
	end

  erb :index
end

get '/callback' do
	code = params['code']
	@token = client.auth_code.get_token(code, :redirect_uri => ENV['BASE_URL'] + '/oauth2/callback')

	athlete = @token.params['athlete']

	unless User.first( email: athlete['email'] )
		User.create(
			access_token: @token.token,
			firstname: athlete['firstname'],
			lastname: athlete['lastname'],
			email: athlete['email'],
			send_email: true
		)
	end

	response.set_cookie 'access_token',
		{ value: @token.token, max_age: '2592000', domain: ENV['COOKIE_DOMAIN'] }

	redirect '/'
end

# ajax endpoint
get '/subscribe' do
end

# ajax endpoint
get '/unsubscribe' do
end