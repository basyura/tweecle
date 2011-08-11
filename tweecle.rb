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
%w(
  pstore
  time
  fileutils
).each { |lib| require lib }
%w(
  config
  notifier
  rubytter
).each { |name| require File.expand_path("../tweecle/#{name}", __FILE__) }
#
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
      tweets(method , *params).each do |tweet|
        next if since_id >= tweet.id
        if count % @config.notify_number == 0 &&  count != 0
          sleep @config.sleeping_seconds 
        end
        growl(tweet , method)
        pstore[:since_id] = tweet.id
        count += 1

        log "-".ljust(100 , "-")
        log tweet.user.screen_name.to_s.ljust(15) + 
          ' : ' + tweet.text + 
          " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"
      end
    end
  end
  
  private
  #
  #
  def tweets(method , *params)
    @rubytter.__send__(method , *params).reverse
  end
  #
  #
  def growl(tweet , method)
    @notifier.growl(tweet , method)
  end
  #
  #
  def log(msg)
    return unless @out
    @out.puts msg
  end
end
