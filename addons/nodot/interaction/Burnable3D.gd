## Allows 
class_name Burnable3D extends Nodot

## Enable the burnable3d node
@export var enabled: bool = true
## The target to detect collisions
@export var target: RigidBody3D
## Automatically ignite the target on spawn
@export var auto_ignite: bool = false
## Permanently at full effect and spreadable
@export var permanent: bool = false
## The time it takes before the effect start to spread
@export var time_to_spread: float = 1.0
## The time it takes for the fire effect to reach maximum
@export var time_to_full_effect: float = 2.0
## The time it takes to burn out from full effect (also stops spreading)
@export var time_to_burnout: float = 5.0
## (optional) The health node to apply damage
@export var health_node: Health
## (optional) Damage per second (0 for none) (health_node is required)
@export var damage_per_second: float = 0.0
## (optional) A Fire3D node to control fire effects
@export var fire3d_node: Fire3D
## (optional) the maximum effect scale for the fire3d_node (fire3d_node is required)
@export var full_effect_scale: float = 1.0

## The burnable has been ignited
signal ignite_started
## Spreading is now enabled
signal spreading_enabled
## The fire has been spread to another body
signal spreading_to(body: RigidBody3D)
## The fires full effect has been reached
signal full_effect_reached
## The fire has burned out
signal burned_out
## Triggered each physics frame containing a percentage (between 0-1.0) of total progress
signal burn_progress(progress: float)

var ignited: bool = false
var non_burnables: Array[Node] = []
var spreadable: bool = false
var burning_timer: float = 0.0
var damage_tick: float = 0.0
var effect_scale_percentage: float = 0.0
var is_full_effect: bool = false

func _ready():
	if enabled and auto_ignite:
		action()

func _physics_process(delta):
	if !enabled:
		return
		
	if ignited:
		burning_timer += delta
		if time_to_spread > burning_timer:
			if !spreadable:
				spreadable = true
				spreading_enabled.emit()
			
		if time_to_full_effect > burning_timer:
			effect_scale_percentage = burning_timer / time_to_full_effect
		elif time_to_burnout > burning_timer:
			if !is_full_effect:
				full_effect_reached.emit()
			if !permanent:
				effect_scale_percentage = 1.0 - ((burning_timer - time_to_full_effect) / (time_to_burnout - time_to_full_effect))
		elif !permanent:
			enabled = false
			reset()
			burned_out.emit()
			
		if fire3d_node:
			fire3d_node.effect_scale = full_effect_scale / 100 * (effect_scale_percentage * 100)
		
		damage_tick += delta
		if damage_tick > 1.0 and is_instance_valid(health_node):
			damage_tick = 0.0
			health_node.add_health(-damage_per_second)
		
		if !permanent:
			burn_progress.emit(burning_timer / time_to_burnout)
		
	if ignited and (spreadable or permanent):
		var bodies = target.get_colliding_bodies()
		for body in bodies:
			if !non_burnables.has(body):
				var burnable = Nodot.get_first_child_of_type(body, Burnable3D)
				if burnable and burnable.enabled and !burnable.ignited:
					spreading_to.emit(body)
					burnable.action()
				else:
					non_burnables.append(body)
		
func action():
	if enabled:
		ignited = true
		ignite_started.emit()

func reset():
	ignited = false
	spreadable = false
	burning_timer = 0.0
	effect_scale_percentage = 0.0
	is_full_effect = false
	damage_tick = 0.0
	if fire3d_node:
		fire3d_node.effect_scale = 0.0
