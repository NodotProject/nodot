## SaveManager node
## [br]
## This node is for testing (is not complete)
## [br] - if you want use this, the script of "node" must have:
## [br]     * init_load 
## [br]     * to_save_json
## [br] - "to_save_json" must return are Dictonary
##
## all must are Dictonary in two func [br]
## (this class is alone to test, have errors)
class_name SaveManager extends Node3D

## emitted when you load archive
signal load_archive(PATH: String)
## emitted when you save archive
signal save_archive(PATH: String)

@export_category("Direction node/scene")
## specify direction for add when is load game
@export var dir_save : Array[NodePath]
## Create a "character" for the scene
@export var dir_load_scene : Array[PackedScene]

##  clear all node with tag "save_archive"
func _clear_nodes() -> void:
	for node in get_tree().get_nodes_in_group("save_archive"):
		node.free()

func _ready():
	connect("load_archive", _load_archive)
	connect("save_archive", _save_archive)

##  Save the archive with  a "PATH"
func _save_archive(PATH:String) -> void:
	#  Localize the archive
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	
	for node in get_tree().get_nodes_in_group("save_archive"):
		#  Check if has method, but is faild, then print a error
		if node.has_method("to_save_json"):
			file.store_line(JSON.stringify(node.to_save_json()))
			file.close()
			print_debug("Succes create the save in: ", PATH)
		else: 
			#  Print if has error
			print_debug("- A error has being ocurred, ", node.name, " not have function: //to_save_json//")
	return

## Load archives with "PATH"
func _load_archive(PATH:String) -> void:
	#  Search archive, if not, return
	if not FileAccess.file_exists(PATH):
		print_debug("File not found in the path: ", PATH)
		return
	
	_clear_nodes()
	var file = FileAccess.open(PATH, FileAccess.READ)
	#Create nodess
	while not file.eof_reached():
		var line = file.get_line()
		
		for instance in len(dir_load_scene):
			
			var add_node_load = get_node(dir_save[instance])
			
			if not line == "":
				var node := dir_load_scene[instance].instantiate()
				# check if node has method for init the node
				if node.has_method("init_load"):
					node.init_load(JSON.parse_string(line))
					add_node_load.add_child(node)
					node.owner = add_node_load
					print_debug(" Succest load the save of: ", PATH)
				else:
					# Print if has error
					print_debug("- A error has being ocurred, ", node.name, " not have function: //init_load// or 
					the date is incorrect")
	file.close()
	return