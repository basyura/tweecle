
class Tweecle
  class Notifier
    class GrowlNotify
      #
      #
      def initialize(config)
        @config = config
        require 'growl_notify'
        ::GrowlNotify.config do |gconf|
          gconf.application_name      = "tweecle"
          gconf.notifications         = ["notify" , "replies"]
          gconf.default_notifications = ["notify"] 
        end
        # to save icons
        FileUtils.mkdir_p(@config.images_dir)
      end
      #
      #
      def notify(tweet , type)
        type = ::GrowlNotify.notifications.include?(type) ? type : "notify"
        ::GrowlNotify.normal(
          :title       => tweet.screen_name , 
          :description => tweet.text ,
          :icon        => image_path(@config.images_dir , tweet) ,
          :with_name => type
        )
      end

      private
      #
      #
      def image_path(images_dir , tweet)
        url = tweet.image_url
        return nil unless url =~ /profile_images\/(.*?)\/(.*)/
        path = File.join(images_dir , "#{$1}_#{$2}")
        unless File.exist?(path)
          `curl --silent -o #{path} #{url}`
        end
        path
      end
    end
  end
end
