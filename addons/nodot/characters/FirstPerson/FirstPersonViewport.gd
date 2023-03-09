class_name FirstPersonViewport extends SubViewportContainer

func _enter_tree():
  var subviewport = SubViewport.new()
  subviewport.transparent_bg = true
  subviewport.handle_input_locally = false
  var camera3d = Camera3D.new()
  camera3d.cull_mask = 22049274 # Only layer 2
  subviewport.add_child(camera3d)
  add_child(subviewport)
  
