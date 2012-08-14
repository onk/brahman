require "time"
require "logger"
require "yaml"
require "fileutils"
require "rexml/document"
require "brahman/version"
require "brahman/commit_log"
require "brahman/mergeinfo"
require "brahman/config"

module Brahman
  # action
  #   :list
  #   :merge
  #   :diff
  #   :mergeinfo_clean
  def self.run(action, args)
    @@log = Logger.new(STDOUT)
    @@log.level = args[:verbose] ? Logger::DEBUG : Logger::INFO
    @@config = Config.load
    self.send(action, args)
  end

  def self.config
    @@config
  end

  def self.log
    @@log
  end

  def self.list(args)
    if args[:revisions]
      revs = Mergeinfo.str_to_list(args[:revisions])
    else
      log.debug "fetch mergeinfo ..."
      revs = Mergeinfo.mergeinfo(config.parent_url)
      log.debug "fetch mergeinfo done."
    end

    revs.each do |rev|
      begin
        log.debug "fetch commitlog #{rev} ..."
        puts CommitLog.new(rev.chomp, config.parent_url).to_s
      rescue
        next
      end
    end
  end

  def self.merge(args)
    raise "-r revision is required" unless args[:revisions]

    revs = Mergeinfo.str_to_list(args[:revisions])
    revs.each do |rev|
      log.debug "merge #{rev} ..."
      puts `svn merge --accept postpone -c #{rev} #{config.parent_url}`
      raise unless $?.success?
    end
  end

  def self.mergeinfo_clean(args)
    raise "-r revision:revision is required" unless args[:revisions]

    from, to = args[:revisions].split(":")
    raise "-r revision:revision is required" unless (from and to)

    log.debug "fetch mergeinfo ..."
    not_merged_revisions = Mergeinfo.mergeinfo(config.parent_url).map(&:to_i)
    log.debug "fetch mergeinfo done."

    full_arr = (from.to_i .. to.to_i).to_a

    puts Mergeinfo.hyphenize(full_arr - not_merged_revisions)
  end

end

