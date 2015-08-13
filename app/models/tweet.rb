class Tweet < ActiveRecord::Base
  belongs_to :twitter_user

  def text
  	desc
  end
end
