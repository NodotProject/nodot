class_name FirstPersonItemsContainer extends Node3D

## Whether the ItemContainer is enabled
@export var enabled: bool = true
## The character the viewport is attached to
@export var character: FirstPersonCharacter
## The input action name for reloading the current active weapon
@export var reload_action: String = "reload"

signal item_change(item: FirstPersonItem)
signal item_scroll(item_index: int)
signal item_actioned(cooldown: float)

var item_changing: bool = false
var is_item_active: bool = true
var active_item_index: int = 0
var carry_ended: bool = false

func _ready() -> void:
	# Move existing children to be a child of the camera
	for child in get_children():
		if child is FirstPersonItem:
			child.connect("discharged", func ():
				emit_signal("item_actioned", child.magazine_node.fire_rate)
				)
				
	GlobalSignal.add_listener("carry_ended", self, "on_carry_ended")
	
func _input(event: InputEvent) -> void:
	if not character.is_authority(): return
	
	if get_input():
		reload()
		
func _physics_process(delta: float) -> void:
	action()
		
func get_input():
	return InputMap.has_action(reload_action) and Input.is_action_pressed(reload_action)

## Select the next item
func next_item() -> void:
	var next_valid_index := iterate_item(-1)
	if next_valid_index >= 0:
		GlobalSignal.trigger_signal("item_scroll", next_valid_index)
		change_item(next_valid_index)

## Select the previous item
func previous_item() -> void:
	var next_valid_index := iterate_item(1)
	if next_valid_index >= 0:
		GlobalSignal.trigger_signal("item_scroll", next_valid_index);
		change_item(next_valid_index)
	
## Iterate the items list
func iterate_item(direction: int) -> int:
	var items: Array = get_all_items()
	var items_size: int = items.size()
	var current_index := (active_item_index + direction + items_size) % items_size
	var checked_items := 0

	while checked_items < items_size:
		if items[current_index].unlocked:
			return current_index
		current_index = (current_index + direction + items_size) % items_size
		checked_items += 1

	return -1  # Return -1 if no unlocked item is found after checking all items
	
func on_carry_ended(_body):
	if !enabled: return
	carry_ended = true
	await get_tree().create_timer(0.5).timeout
	carry_ended = false

## Get the active item if there is one
## TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162
func get_active_item():
	if not character.is_authority(): return
	
	var items = Nodot.get_children_of_type(self, FirstPersonItem)
	for item in items:
		if item.active:
			return item

## Get all FirstPersonItems
func get_all_items() -> Array:
	return Nodot.get_children_of_type(self, FirstPersonItem)

## Change which item is active.
func change_item(new_index: int) -> void:
	if new_index == active_item_index: return;
	var items: Array = get_all_items()
	var item_count: int = items.size()
	if item_count == 0: return
	if item_changing == true: return
	if not items[new_index].unlocked: return
	item_changing = true
	
	# Total item count is placeholder till all items are implemented
	if new_index >= item_count - 1:
		active_item_index = item_count - 1
	elif new_index <= 0:
		active_item_index = 0
	else:
		active_item_index = new_index
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item:
		await (active_item as FirstPersonItem).deactivate()

	if is_item_active and active_item_index < items.size():
		await items[active_item_index].activate()

	item_changing = false
	if active_item_index < item_count:
		emit_signal("item_change", items[active_item_index])

func activate_current_item():
	is_item_active = true;
	var items: Array = get_all_items();

func deactivate_current_item():
	is_item_active = false;
	var items: Array = get_all_items();
	var item_count: int = items.size();
	if active_item_index < item_count:
		await (items[active_item_index] as FirstPersonItem).deactivate();
		
func unlock_item(item_index: int):
	var items: Array = get_all_items()
	if items.size() <= item_index: return
	items[item_index].unlocked = true
	
func lock_item(item_index: int):
	var items: Array = get_all_items()
	if items.size() <= item_index: return
	items[item_index].unlocked = false

func action():
	var mouse_action = character.input_states.get("mouse_action")
	match mouse_action:
		"next_item":
			next_item()
		"previous_item":
			previous_item()
		"action":
			discharge()
		"release_action":
			release_action();
		"zoom":
			zoom()
		"zoomout":
			zoomout()

func discharge() -> void:
	if !enabled: return
	if carry_ended: return
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("action"):
		(active_item as FirstPersonItem).action()

func release_action() -> void:
	if !enabled: return
	if carry_ended:
		carry_ended = false
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("release_action"):
		(active_item as FirstPersonItem).release_action()


func zoom() -> void:
	if !enabled: return
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("zoom"):
		(active_item as FirstPersonItem).zoom()

func zoomout() -> void:
	if !enabled: return
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("zoomout"):
		(active_item as FirstPersonItem).zoomout()

func reload() -> void:
	if !enabled: return
	
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("reload"):
		(active_item as FirstPersonItem).reload()
