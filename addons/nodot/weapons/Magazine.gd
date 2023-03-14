class_name Magazine extends Nodot

## A magazine (for example, a gun magazine) that can be used to manage ammunition and fire rates

## Total rounds per magazine
@export var capacity := 10
## Total rounds available
@export var total_count := 20
## Total round limit
@export var total_count_limit := 100
## Total rounds released per action
@export var dispatch_count := 1
## Time between round releases
@export var fire_rate := 0.5
## Time to reload the magazine
@export var reload_time := 1.0
