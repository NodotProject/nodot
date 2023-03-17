class_name Magazine extends Nodot

## A magazine (for example, a gun magazine or crossbow) that can be used to manage ammunition and fire rates

## Total rounds per magazine
@export var capacity := 10
## Rounds available other than the loaded rounds
@export var supply_count := 20
## Round supply maximum
@export var supply_count_limit := 100
## Total rounds released per action
@export var dispatch_count := 1
## Time between round releases
@export var fire_rate := 0.5
## Time to reload the magazine
@export var reload_time := 1.0
## Automatically reloads the weapon when ammo has depleted and the player attempts to fire
@export var auto_reload := true
## Number of rounds currently loaded
@export var rounds_left := capacity

## Emitted when there are no rounds left in the chamber
signal magazine_depleted
## Emitted when there is no supply left at all
signal supply_depleted
## Emitted when the magazine begins reloading
signal reloading
## Emitted when a round is dispatched
signal dispatched

var time_since_last_fired = 0
var time_since_last_reload = 0

func _physics_process(delta):
  # Safely limit how big these numbers can get
  if time_since_last_fired < fire_rate * 2: time_since_last_fired += delta
  if time_since_last_reload < reload_time * 2: time_since_last_reload += delta

## Dispatches a round
func action():
  # Return if reloading
  if time_since_last_reload < reload_time: return
  
  # If there are enough rounds left in the chamber
  if rounds_left - dispatch_count < 0:
    if auto_reload: reload()
    emit_signal("magazine_depleted")
  # Otherwise fire
  elif time_since_last_fired >= fire_rate:
    rounds_left -= dispatch_count
    emit_signal("dispatched")
    if supply_count < dispatch_count:
      emit_signal("supply_depleted")
    time_since_last_fired = 0

## Initiates a reload of the magazine
func reload():
  if time_since_last_reload >= reload_time:
    var rounds_required = capacity - rounds_left
    if rounds_required > 0 and supply_count >= rounds_required:
      supply_count -= rounds_required
      rounds_left = capacity
      time_since_last_reload = 0
      emit_signal("reloading")      
