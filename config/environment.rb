# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'

require 'uri'
require 'pathname'

require 'pg'
require 'active_record'
require 'logger'

require 'sinatra'
require "sinatra/reloader" if development?

require 'erb'
require 'twitter'
require 'byebug'
require 'omniauth-twitter'
require 'yaml'

require 'sidekiq'
require 'redis'
require 'sidekiq/api'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'workers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

# For Heroku production with terminal set up
# heroku config:set twitter_consumer_key_id=cBRMA4SEUquwvBWeDmtYSBDHc
# heroku config:set twitter_consumer_secret_key_id=ephH3FpEunz8giGxvimkNW9t7MKIp9HnCo4F0cQsNtrPk5HTOI
# heroku logs 
# heroku login
# heroku logout (imf*)
# rename heroku app: heroku apps: rename name-app
if Sinatra::Base.development?
	API_KEYS = YAML::load(File.open('config/app.yaml'))
else
	API_KEYS = {}
	API_KEYS["twitter_consumer_key_id"] = ENV["twitter_consumer_key_id"]
	API_KEYS["twitter_consumer_secret_key_id"] = ENV["twitter_consumer_secret_key_id"]
end

# $client = Twitter::REST::Client.new do |config|
#   config.consumer_key        = "cBRMA4SEUquwvBWeDmtYSBDHc"
#   config.consumer_secret     = "ephH3FpEunz8giGxvimkNW9t7MKIp9HnCo4F0cQsNtrPk5HTOI"
#   config.access_token        = "1552643148-KaArss8X3inbPsva9tzWoxU4poViR0jF2BMRQlZ"
#   config.access_token_secret = "kpaJjQt0ZkqzXN2FXCnbx3F80K1in4gHjxJtxR1cRUpU3" #put them in
# end

use OmniAuth::Builder do
	provider :twitter, API_KEYS["twitter_consumer_key_id"], API_KEYS["twitter_consumer_secret_key_id"]
end