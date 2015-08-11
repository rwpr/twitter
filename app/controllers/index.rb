get '/' do
  erb :index
end

get '/:username' do
	@user = TwitterUser.find_or_create_by(username: params[:username])
    
	last_update = @user.tweets.last.created_at
	diff = Time.now()-last_update

	# check whether the last update is more than 5s 
	if diff > 500
		@tweets = @user.fetch_tweets!(params[:username]) #twitter objects
		@user.tweets.destroy_all
		@tweets.each do |tweet|
	 		@user.tweets.create(desc: tweet.text) 
		end
		@tweets.map! { |tweet| tweet.text } # same 
	# else query from local database (algorithm timestamping)
	else
		@tweets = @user.tweets.all.map { |tweet| tweet.desc } # same 
	end

	@tweets = @tweets.take(10)

	# Process for views
	erb :show_tweets
end

post '/' do
	redirect to "/#{params[:username]}"
end