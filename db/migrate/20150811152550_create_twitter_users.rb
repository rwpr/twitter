class CreateTwitterUsers < ActiveRecord::Migration
  def change
  	create_table :twitter_users do	|t|
  		t.string :username
  		t.string :access_token
  		t.string :access_token_secret
  	end
  end
end
