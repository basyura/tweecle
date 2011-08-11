require 'pstore'
require 'time'
require 'fileutils'
require './config'
require './notifier'
require './rubytter'
#
#  brew install growlnotify
#  brew install curl
#
#  config.yaml
#    consumer_key        : your consumer key
#    consumer_secret     : your consumer secret
#    access_token        : your access token
#    access_token_secret : your access token secret
#    notify_number       : notify number at a time
#    sleeping_seconds    : sleeping seconds after notified
#
class Tweecle
  #
  #
  def initialize(config_path , out = nil)
    @config   = Tweecle::Config.new(config_path)
    @rubytter = Tweecle::Rubytter.new(@config)
    @notifier = Tweecle::Notifier.new(@config)
    @out      = out
  end
  #
  #
  def crawl(method , *params)
    PStore.new(@config.pstore_path(method)).transaction do |pstore|
      count = 0
      since_id = pstore[:since_id] ||= 0
      tweets = @rubytter.__send__(method , *params).reverse
      tweets.each do |tweet|
        next if since_id >= tweet.id
        if count % @config.notify_number == 0 &&  count != 0
          sleep @config.sleeping_seconds 
        end
        count += 1
        @notifier.growl(tweet , method)

        log "-".ljust(100 , "-")
        log tweet.user.screen_name.to_s.ljust(15) + 
          ' : ' + tweet.text + 
          " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"
      end
      pstore[:since_id] = tweets[-1].id unless tweets.empty?
    end
  end
  
  private
  #
  #
  def log(msg)
    return unless @out
    @out.puts msg
  end
end
