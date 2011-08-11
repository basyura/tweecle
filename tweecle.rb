require 'rubytter'
require 'pstore'
require 'time'
require 'fileutils'
require './config'
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
class Tweecle
  #
  #
  def initialize(config_path , out = nil)
    @config   = Tweecle::Config.new(config_path)
    @rubytter = new_client(@config)
    @out      = out
    initialize_files(@config)
    initialize_growl(@config)
  end
  #
  #
  def crawl(method , *params)
    path = File.join(@config.pstore_path , method.to_s + ".pstore")
    PStore.new(path).transaction do |pstore|
      count = 0
      since_id = pstore[:since_id] ||= 0
      tweets = @rubytter.__send__(method , *params).reverse
      tweets.each do |tweet|
        next if since_id >= tweet.id
        if count % @config.notify_number.to_i == 0 &&  count != 0
          sleep @config.sleeping_seconds.to_i 
        end
        count += 1
        growl(tweet , method)
      end
      pstore[:since_id] = tweets[-1].id unless tweets.empty?
    end
  end
  
  private
  #
  #
  def growl(tweet , type = "notify")
    type = type.to_s
    type = GrowlNotify.notifications.include?(type) ? type : "notify"

    log "-".ljust(100 , "-")
    log tweet.user.screen_name.to_s.ljust(15) + 
            ' : ' + tweet.text + 
            " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"

    if isWin
      GNTP.notify(
        :app_name => "tweecle",
        :name     => type ,
        :title    => tweet.user.screen_name ,
        :text     => tweet.text ,
        :icon     => tweet.user.profile_image_url_https,
      )
    else
      GrowlNotify.normal(
        :title       => tweet.user.screen_name , 
        :description => tweet.text ,
        :icon        => image_path(@config.images_dir , 
                                   tweet.user.profile_image_url_https) ,
        :with_name   => type
      )
    end
  end
  #
  #
  def new_client(config)
    consumer = OAuth::Consumer.new(
      config.consumer_key     ,
      config.consumer_secret ,
      :site => 'https://api.twitter.com'
    )
    access_token = OAuth::AccessToken.new(
      consumer ,
      config.access_token ,
      config.access_token_secret
    )
    OAuthRubytter.new(access_token)
  end
  #
  #
  def initialize_files(config)
    FileUtils.mkdir_p(config.images_dir)
  end
  #
  #
  def initialize_growl(config)

    if isWin
      require 'ruby_gntp'
      growl = GNTP.new("tweecle")
      growl.register(:notifications => [{
        :name     => ["notify" , "replies"] ,
        :enabled  => true,
      }])
    else
      require 'growl_notify'
      GrowlNotify.config do |gconf|
        gconf.application_name      = "tweecle"
        gconf.notifications         = ["notify" , "replies"]
        gconf.default_notifications = ["notify"] 
      end
    end
  end
  #
  #
  def image_path(images_dir , profile_image_url)
    return nil unless profile_image_url =~ /profile_images\/(.*?)\/(.*)/
    path = File.join(images_dir , "#{$1}_#{$2}")
    unless File.exist?(path)
      `curl --silent -o #{path} #{profile_image_url}`
    end
    path
  end
  #
  #
  def isWin
    RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
  end
  #
  #
  def log(msg)
    return unless @out
    @out.puts msg
  end
end
