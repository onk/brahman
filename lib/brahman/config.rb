module Brahman
  class Config
    attr_reader :parent_url, :cache_dir

    def initialize(config)
      raise unless config[:repository_url]
      raise unless config[:parent_path]

      @parent_url = config[:repository_url] + config[:parent_path]
      @cache_dir  = File.join(Brahman::Config::cache_dir, config[:parent_path])
    end

    def self.load
      Brahman::Config.new(load_config)
    end

    def self.load_config
      YAML.load_file(config_path)
    end

    def self.config_path
      ".brahman"
    end

    def self.cache_dir
      File.join(Dir.home, ".brahman")
    end
  end
end

