## SaveManager node
## [br]
## This node is for testing (is not complete)
## [br] - if you want use this, the script of "node" must have:
## [br]     * init_load 
## [br]     * to_save
## [br] - "to_save" must return are Dictonary
##
## all must are Dictonary in two func [br]
## (this class is alone to test, have errors)
class_name SaveManager extends Node3D

signal load_archive(PATH: String)
signal save_archive(PATH: String)

@export_category("Node to load")
## specify direction for add when is load game
@export_node_path("Node3D") var add_node_to_load

@export_category("Nodes to save")
## Create a "character" for the scene
@export var character_scene : PackedScene

## clear all node with tag "save_archive"
func _clear_nodes() -> void:
	for node in get_tree().get_node_in_group("save_archive"):
		node.free()

func _ready():
	self.connect("load_archive", self._load_archive)
	self.connect("save_archive", self._save_archive)

## Save the archive
func _save_archive(PATH:String) -> void:
	# Localize the archive
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	
	for node in get_tree().get_nodes_in_group("save_archive"):
		# Check if has method, but is faild, then print a error
		if node.has_method("to_save"):
			file.store_line(JSON.stringify(node.to_save(), "\t"))
			file.close()
		else: 
			print_debug("- A error has being ocurred, ", node.name, " not have function: //to_save_json//")

## Load archives
func _load_archive(PATH:String) -> void:
	if not FileAccess.file_exists(PATH):
		print_debug("File not found in the path: ", PATH)
		return
	
	_clear_nodes()
	var file = FileAccess.open(PATH, FileAccess.READ)
	#Create nodess
	while not file.eof_reached():
		var line = file.get_line()
		
		if not line == "":
			var node = character_scene.instantiate()
			# check if node has method for init the node
			if node.has_method("init_json"):
				node.init_load(JSON.parse_string(line))
				$master.add_child(add_node_to_load)
				node.owner = $master
			else:
				print_debug("- A error has being ocurred, ", node.name, " not have function: //init_load// or 
				\n the date is incorrect (read documentation)")
	file.close()