
class Tweecle
  class Notifier
    #
    #
    def initialize(config)
      if isWin
        @notifier = Tweecle::Notifier::RubyGNTP.new(config)
      else
        @notifier = Tweecle::Notifier::GrowlNotify.new(config)
      end
    end
    #
    #
    def notify(tweet , type = "notify")
      @notifier.notify(tweet , type.to_s)
    end

    private
    #
    #
    def isWin
      RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    end
  end
end
