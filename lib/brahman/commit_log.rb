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

    def self.package_fetch(min_rev, max_lev, parent_url)
      parent_path = Brahman.config.url_to_path(parent_url)
      Brahman.log.debug("svn log -r #{min_rev}:#{max_lev} --xml #{parent_url}")
      xml_str = `svn log -r #{min_rev}:#{max_lev} --xml #{parent_url}`
      log_xml = REXML::Document.new(xml_str).elements["/log"]

      return unless log_xml

      log_elms = log_xml.elements

      ((min_rev.to_i)..(max_lev.to_i)).each do |rev|
        cache_path = self.cache_path(rev, parent_path)
        FileUtils.mkdir_p(File.dirname(cache_path))

        log_elm = log_elms.detect{|elm|elm.attributes["revision"].to_i == rev}
        log = REXML::Element.new("log")
        if log_elm
          Brahman.log.debug("hit #{rev}")
          log.add_element(log_elm)
        else
          Brahman.log.debug("not hit #{rev}")
        end

        xml = REXML::Document.new
        xml << REXML::XMLDecl.new("1.0", "UTF-8")
        xml.add_element(log)
        formatter = REXML::Formatters::Default.new
        File.open(cache_path, "w") {|f| formatter.write(xml, f) }
      end
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

