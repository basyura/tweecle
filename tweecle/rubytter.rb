require 'rubytter'

class Tweecle
  class Rubytter
    #
    #
    def initialize(config)
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
      @client = OAuthRubytter.new(access_token)
    end
    #
    #
    def method_missing(method , *args)
      @client.__send__(method , *args)
    end
  end
end
