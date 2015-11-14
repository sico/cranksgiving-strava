require 'rubygems'
require 'bundler'
require 'sass/plugin/rack'
require './strava'

# use scss for stylesheets
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run Sinatra::Application