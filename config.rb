require 'yaml'

class Tweecle
  #
  #
  class Config
    DEFAULT_IMAGES_DIR       = File.expand_path("~/.tweecle/images")
    DEFAULT_PSTORE_PATH      = File.expand_path("~/.tweecle")
    DEFAULT_NOTIFY_NUMBER    = 3
    DEFAULT_SLEEPING_SECONDS = 11
    #
    #
    def initialize(config_path)
      @config = YAML.load(open(config_path).read)
    end
    #
    #
    def method_missing(method , *args)
      value = @config[method.to_s]
      unless value
        begin
          value = self.class.const_get("DEFAULT_" + method.to_s.upcase)
        rescue NameError => e
          raise StandardError("No Such Config : #{method}")
        end
      end
      value
    end
  end
end
