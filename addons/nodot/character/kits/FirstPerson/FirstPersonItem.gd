@tool
@icon("../../icons/first_person_item.svg")
## An item used in first person games. i.e sword, gun, hands.
class_name FirstPersonItem extends Nodot3D

## If the weapon is allowed to be used or not
@export var unlocked: bool = true
## If the weapon is visible or not
@export var active: bool = false
## (optional) The mesh of the weapon
@export var mesh: Mesh
@export var magazine_node: Magazine
## (optional) A hitscan node
@export var hitscan_node: HitScan3D
## (optional) A project emitter node
@export var projectile_emitter_node: ProjectileEmitter3D
@export var bullethole_node: BulletHole

## Triggered when the item is activated
signal activated
## Triggered when the item is deactivated
signal deactivated
signal discharged

## Not exported as FirstPersonIronSight must be a child node of the FirstPersonItem
var ironsight_node: FirstPersonIronSight
var crosshair_node: CrossHair

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonItemsContainer):
		warnings.append("Parent should be a FirstPersonItemsContainer")
	return warnings


func _ready() -> void:
	ironsight_node = Nodot.get_first_child_of_type(self, FirstPersonIronSight)
	magazine_node = Nodot.get_first_child_of_type(self, Magazine)
	hitscan_node = Nodot.get_first_child_of_type(self, HitScan3D)
	projectile_emitter_node = Nodot.get_first_child_of_type(self, ProjectileEmitter3D)
	bullethole_node = Nodot.get_first_child_of_type(self, BulletHole)
	crosshair_node = Nodot.get_first_child_of_type(self, CrossHair)

	connect_magazine()

	if mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		add_child(mesh_instance)

	if active:
		activate()
	else:
		deactivate()
		
	if magazine_node:
		magazine_node.connect("discharged", func():
			discharged.emit()
			)

## Async function to activate the weapon. i.e animate it onto the screen.
func activate() -> void:
	active = true
	visible = true
	for child in get_children():
		if child.has_method("activate"):
			child.activate()
	activated.emit()


## Async function to deactivate the weapon. i.e animate it off of the screen.
func deactivate() -> void:
	active = false
	for child in get_children():
		if child.has_method("deactivate"):
			await child.deactivate()
	visible = false
	deactivated.emit()


## Triggered when the item is fired (i.e on left click to fire weapon)
func action() -> void:
	if magazine_node:
		magazine_node.action()

	for child in get_children():
		if child.has_method("action_performed"):
			await child.action_performed()

## Triggered when the item fire is released (i.e on left click release)
func release_action() -> void:
	if magazine_node:
		magazine_node.release_action()

## Triggered when the zoom/ironsight button is pressed
func zoom() -> void:
	if ironsight_node:
		ironsight_node.zoom()


## Triggered when the zoom/ironsight button is released
func zoomout() -> void:
	if ironsight_node:
		ironsight_node.zoomout()


## Triggered when the player requests that the item be reloaded
func reload():
	if magazine_node:
		magazine_node.reload()


## Connect the magazine events to the hitscan node
func connect_magazine() -> void:
	if magazine_node:
		if hitscan_node:
			magazine_node.connect("discharged", func():
				hitscan_node.action.rpc(magazine_node.discharge_count, magazine_node.charge_amount)
				)
		if projectile_emitter_node:
			magazine_node.connect("discharged", projectile_emitter_node.action)
	if hitscan_node and bullethole_node:
		hitscan_node.connect("target_hit", bullethole_node.action)
