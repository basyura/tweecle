
class Tweecle
  #
  #
  class Notifier
    #
    #
    def initialize(config)
      @config = config
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
        # to save icons
        FileUtils.mkdir_p(config.images_dir)
      end
    end
    #
    #
    def growl(tweet , type = "notify")
      type = type.to_s
      if isWin
        gntp_notify(tweet , type)
      else
        type = GrowlNotify.notifications.include?(type) ? type : "notify"
        growl_notify(tweet , type)
      end
    end

    private
    #
    #
    def gntp_notify(tweet , type)
        GNTP.notify(
          :app_name => "tweecle",
          :name     => type ,
          :title    => tweet.user.screen_name ,
          :text     => tweet.text ,
          :icon     => tweet.user.profile_image_url_https,
        )
    end
    #
    #
    def growl_notify(tweet , type) 
      GrowlNotify.normal(
        :title       => tweet.user.screen_name , 
        :description => tweet.text ,
        :icon        => image_path(@config.images_dir , 
                                   tweet.user.profile_image_url_https) ,
                                   :with_name   => type
      )
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
  end
end
