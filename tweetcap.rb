require 'time'
require 'tweetstream'
require 'mongo'
require 'yajl'

mongo_uri = URI.parse(ENV['MONGOLAB_URI'])
mongo_conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
mongo_db = mongo_conn.db(mongo_uri.path.gsub(/^\//, ''))
filive_tweets = mongo_db.collection("filive_tweets")
filive_live = mongo_db.collection("filive_live")

TweetStream.configure do |config|
  config.username = ENV['TWITTER_USER']
  config.password = ENV['TWITTER_PASS']
  config.auth_method = :basic
  config.parser = :yajl
end

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

client.track("#filive") do |status|
  cs = { :id => status[:id],
         :created_at => Time.parse(status[:created_at]).utc,
         :text => status[:text],
         :retweet_count => status[:retweet_count],
         :in_reply_to_user_id => status[:in_reply_to_user_id],
         :in_reply_to_status_id => status[:in_reply_to_status_id],
         :in_reply_to_status_id_str => status[:in_reply_to_status_id_str],
         :in_reply_to_screen_name => status[:in_reply_to_screen_name],
         :entities => status[:entities],
         :user_id => status[:user][:id],
         :user_screen_name => status[:user][:screen_name],
         :user_name => status[:user][:name], 
         :user_profile_image_url => status[:user][:profile_image_url_https]
  }

  filive_tweets.insert(cs)
  filive_live.insert(cs)
end
