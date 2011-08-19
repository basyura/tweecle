
class Tweecle
  class Notifier
    class RubyGNTP < Base
      #
      #
      def initialize(config)
        require 'ruby_gntp'
        growl = GNTP.new(app_name)
        growl.register(:notifications => [{
          :name     => notification_kinds ,
          :enabled  => true,
        }])
      end
      #
      #
      def notify(tweet , type)
        GNTP.notify(
          :app_name => app_name ,
          :name     => type ,
          :title    => tweet.screen_name ,
          :text     => tweet.text ,
          :icon     => tweet.image_url ,
        )
      end
    end
  end
end
