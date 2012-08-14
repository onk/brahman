module Brahman
  class CommitLog
    MAX_AUTHOR_LENGTH = 18

    def initialize(rev, parent_url)
      xml_str = CommitLog.svn_log(rev, parent_url)

      logentry = REXML::Document.new(xml_str).elements["/log/logentry"]
      @revision = logentry.attributes["revision"]
      @author = logentry.elements["author"].text
      @commit_at = Time.parse(logentry.elements["date"].text).localtime
      @message = logentry.elements["msg"].text
    end

    def to_s
      "* #{revision} | #{commit_at} | #{author} | #{message}"
    end

    def self.svn_log(rev, parent_url)
      parent_path = Brahman.config.url_to_path(parent_url)
      cache_path = self.cache_path(rev, parent_path)
      if File.exists?(cache_path)
        log = File.read(cache_path)
      else
        log = `svn log -c #{rev} --xml #{parent_url}`
        FileUtils.mkdir_p(File.dirname(cache_path))
        File.open(cache_path, "w") {|f| f.puts(log)}
      end
      log
    end

    def self.cache_path(rev, parent_path)
      File.join(Brahman.config.cache_dir(parent_path), (rev.to_i/1000).to_s, rev.to_s)
    end

    private
    def revision
      "r" + @revision
    end

    def author
      @author + " " * (MAX_AUTHOR_LENGTH - @author.length)
    end

    def message
      if @message
        @message.split("\n").first
      end
    end

    def commit_at
      @commit_at.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end

