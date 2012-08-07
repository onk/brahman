require "time"
require "rexml/document"
require "brahman/version"
require "brahman/commit_log"
require "brahman/mergeinfo"

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
  #   :diff
  #   :mergeinfo_clean
  def self.run(action, args)
    self.send(action, args)
  end

  def self.list(args)
    revs = if args[:revisions]
             Mergeinfo.str_to_list(args[:revisions])
           else
             Mergeinfo.mergeinfo(TRUNK_PATH)
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

    revs = Mergeinfo.str_to_list(args[:revisions])
    puts `svn merge --accept postpone -c #{revs.join(',')} #{TRUNK_PATH}`
  end

  def self.mergeinfo_clean(args)
    raise "-r revision:revision is required" unless args[:revisions]

    from, to = args[:revisions].split(":")
    raise "-r revision:revision is required" unless (from and to)

    not_merged_revisions = Mergeinfo.mergeinfo(TRUNK_PATH).map(&:to_i)
    full_arr = (from.to_i .. to.to_i).to_a

    puts Mergeinfo.hyphenize(full_arr - not_merged_revisions)
  end

end

