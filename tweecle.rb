#!/usr/bin/env ruby

require 'rubytter'
require 'oauth'
require 'pstore'
require 'time'
require 'growl_notify'
require 'yaml'
#
#  config.yaml
#    consumer_key        : your consumer key
#    consumer_secret     : your consumer secret
#    access_token        : your access token
#    access_token_secret : your access token secret
#
#
class Tweecle
  #
  #
  def initialize(config_path)
    @config = YAML.load(open(config_path).read)
    consumer = OAuth::Consumer.new(
      @config["consumer_key"]    ,
      @config["consumer_secret"] ,
      :site => 'https://api.twitter.com'
    )
    access_token = OAuth::AccessToken.new(
      consumer ,
      @config["access_token"] ,
      @config["access_token_secret"]
    )
    @rubytter = OAuthRubytter.new(access_token)
    GrowlNotify.config do |gconf|
      gconf.application_name      = "tweecle"
      gconf.notifications         = ["notify"]
      gconf.default_notifications = ["notify"] 
    end
  end
  #
  #
  def crawl
    PStore.new("/repos/ruby/tweet_crawler/_status").transaction do |pstore|
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
    puts tweet.user.screen_name.to_s.ljust(15) + 
            ' : ' + tweet.text + 
            " (#{Time.parse(tweet.created_at).strftime('%H:%M:%S')})"

    puts "-".ljust(100 , "-")

    image_path = nil
    if tweet.user.profile_image_url =~ /profile_images\/(.*?)\/(.*)/
      image_path = "images/#{$1}_#{$2}"
      unless File.exist?(image_path)
        `wget #{tweet.user.profile_image_url} --output-document #{image_path}`
      end
    end
    GrowlNotify.normal(
      :title => tweet.user.screen_name , 
      :description => tweet.text ,
      :icon => "/repos/ruby/tweet_crawler/#{image_path}"
    )
  end
end

tweecle = Tweecle.new("config.yaml")

while true
  tweecle.crawl
  sleep 30
end

