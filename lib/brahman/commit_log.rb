module Brahman
  class CommitLog
    MAX_AUTHOR_LENGTH = 18

    def initialize(rev)
      xml_str = CommitLog.svn_log(rev)

      logentry = REXML::Document.new(xml_str).elements["/log/logentry"]
      @revision = logentry.attributes["revision"]
      @author = logentry.elements["author"].text
      @commit_at = Time.parse(logentry.elements["date"].text).localtime
      @message = logentry.elements["msg"].text
    end

    def to_s
      "* #{revision} | #{commit_at} | #{author} | #{message}"
    end

    def self.svn_log(rev)
      cache_path = File.join(Brahman::CACHE_DIR, rev)
      if File.exists?(cache_path)
        log = File.read(cache_path)
      else
        log = `svn log -c #{rev} --xml #{Brahman::TRUNK_PATH}`

        File.open(cache_path, "w") {|f| f.puts(log)}
      end
      log
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

