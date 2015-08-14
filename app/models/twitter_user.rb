class TwitterUser < ActiveRecord::Base
  has_many :tweets

  def tweets_stale?
    #last_update = @user.tweets.last.created_at
    tweet = self.tweets.last
  	if tweet
  		return Time.now()-tweet.created_at > 30
  	else
  		false
  	end
  end

  def fetch_tweets!(username)
    client = self.generate_client
    @tweets = client.user_timeline(username)
    Tweet.where(twitter_user_id: self.id).destroy_all
    @tweets.each do |tweet|
        Tweet.create(twitter_user_id: self.id ,desc: tweet.text) 
        # alternative: Tweet.create(twitter_user_id: @user.id, body: tweet.text)
    end
    @tweets = Tweet.where(twitter_user_id: self.id)
  end

  def post_tweet(tweet)
    tweet = self.tweets.create(desc: tweet)
    TwitterWorker.perform_async(tweet.id)
    # this returns job_id of sidekiq

  end

  def post_tweet_later(tweet, time)
    puts "Time: #{time.to_i.seconds}"
    puts "tweet: #{tweet}"
    tweet = self.tweets.create(desc: tweet)
    TwitterWorker.perform_at(time.to_i.seconds, tweet.id)
  end

  
  def generate_client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = API_KEYS["twitter_consumer_key_id"]
      config.consumer_secret     = API_KEYS["twitter_consumer_secret_key_id"]
      config.access_token        = self.access_token
      config.access_token_secret = self.access_token_secret 
    end
  end
end