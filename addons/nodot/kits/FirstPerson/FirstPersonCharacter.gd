## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled := true
## The camera field of view
@export var fov := 75.0
## Minimum amount of fall damage before it is actually applied
@export var minimum_fall_damage: float = 5.0
## The amount of fall damage to inflict when hitting the ground at velocity (0 for disabled)
@export var fall_damage_multiplier: float = 0.5

## Triggered when the character takes fall damage
signal fall_damage(amount: float)

var head: Node3D
var health: Health
var submerge_handler: CharacterSwim3D
var inventory: CollectableInventory
var was_on_floor: bool = false
var floor_body: Node3D;
# Velocity of the previous frame
var previous_velocity: float = 0.0
# Peak velocity of the last 0.1 seconds
var peak_recent_velocity: Vector3 = Vector3.ZERO
var peak_recent_velocity_timer: float = 0.0
var character_colliders: UniqueSet = UniqueSet.new()
var terminal_velocity := 190.0

func _enter_tree() -> void:
	if !sm:
		sm = StateMachine.new()
		add_child(sm)
	
	if !has_node("Head"):
		head = Node3D.new()
		head.name = "Head"
		camera.name = "Camera3D"
		head.add_child(camera)
		add_child(head)

	submerge_handler = Nodot.get_first_child_of_type(self, CharacterSwim3D)
	inventory = Nodot.get_first_child_of_type(self, CollectableInventory)
	health = Nodot.get_first_child_of_type(self, Health)
	
	PlayerManager.players.add(self)
	if NetworkManager.enabled:
		set_multiplayer_authority(1)


func _ready() -> void:
	camera.fov = fov

	if has_node("Head"):
		head = get_node("Head")
		camera = get_node("Head/Camera3D")
	
	if is_authority() and is_current_player:
		set_current_player()
		
	if has_method("_after_ready"):
		call("_after_ready")

func _physics_process(delta: float) -> void:
	peak_recent_velocity_timer += delta
	if peak_recent_velocity_timer > 0.05:
		peak_recent_velocity_timer = 0.0
	else:
		var max_velocity = max(abs(velocity.x), abs(velocity.y), abs(velocity.z))
		var old_max_velocity = max(abs(peak_recent_velocity.x), abs(peak_recent_velocity.y), abs(peak_recent_velocity.z))
		if old_max_velocity < max_velocity:
			peak_recent_velocity = cap_velocity(velocity)
		else:
			peak_recent_velocity = lerp(peak_recent_velocity, Vector3.ZERO, delta)
	
	var on_floor = _is_on_floor() != null
	if !health or fall_damage_multiplier <= 0.0:
		was_on_floor = on_floor
		floor_body = _is_on_floor();
		return
	
	if !was_on_floor:
		floor_body = null;
		if on_floor:
			var falling_velocity = abs(previous_velocity)
			var damage = falling_velocity * fall_damage_multiplier
			if damage > minimum_fall_damage:
				health.add_health(-damage)
				fall_damage.emit(damage)
		else:
			previous_velocity = velocity.y
	was_on_floor = on_floor

func _is_current_player_changed(new_value: bool):
	is_current_player = new_value
	input_enabled = new_value
	
## Add collectables to collectable inventory
func collect(node: Node3D) -> bool:
	if not is_host(): return false
	if !inventory: return false
	return inventory.add(node.display_name, node.quantity)

## Set the character as the current player
func set_current_player():
	is_current_player = true
	PlayerManager.node = self
	set_current_camera(camera)

func cap_velocity(velocity: Vector3) -> Vector3:
	# Check if the velocity exceeds the terminal velocity
	if velocity.length() > terminal_velocity:
		# Cap the velocity to the terminal velocity, maintaining direction
		return velocity.normalized() * terminal_velocity
	else:
		# If it's below terminal velocity, return it unchanged
		return velocity
