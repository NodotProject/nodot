## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled := true
## The camera field of view
@export var fov := 75.0
## The head position
@export var head_position := Vector3.ZERO


@export_category("Input Actions")
## The input action name for pausing the game
@export var escape_action: String = "escape"

## Triggered when the game is paused
signal paused
## Triggered when the game is unpaused
signal unpaused

var head: Node3D
var camera: Camera3D = Camera3D.new()
var submerge_handler: CharacterSwim3D
var inventory: CollectableInventory


func _enter_tree() -> void:
	if is_current_player:
		PlayerManager.node = self
		set_current_camera(camera)
		
	if !sm:
		sm = StateMachine.new()
		add_child(sm)
		
	head = Node3D.new()
	head.name = "Head"
	camera.name = "Camera3D"
	head.add_child(camera)
	add_child(head)

	submerge_handler = Nodot.get_first_child_of_type(self, CharacterSwim3D)
	inventory = Nodot.get_first_child_of_type(self, CollectableInventory)
	


func _ready() -> void:
	camera.fov = fov

	if has_node("Head"):
		head = get_node("Head")
		camera = get_node("Head/Camera3D")

	if has_node("HeadPosition"):
		var head_position_node: Node = get_node("HeadPosition")
		head.position = head_position_node.position
		head_position_node.queue_free()
	else:
		head.position = head_position

func _physics_process(delta: float) -> void:
	var collision = get_last_slide_collision()
	if collision:
		for i in collision.get_collision_count():
			var collider = collision.get_collider(i)
			if collider and collider.has_method("_on_character_collide"):
				collider._on_character_collide(self)
	

func _input(event: InputEvent) -> void:
	if !event.is_action_pressed(escape_action): return
	if input_enabled:
		pause()
	else:
		unpause()


## Pause the game
func pause():
	input_enabled = false
	InputManager.disable()
	emit_signal("paused")


## Unpause the game
func unpause():
	input_enabled = true
	InputManager.enable()
	emit_signal("unpaused")

## Add collectables to collectable inventory
func collect(node: Node3D) -> bool:
	if !inventory: return false
	return inventory.add(node.display_name, node.quantity)
