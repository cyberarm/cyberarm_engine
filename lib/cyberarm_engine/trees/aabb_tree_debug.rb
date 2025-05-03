# frozen_string_literal: true

module CyberarmEngine
  # Gets included into AABBTree
  module AABBTreeDebug
    def inspect
      @branches = 0
      @leaves = 0
      if @root
        node = @root

        debug_search(node.a)
        debug_search(node.b)
      end

      puts "<#{self.class}:#{object_id}> has #{@branches} branches and #{@leaves} leaves"
    end

    def debug_search(node)
      if node.leaf?
        @leaves += 1
      else
        @branches += 1
        debug_search(node.a)
        debug_search(node.b)
      end
    end
  end
end
