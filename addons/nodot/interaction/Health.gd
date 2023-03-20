class_name Health extends Nodot

## The maximum health
@export var max_health := 100
## The current health
@export var current_health := max_health

## current_health has reached zero
signal health_depleted
## current_health has been reduced
signal health_lost(old_health: int, new_health: int)
## current_health has been increased
signal health_gained(old_health: int, new_health: int)
## current_health has changed
signal health_changed(old_health: int, new_health: int)

## Offsets current_health by the modifier
func set_health(modifier: int):
  if modifier == 0: return
  var old_health = current_health
  var new_health = current_health + modifier
  if new_health <= 0:
    current_health = 0
    emit_signal("health_depleted")
  else:
    if new_health > max_health:
      current_health = max_health
    else:
      current_health = new_health
      
    if modifier < 0:
      emit_signal("health_lost", old_health, new_health)
    else:
      emit_signal("health_gained", old_health, new_health)
  emit_signal("health_changed", old_health, new_health)
