helpers do
	def current_user
		if session[:username]
			TwitterUser.find_by(username: session[:username])
		end
	end
end

helpers do 
	def job_is_complete(jid)
	  waiting = Sidekiq::Queue.new
	  working = Sidekiq::Workers.new
	  pending = Sidekiq::ScheduledSet.new
	  return false if pending.find { |job| job.jid == jid }
	  return false if waiting.find { |job| job.jid == jid }
	  return false if working.find { |process_id, thread_id, work| work["payload"]["jid"] == jid }
	  true
	end
end

get '/' do
  erb :index
end

get '/login' do
	session[:admin] = true
	redirect to "/auth/twitter"
end

get '/:username' do
	@user = TwitterUser.find_or_create_by(username: params[:username])
	@username = @user.username

    if 	@user.tweets.empty? || @user.tweets_stale?
       	@tweets = @user.fetch_tweets!(params[:username])
       	@tweets
       	erb :index
	else
		@tweets = @user.tweets.first(10)
		erb :index
	end
end

get '/auth/twitter/callback' do
	env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorised')
	@user = TwitterUser.find_or_create_by(username: env['omniauth.auth']['info']['nickname'])
	@user.access_token = env['omniauth.auth']['credentials']['token']
	@user.access_token_secret = env['omniauth.auth']['credentials']['secret']
	@user.username = env['omniauth.auth']['info']['name']
	@user.save

	session[:username] = @user.username
	redirect to '/'
end

get '/auth/failure' do
	params[:message]
end


get '/logout' do
	session.clear
	redirect '/'
end

post '/' do
	redirect to "/#{params[:username]}"
end

post '/tweets' do

	@twitter_user = current_user
	@twitter_user.post_tweet(params["newtweet"])
	@twitter_user.fetch_tweets!(params['username'])
	@tweet = @twitter_user.tweets.first
	@tweet.to_json
	# LAYOUT SET FALSE TO REMOVE THE CONTAINER WHEN I INSERTED INTO DIV ID =" TWEETS"
	# erb :_tweet_box
end

post '/tweets_later' do
	@twitter_user = current_user
	@job_id = @twitter_user.post_tweet_later(params["tweetlater"],params["time"])
	@tweet = @twitter_user.tweets.first

	{tweet: @tweet, job_id: @job_id}.to_json
	# LAYOUT SET FALSE TO REMOVE THE CONTAINER WHEN I INSERTED INTO DIV ID =" TWEETS"
	# erb :_tweet_box
end

get '/status/:job_id' do
  # return the status of a job to an AJAX call
  @job_id = params[:job_id]
  job_is_complete(params[:job_id]).to_s
end
