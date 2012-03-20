require 'yaml'

class Tweecle
  class Config
    DEFAULT_IMAGES_DIR       = File.expand_path("~/.tweecle/images")
    DEFAULT_PSTORE_PATH      = File.expand_path("~/.tweecle")
    DEFAULT_NOTIFY_NUMBER    = 3
    DEFAULT_SLEEPING_SECONDS = 11
    TO_INT_METHODS = [:notify_number , :sleeping_seconds]
    DEFAULT_OUT    = STDOUT
    #
    #
    def initialize(config)
      @config = {}
      config.each_pair do |key, value|
        @config[key.to_sym] = value.dup
      end
    end
    #
    #
    def pstore_path(name)
      File.join(method_missing("pstore_path"), "#{name}.pstore")
    end
    #
    #
    def method_missing(method , *args)
      value = @config[method.to_sym]
      unless value
        begin
          value = self.class.const_get("DEFAULT_" + method.to_s.upcase)
        rescue NameError => e
          raise NameError.new("No Such Config : #{method}")
        end
      end
      TO_INT_METHODS.include?(method) ? value.to_i : value
    end
  end
end
