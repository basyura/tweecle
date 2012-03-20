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
  io/console
).each { |lib| require lib }
%w(
  config
  notifier
  rubytter
  notifier/base
  notifier/ruby_gntp
  notifier/growl_notify
).each { |name| require File.expand_path("../tweecle/#{name}", __FILE__) }
#
#
class Tweecle
  #
  #
  def initialize(config = {})
    @config   = Tweecle::Config.new(config)
    @rubytter = Tweecle::Rubytter.new(@config)
    @notifier = Tweecle::Notifier.new(@config)
    @out      = @config.out
    @notified = {}
    @user     = @rubytter.verify_credentials
  end
  #
  #
  def crawl(interval , &block)
    while true
      begin
        instance_eval(&block)
      rescue => e
        puts e
      end
      sleep interval
    end
  end
  #
  #
  def __crawl__(method , *params)
    count = 0
    PStore.new(@config.pstore_path(method)).transaction do |pstore|
      since_id = pstore[:since_id] ||= 0
      tweets(method , *params).each do |tweet|
        next if since_id >= tweet.id
        count += 1 if notify(tweet , method)
        pstore[:since_id] = tweet.id

        msg = "#{tweet.screen_name.ljust(15)} : #{tweet.text}" + 
              " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"
        if tweet.text =~ /@#{@user.screen_name}/
          msg = "\033[33m" + msg + "\033[0m"
        end

        log "\033[36m" + "-".ljust(STDOUT.winsize[1], "-") + "\033[0m"
        log msg

        if count % @config.notify_number == 0 &&  count != 0
          sleep @config.sleeping_seconds 
        end
      end
    end
    sleep @config.sleeping_seconds if count > 0
  end
  #
  #
  def method_missing(method , *params)
    if @rubytter.respond_to?(method)
      __crawl__(method , *params)
    else
      raise StandardError.new "No Suche Method : #{method}"
    end
  end
  
  private
  #
  #
  def tweets(method , *params)
    @rubytter.__send__(method , *params)
  end
  #
  #
  def notify(tweet , method)
    unless @notified.include?(tweet.id)
      @notifier.notify(tweet , method)
      @notified[tweet.id] = true
      true
    else
      false
    end
  end
  #
  #
  def log(msg)
    return unless @out
    @out.puts msg
  end
end
