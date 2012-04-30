require "time"
require "rexml/document"
require "brahman/version"

module Brahman
  CASHE_DIR = ".svn_cache"
  unless File.exists?(CASHE_DIR)
    Dir.mkdir(CASHE_DIR)
  end
  trunk_file = File.join(CASHE_DIR, "trunk")
  if File.exists?(trunk_file)
    TRUNK_PATH = File.read(trunk_file)
  else
    raise "trunk not found"
  end

  def self.run(args)
    if args[:revisions]
      revs = args[:revisions].split(',').map{|e|
        if e =~ /-/
          min,max = e.delete("r").split("-")
          (min..max).to_a
        else
          e
        end
      }.flatten.map{|rev|
        rev.delete("r")
      }.sort.join("\n")
    else
      revs = `svn mergeinfo --show-revs eligible #{TRUNK_PATH}`.map{|rev|
        rev = rev.chomp
        rev.delete("r")
      }.sort.join("\n")
    end
    revs.each_line do |rev|
      begin
        puts CommitLog.new(rev.chomp).to_s
      rescue
        next
      end
    end
  end

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
      cache_path = File.join(CASHE_DIR, rev)
      if File.exists?(cache_path)
        log = File.read(cache_path)
      else
        log = `svn log -c #{rev} --xml #{TRUNK_PATH}`

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

