require "time"
require "rexml/document"
require "brahman/version"
require "brahman/commit_log"

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

end

