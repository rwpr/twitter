class TwitterUser < ActiveRecord::Base
  has_many :tweets

  def fetch_tweets!(username)
	$client.user_timeline(username)
  end
end
