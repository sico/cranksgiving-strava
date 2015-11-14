require 'sinatra'
require 'tilt/erb'
require 'oauth2'

client = OAuth2::Client.new(ENV['STRAVA_APP_ID'], ENV['STRAVA_SECRET'], :site => 'https://www.strava.com/oauth/authorize')

get '/' do

	@auth_url = client.auth_code.authorize_url(:redirect_uri => ENV['BASE_URL'] + 'callback')

  erb :index
end

get '/callback' do
	code = params['code']
	@token = client.auth_code.get_token(code, :redirect_uri => ENV['BASE_URL'] + '/oauth2/callback')

	erb :callback
end