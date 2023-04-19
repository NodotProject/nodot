@icon("icons/nodot.svg")
class_name Nodot extends Node

static func get_children_of_type(parent: Node, type: Variant):
  var found_children = []
  for child in parent.get_children():
    if is_instance_of(child, type):
      found_children.append(child)
  return found_children
