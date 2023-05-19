class_name Cursor extends Sprite2D

signal click(position: Vector2)

func _init():
	centered = false

func _input(event):
	if event is InputEventMouseButton:
		emit_signal("click", event.position)
	elif event is InputEventMouseMotion:
		position = event.position
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		visible = false
	else:
		visible = true
