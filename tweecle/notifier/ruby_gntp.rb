
class Tweecle
  class Notifier
    class RubyGNTP
      #
      #
      def initialize(config)
        require 'ruby_gntp'
        growl = GNTP.new("tweecle")
        growl.register(:notifications => [{
          :name     => ["notify" , "replies"] ,
          :enabled  => true,
        }])
      end
      #
      #
      def notify(tweet , type)
        GNTP.notify(
          :app_name => "tweecle",
          :name     => type ,
          :title    => tweet.screen_name ,
          :text     => tweet.text ,
          :icon     => tweet.image_url ,
        )
      end
    end
  end
end
