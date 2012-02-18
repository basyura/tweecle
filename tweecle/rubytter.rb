require 'rubytter'

class Tweecle
  class Rubytter
    #
    #
    def initialize(config)
      proxy = ENV['http_proxy']
      proxy = proxy && proxy != '' ? proxy : nil
      if proxy
        proxy = 'http://' + proxy if proxy !~ /^http/
        proxy = URI.parse(proxy)
      end

      consumer = OAuth::Consumer.new(
        config.consumer_key     ,
        config.consumer_secret ,
        {
          :site  => 'https://api.twitter.com' ,
          :proxy => proxy ,
        }
      )
      access_token = OAuth::AccessToken.new(
        consumer ,
        config.access_token ,
        config.access_token_secret
      )
      option = {}
      option.merge(:proxy_host => proxy.host , :proxy_port => proxy.port) if proxy
      @client = OAuthRubytter.new(access_token , option)
    end
    #
    #
    def respond_to?(method)
      @client.respond_to?(method)
    end
    #
    #
    #
    def verify_credentials
      @client.verify_credentials
    end
    #
    #
    def method_missing(method , *args)
      @client.__send__(method , *args).reverse.map do |tweet|
        tweet.extend TweetSupport
      end
    end
  end
  #
  #
  module TweetSupport
    def screen_name
      self.user.screen_name
    end
    def image_url
      self.user.profile_image_url_https || self.user.profile_image_url
    end
  end
end
