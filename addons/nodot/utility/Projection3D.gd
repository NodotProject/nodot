## Whatever 2D nodes are added to Projection3D are projected onto a plane
class_name Projection3D extends Nodot3D

## Width of the projection
@export var projection_size: Vector2 = Vector2(1.0, 0.66)
## Resolution of the projection
@export var resolution_size: Vector2 = Vector2(640, 480)

var plane_mesh = PlaneMesh.new()
var viewport = SubViewport.new()

func _enter_tree():
  var children = get_children()
  
  var mesh = MeshInstance3D.new()
  plane_mesh.size = projection_size
  plane_mesh.orientation = PlaneMesh.FACE_X
  mesh.mesh = plane_mesh
  add_child(mesh)
  
  var viewport_container = SubViewportContainer.new()
  viewport_container.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
  viewport.size = resolution_size
  viewport.transparent_bg = true
  viewport.disable_3d = true
  viewport.handle_input_locally = false
  viewport_container.add_child(viewport)
  add_child(viewport_container)
  
  for child in children:
    child.reparent(viewport)
  
func _ready():
  var material = StandardMaterial3D.new()
  material.albedo_texture = viewport.get_texture()
  plane_mesh.material = material
