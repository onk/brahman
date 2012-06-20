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

    # 数字が連続する場合にその箇所をハイフンにする
    def self.hyphenize(nums)
      nums.inject([]) { |arr, n| arr[n-1] = n; arr }
      .chunk { |n| !n.nil? || nil }
      .map { |_, gr| gr.size > 1 ? "#{gr.first}-#{gr.last}" : "#{gr.first}" }
      .join(', ') + '.'
    end
  end
end

