module Brahman
  class Config
    attr_reader :parent_url

    def initialize(config)
      @config = config

      raise unless @config[:repository_url]
      raise unless @config[:parent_path]

      @parent_url = @config[:repository_url] + @config[:parent_path]
    end

    def cache_dir(parent_path = nil)
      parent_path ||= @config[:parent_path]
      File.join(Brahman::Config.cache_dir, parent_path)
    end

    def url_to_path(url)
      url.sub(@config[:repository_url], "")
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

