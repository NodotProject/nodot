## A magazine (for example, a gun magazine or crossbow) that can be used to manage ammunition and fire rates
class_name Magazine extends Nodot

## Total rounds per magazine
@export var capacity: int = 10
## Rounds available other than the loaded rounds (-1 for infinite)
@export var supply_count: int = 20
## Round supply maximum
@export var supply_count_limit: int = 100
## Total rounds released per action
@export var discharge_count: int = 1
## Time between round releases
@export var fire_rate: float = 0.5
## Time to reload the magazine
@export var reload_time: float = 1.0
## Automatically reloads the weapon when ammo has depleted and the player attempts to fire
@export var auto_reload: bool = true
## Number of rounds currently loaded
@export var rounds_left: int = capacity

## Emitted when there are no rounds left in the chamber
signal magazine_depleted
## Emitted when there is no supply left at all
signal supply_depleted
## Emitted when the magazine begins reloading
signal reloading
## Emitted when a round is discharged
signal discharged

var time_since_last_fired: float = fire_rate
var time_since_last_reload: float = reload_time


func _physics_process(delta: float) -> void:
	# Safely limit how big these numbers can get
	if time_since_last_fired < fire_rate * 2:
		time_since_last_fired += delta
	if time_since_last_reload < reload_time * 2:
		time_since_last_reload += delta


## Dispatches a round
func action() -> void:
	# Return if reloading
	if time_since_last_reload < reload_time:
		return

	# If there are enough rounds left in the chamber
	if rounds_left - discharge_count < 0:
		if auto_reload:
			reload()
		emit_signal("magazine_depleted")
	# Otherwise fire
	elif time_since_last_fired >= fire_rate:
		rounds_left -= discharge_count
		emit_signal("discharged")
		if supply_count != -1 and supply_count < discharge_count:
			emit_signal("supply_depleted")
		time_since_last_fired = 0


## Initiates a reload of the magazine
func reload() -> void:
	if time_since_last_reload < reload_time: return
	var rounds_required: int = capacity - rounds_left
	if supply_count != -1 and rounds_required <= 0 and supply_count < rounds_required: return
	if supply_count != -1:
		supply_count -= rounds_required
	rounds_left = capacity
	time_since_last_reload = 0
	emit_signal("reloading")


## Adds rounds to the supply and returns rejected rounds if the supply_count_limit has been reached
func resupply(amount: int) -> int:
	if supply_count == -1:
		return supply_count
		
	var new_supply: int = supply_count + amount
	if new_supply > supply_count_limit:
		supply_count = supply_count_limit
		return new_supply - supply_count_limit
	supply_count += amount
	return 0
