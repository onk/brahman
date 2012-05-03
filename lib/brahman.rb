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

  # action
  #   :list
  #   :merge
  def self.run(action, args)
    self.send(action, args)
  end

  def self.list(args)
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
      }.sort
    else
      revs = `svn mergeinfo --show-revs eligible #{TRUNK_PATH}`.split("\n").map{|rev|
        rev = rev.chomp
        rev.delete("r")
      }.sort
    end
    revs.each do |rev|
      begin
        puts CommitLog.new(rev.chomp).to_s
      rescue
        next
      end
    end
  end

  def self.merge(args)
    raise "-r revision is required" unless args[:revisions]

    puts `svn merge -c #{args[:revisions]} #{TRUNK_PATH}`
  end
end

