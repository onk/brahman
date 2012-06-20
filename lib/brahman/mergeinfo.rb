module Brahman
  class Mergeinfo
    # mergeinfo string to list
    #
    # あいまいな入力も受け付け
    # * m-n を展開し
    # * r を取り除いて
    # 配列にして返す
    def self.str_to_list(mergeinfo)
      mergeinfo.split(',').map{|e|
        if e =~ /-/
          min,max = e.delete("r").split("-")
          (min..max).to_a
        else
          e
        end
      }.flatten.map{|rev|
        rev.delete("r")
      }.sort
    end

    def self.mergeinfo(parent_path)
      `svn mergeinfo --show-revs eligible #{parent_path}`.split("\n").map{|rev|
        rev = rev.chomp
        rev.delete("r")
      }.sort
    end
  end
end

