@icon("../icons/accordion.svg")
## A button to expand children inside of it on click
class_name Accordion extends Control

## Whether the accordion starts collapsed or not
@export var collapsed: bool = true
## The speed that the accordion expands/collapses
@export var collapse_speed: float = 5.0
## The text to show on the expand button
@export var show_button_text: String = "Show"
## The icon to show on the expand button
@export var show_button_icon: Texture2D = load("res://addons/nodot/icons/plus.svg")

## Triggered when the accordion begins to expand
signal expand_started(node: Accordion)
## Triggered when the accordion begins to collapse
signal collapse_started(node: Accordion)
## Triggered when an accordion begins to expand or collapse
signal animation_started(node: Accordion)

var show_button: Button
var vbox: VBoxContainer

var target_size: Vector2 = Vector2.ZERO

func _enter_tree():
	show_button = Button.new()
	show_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	show_button.text = show_button_text
	if show_button_icon:
		show_button.icon = show_button_icon
		show_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		show_button.expand_icon = true
	add_child(show_button)
	
	vbox = VBoxContainer.new()
	add_child(vbox)
	
	show_button.connect("pressed", toggle)
	connect("child_entered_tree", _child_enter_tree)

func _ready():
	for child in get_children():
		if child != show_button and child != vbox:
			child.reparent(vbox)
	
	clip_contents = true
	var size = get_rect().size
	
	var button_size = show_button.get_rect().size
	if show_button_icon:
		button_size = Vector2(button_size.x + 32.0, button_size.y)
		show_button.set_size(button_size)
	
	vbox.position.y = button_size.y
	var new_size = Vector2.ZERO
	if collapsed:
		new_size = Vector2(max(size.x, button_size.x), get_collapsed_height())
	else:
		new_size = Vector2(max(size.x, button_size.x), get_full_height())
	set_size(new_size)
	target_size = new_size
	
func _process(delta):
	var current_size = get_rect().size
	if target_size != current_size:
		var new_size = lerp(current_size, target_size, collapse_speed * delta)
		set_size(new_size)

## Expand the accordion
func expand():
	set_height(get_full_height())
	collapsed = false
	emit_signal("expand_started", self)
	emit_signal("animation_started", self)
	
## Collapse the accordion
func collapse():
	set_height(get_collapsed_height())
	collapsed = true
	emit_signal("collapse_started", self)
	emit_signal("animation_started", self)

## Expand if the accordion is collapsed and visa versa
func toggle():
	if collapsed:
		expand()
	else:
		collapse()

## Set the target height of the accordion
func set_height(new_height: float):
	target_size = Vector2(get_rect().size.x, new_height)

## Get the collapsed height of the accordion
func get_collapsed_height():
	return show_button.get_rect().size.y

## Get the expanded height of the accordion
func get_full_height():
	var button_height = get_collapsed_height()
	return button_height + vbox.get_rect().size.y

func _child_enter_tree(child: Node):
	if child != show_button and child != vbox:
		child.reparent(vbox)
