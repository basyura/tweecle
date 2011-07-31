#!/usr/bin/env ruby

require 'rubytter'
require 'pstore'
require 'time'
require 'growl_notify'
require 'yaml'
require 'fileutils'
#
#  brew install growlnotify
#  brew install curl
#
#  config.yaml
#    consumer_key        : your consumer key
#    consumer_secret     : your consumer secret
#    access_token        : your access token
#    access_token_secret : your access token secret
#
class Tweecle
  IMAGES_DIR  = File.expand_path("~/.tweecle/images")
  PSTORE_PATH = File.expand_path("~/.tweecle/status.pstore")
  #
  #
  def initialize(config_path)
    initialize_files
    initialize_growl

    @config   = YAML.load(open(config_path).read)
    @rubytter = new_client(@config)
  end
  #
  #
  def crawl
    PStore.new(PSTORE_PATH).transaction do |pstore|
      count = 0
      since_id = pstore[:since_id] ||= 0
      tweets = @rubytter.list_statuses('basyura' , 'all').reverse
      tweets.each do |tweet|
        next if since_id >= tweet.id
        sleep 11 if count % 3 == 0 &&  count != 0
        count += 1
        growl(tweet)
      end
      pstore[:since_id] = tweets[-1].id unless tweets.empty?
    end
  end
  
  private
  #
  #
  def growl(tweet)
    puts "-".ljust(100 , "-")
    puts tweet.user.screen_name.to_s.ljust(15) + 
            ' : ' + tweet.text + 
            " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"

    GrowlNotify.normal(
      :title       => tweet.user.screen_name , 
      :description => tweet.text ,
      :icon        => image_path(tweet.user.profile_image_url_https)
    )
  end
  #
  #
  def new_client(config)
    consumer = OAuth::Consumer.new(
      config["consumer_key"]    ,
      config["consumer_secret"] ,
      :site => 'https://api.twitter.com'
    )
    access_token = OAuth::AccessToken.new(
      consumer ,
      config["access_token"] ,
      config["access_token_secret"]
    )
    OAuthRubytter.new(access_token)
  end
  #
  #
  def initialize_files
    FileUtils.mkdir_p(IMAGES_DIR)
  end
  #
  #
  def initialize_growl
    GrowlNotify.config do |gconf|
      gconf.application_name      = "tweecle"
      gconf.notifications         = ["notify"]
      gconf.default_notifications = ["notify"] 
    end
  end
  #
  #
  def image_path(profile_image_url)
    return nil unless profile_image_url =~ /profile_images\/(.*?)\/(.*)/
    path = File.join(IMAGES_DIR , "#{$1}_#{$2}")
    unless File.exist?(path)
      `curl --silent -o #{path} #{profile_image_url}`
    end
    path
  end
end

tweecle = Tweecle.new("config.yaml")

while true
  begin
    tweecle.crawl
    sleep 30
  rescue => e
    puts e
  end
end

