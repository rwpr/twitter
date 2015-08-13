helpers do
	def current_user
		if session[:username]
			TwitterUser.find_by(username: session[:username])
		end
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
	# session[:admin].clear
	# session[:username].clear
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
	@tweets = @twitter_user.tweets

	# LAYOUT SET FALSE TO REMOVE THE CONTAINER WHEN I INSERTED INTO DIV ID =" TWEETS"
	erb :_tweet_box
end