class_name TextEmitter extends Node3D

@export var enabled : bool = true
@export var font_color : Color = Color.WHITE
@export var font_size : int = 18
@export var despawn_time : float = 0.0
@export var move_direction : Vector3 = Vector3.UP
@export var move_speed : float = 1.0

func _physics_process(delta: float) -> void:
  if !enabled:
    return

  var speed: float = move_speed * delta
  for child in get_children():
    var position_modifier: Vector3 = move_direction * speed
    child.position += position_modifier

func action(text: String) -> void:
  if !enabled:
    return

  var sprite3d: Sprite3D = Sprite3D.new()
  var viewport: SubViewport = SubViewport.new()
  var label: Label = Label.new()

  viewport.add_child(label)
  sprite3d.add_child(viewport)

  sprite3d.texture = viewport.get_texture()
  sprite3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
  sprite3d.fixed_size = true
  sprite3d.no_depth_test = true
  sprite3d.pixel_size = 0.0033

  viewport.disable_3d = true
  viewport.transparent_bg = true
  viewport.handle_input_locally = false

  label.text = text
  label.anchors_preset = Control.PRESET_FULL_RECT
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.add_theme_font_size_override("font_size", font_size)
  label.add_theme_color_override("font_color", font_color)

  add_child(sprite3d)

  if despawn_time > 0.0:
    await get_tree().create_timer(despawn_time).timeout
    sprite3d.queue_free()
