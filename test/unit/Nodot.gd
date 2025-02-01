extends GutTest

func test_get_children_of_type():
  var parent = Node.new()
  var child1 = Node2D.new()
  var child2 = Node2D.new()
  var child3 = Node.new()
  parent.add_child(child1)
  parent.add_child(child2)
  parent.add_child(child3)
  
  var result = Nodot.get_children_of_type(parent, Node2D)
  assert_eq(result.size(), 2)
  assert_eq(result[0], child1)
  assert_eq(result[1], child2)

func test_get_first_child_of_type():
  var parent = Node.new()
  var child1 = Node2D.new()
  var child2 = Sprite2D.new()
  parent.add_child(child1)
  parent.add_child(child2)
  
  var result = Nodot.get_first_child_of_type(parent, Sprite2D)
  assert_true(result == child2)

func test_get_first_parent_of_type():
  var parent = Node2D.new()
  var child = Node.new()
  parent.add_child(child)
  
  var result = Nodot.get_first_parent_of_type(child, Node2D)
  assert_true(result == parent)

func test_get_siblings_of_type():
  var parent = Node.new()
  var child1 = Node2D.new()
  var child2 = Node2D.new()
  var child3 = Node.new()
  parent.add_child(child1)
  parent.add_child(child2)
  parent.add_child(child3)
  
  var result = Nodot.get_siblings_of_type(child1, Node2D)
  assert_eq(result.size(), 1)
  assert_eq(result[0], child2)

func test_get_first_sibling_of_type():
  var parent = Node.new()
  var child1 = Node2D.new()
  var child2 = Node.new()
  var child3 = Node2D.new()
  parent.add_child(child1)
  parent.add_child(child2)
  parent.add_child(child3)
  
  var result = Nodot.get_first_sibling_of_type(child1, Node2D)
  assert_eq(result, child3)

func test_free_all_children():
  var parent = Node.new()
  var child1 = Node2D.new()
  var child2 = Node.new()
  parent.add_child(child1)
  parent.add_child(child2)
  
  Nodot.free_all_children(parent)
  await get_tree().process_frame
  assert_eq(parent.get_child_count(), 0)

func test_toggle():
  var parent = Node2D.new()
  parent.visible = true
  
  Nodot.toggle(parent)
  assert_true(parent.visible == false)
  
  Nodot.toggle(parent)
  assert_true(parent.visible == true)