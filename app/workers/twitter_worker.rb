class TwitterWorker
  include Sidekiq::Worker

  def perform(tweet_id)
  	puts "working.."
    tweet = Tweet.find(tweet_id)
    @user = tweet.twitter_user
    twitter_client = @user.generate_client
    twitter_client.update(tweet.desc)
    # actually make API call
    # Note: this does not have access to controller/view helpers
    # You'll have to re-initialize everything inside here
  end
end
