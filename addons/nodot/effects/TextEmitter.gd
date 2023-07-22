## Used to briefly show text in a 3D space
class_name TextEmitter extends Nodot3D

## Enable or disable the emitter
@export var enabled: bool = true
## The color of the text
@export var font_color: Color = Color.WHITE
## The size of the text
@export var font_size: int = 18
## The time in seconds before the text disappears
@export var despawn_time: float = 0.0
## The direction the text moves in
@export var move_direction: Vector3 = Vector3.UP
## The speed the text moves at
@export var move_speed: float = 1.0


func _physics_process(delta: float) -> void:
	if !enabled:
		return

	var speed: float = move_speed * delta
	for child in get_children():
		var position_modifier: Vector3 = move_direction * speed
		child.position += position_modifier


## Emits a label3D with the text passed in
func action(text: String) -> void:
	if !enabled:
		return

	var label3d: Label3D = Label3D.new()

	label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label3d.fixed_size = true
	label3d.no_depth_test = true
	label3d.text = text
	label3d.font_size = font_size
	label3d.modulate = font_color

	add_child(label3d)

	if despawn_time > 0.0:
		await get_tree().create_timer(despawn_time, false).timeout
		label3d.queue_free()
