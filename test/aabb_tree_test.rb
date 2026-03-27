require "minitest/autorun"

require_relative "../lib/cyberarm_engine/vector"
require_relative "../lib/cyberarm_engine/ray"
require_relative "../lib/cyberarm_engine/bounding_box"
require_relative "../lib/cyberarm_engine/trees/aabb_tree_debug"
require_relative "../lib/cyberarm_engine/trees/aabb_node"
require_relative "../lib/cyberarm_engine/trees/aabb_tree"

class AABBTreeTest < Minitest::Test
  def test_remove_clears_the_root_when_the_last_leaf_is_deleted
    tree = CyberarmEngine::AABBTree.new
    object = Object.new
    box = CyberarmEngine::BoundingBox.new(0, 0, 0, 1, 1, 1)

    tree.insert(object, box)
    tree.remove(object)

    assert_nil tree.root
    assert_empty tree.objects
    assert_empty tree.search(box)
  end

  def test_update_replaces_the_existing_leaf_instead_of_leaking_duplicates
    tree = CyberarmEngine::AABBTree.new
    object = Object.new
    old_box = CyberarmEngine::BoundingBox.new(0, 0, 0, 1, 1, 1)
    new_box = CyberarmEngine::BoundingBox.new(10, 10, 10, 11, 11, 11)

    tree.insert(object, old_box)
    tree.update(object, new_box)

    assert_empty tree.search(old_box)
    assert_equal [object], tree.search(new_box)
  end

  def test_update_can_be_called_multiple_times_for_the_same_object
    tree = CyberarmEngine::AABBTree.new
    object = Object.new
    first_box = CyberarmEngine::BoundingBox.new(0, 0, 0, 1, 1, 1)
    second_box = CyberarmEngine::BoundingBox.new(10, 10, 10, 11, 11, 11)
    third_box = CyberarmEngine::BoundingBox.new(20, 20, 20, 21, 21, 21)

    tree.insert(object, first_box)
    tree.update(object, second_box)
    tree.update(object, third_box)

    assert_equal 1, tree.objects.size
    assert_empty tree.search(first_box)
    assert_empty tree.search(second_box)
    assert_equal [object], tree.search(third_box)
  end
end
