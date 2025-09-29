extends Node3D

# Demo script for PreviewBody3D functionality
# This would normally be attached to a scene demonstrating the preview system


func _ready():
	print("PreviewBody3D Demo Scene Ready")

	# Find the source body and preview nodes
	var source_body = get_node("SourceBody")
	var preview_body = get_node("PreviewBody3D")

	if source_body and preview_body:
		# Set up the preview
		preview_body.source_body = source_body
		preview_body.transparency = 0.7
		preview_body.color_tint = Color.CYAN
		preview_body.collision_mode = 1  # Bounding box

		print("Preview configured successfully!")
		print("Source body: ", source_body.name)
		print("Preview visible: ", preview_body.is_preview_visible())

		# Demonstrate toggling
		await get_tree().create_timer(2.0).timeout
		preview_body.hide_preview()
		print("Preview hidden")

		await get_tree().create_timer(1.0).timeout
		preview_body.show_preview()
		print("Preview shown again")
	else:
		print("Could not find required nodes for demo")


func _input(event):
	if event.is_action_pressed("ui_accept"):
		var preview_body = get_node("PreviewBody3D")
		if preview_body:
			if preview_body.is_preview_visible():
				preview_body.hide_preview()
				print("Preview hidden (manual)")
			else:
				preview_body.show_preview()
				print("Preview shown (manual)")
