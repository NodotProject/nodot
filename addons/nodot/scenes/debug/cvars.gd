extends Node


const HELP_DICT := {
	"world":"The current World, which is the root of the level.",
	"hit":"The collider the camera ray is colliding with, is null if none is found.",
	"hitPos":"The point the camera ray is colliding, is null if none is found.",
	"userDir":"Globalized user:// directory.",
	"gameMgr":"Returns GameManager singleton",
	"gvar":"Global variables dictionary. See setgvar() for setting vars. {key:value}",
	"pl":"Gets the currently controlled Player.",
	"v3x":"Vector3.RIGHT equivalent",
	"v3y":"Vector3.UP equivalent",
	"v3z":"Vector3.BACK equivalent",
	"echo(var)":"Displays the variable input on the console.",
	"loop(expression, times, delay)":"Does the expression 'n' times with a delay between each call. Expression needs to be put \"in quotes\".",
	"load(path)":"Loads the resource at the given filepath.",
	"setGravity(value)":"Sets the physics gravity.",
	"giveWeapon(weapon_name, player)":"Gives a weapon to the player. Non-specified Player defaults to currently controlled.",
	"spawnPlayer(position)":"Spawns a player at the given position. If none is given, defaults to hitPos.",
	"spawnNode(node, parent)":"Adds the node as a child of parent. If no parent is given, it defaults to world.",
	"setTimescale(value)":"Sets the timescale or speed of the engine. 0.5 is half speed, 2.0 is double speed. Capped to 10.",
	"clear()":"Clears the console output.",
	"reload()":"Reloads the current scene.",
	"quit()":"Quits the game.",
	"setgvar(key, value)":"Sets a a key:value pair of the gvar dictionary",
	"openDir(dir)":"Opens the specified directory in the system file explorer.",
	"loadFromFile(filename)":"Loads data from a file saved in 'userData/console_out'. WARNING: Loads objects, meaning code can be executed. Don't load files from untrusted sources.",
	"saveToFile(filename, data)":"Saves file as specified filename in 'userData/console_out/', stores data as a var with objects encoded."
}


var userDir = ProjectSettings.globalize_path("user://")
const v3x := Vector3.RIGHT
const v3y := Vector3.UP
const v3z = Vector3.BACK




func setsafe(a) -> void:
	DebugManager.console.safe_mode = a


func echo(variable):
	DebugManager.console.add_console_message(":: "+str(variable), Color.GRAY)
	return variable


func loop(expression : String, times : int, delay : float) -> void:
	var new_expression = Expression.new()
	new_expression.parse(expression)
	DebugManager.console.add_console_message("Started loop %s (%s times in %s seconds)" % [expression, times, times * delay], Color.YELLOW)
	for i in times:
		DebugManager.console.add_console_message("loop %s : %s / %s (%ss / %ss)" % [expression, i+1, times, (i + 1) * delay, times * delay], Color.DIM_GRAY)
		new_expression.execute([], self, false, DebugManager.console.safe_mode)
		if new_expression.get_error_text() != "":
			DebugManager.console.add_console_message(new_expression.get_error_text(), Color.YELLOW)
			return
		await get_tree().create_timer(delay).timeout
	DebugManager.console.add_console_message("Loop %s ran %s times in %s seconds" % [expression, times, times * delay], Color.YELLOW)


func setGravity(value:float)->void:
	if DebugManager.console.warn_restricted("setGravity()"):return
	ProjectSettings.set_setting("physics/3d/default_gravity", value)


@warning_ignore("shadowed_global_identifier")
func load(path : String):
	if DebugManager.console.warn_restricted("load()"):return
	var res = load(path)
	if res == null:
		DebugManager.console.add_console_message("Failed to load %s" % path, Color.LIGHT_CORAL)
		return res
	DebugManager.console.add_console_message("Loaded %s" % path, Color.GREEN)
	return res


func setTimescale(value : float = 1.0) -> void:
	if DebugManager.console.warn_restricted("setTimescale()"):return
	Engine.time_scale = clamp(value, 0.0, 10.0)
	DebugManager.console.add_console_message("Set timescale to %s (%s%%)" % [Engine.time_scale, 100 * Engine.time_scale], Color.DIM_GRAY)


func debugDraw(mode : Viewport.DebugDraw) -> void:
	if DebugManager.console.safe_mode:
		if not mode in [0, 1]:
			DebugManager.console.add_console_message("debugDraw limited in safe mode.", Color.LIGHT_CORAL)
			DebugManager.console.add_console_message("Available modes: 0, 1", Color.LIGHT_CORAL)
			return
	DebugManager.console.add_console_message("Set debug_draw to %s" % mode, Color.DIM_GRAY)
	get_tree().get_root().get_viewport().debug_draw = mode


func clear() -> void:
	DebugManager.console.clear()


func reload() -> void:
	get_tree().reload_current_scene()
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func quit() -> void:
	get_tree().quit()

func pause() -> void:
	if DebugManager.console.warn_restricted("pause()"):return
	if get_tree().paused == false:
		DebugManager.console.add_console_message("SceneTree paused.", Color.DIM_GRAY)
		get_tree().paused = true
		return
	DebugManager.console.add_console_message("SceneTree is already paused.", Color.DIM_GRAY)


func unpause() -> void:
	if DebugManager.console.warn_restricted("unpause()"):return
	if get_tree().paused == true:
		DebugManager.console.add_console_message("SceneTree resumed.", Color.DIM_GRAY)
		get_tree().paused = false
		return
	DebugManager.console.add_console_message("SceneTree is already unpaused.", Color.DIM_GRAY)


func openDir(dir : String) -> void:
	OS.shell_open(dir)


func loadFromFile(filename : String):
	if DebugManager.console.warn_restricted("loadFromFile()"):return
	var dir = (userDir + "/console_out/").simplify_path()
	if !DirAccess.dir_exists_absolute(dir):
		DebugManager.console.add_console_message("Directory 'console_out' does not exist in user://", Color.LIGHT_CORAL)
		return
	dir += "/"+filename
	var fa = FileAccess.open(dir, FileAccess.READ)
	if fa == null:
		DebugManager.console.add_console_message("Failed to open file %s" % [dir], Color.LIGHT_CORAL)
		return
	DebugManager.console.add_console_message("Load success!", Color.GREEN)
	var data = fa.get_var(true)
	DebugManager.console.add_console_message("Data: %s" % [data], Color.GRAY)
	return data


func saveToFile(filename : String, data) -> void:
	var dir = (userDir + "/console_out/").simplify_path()
	if !DirAccess.dir_exists_absolute(dir):
		if DirAccess.make_dir_absolute(dir) != OK:
			DebugManager.console.add_console_message("Failed to create directory 'console_out' in user://", Color.LIGHT_CORAL)
			DebugManager.console.add_console_message("Try openUserDir() and adding a 'console_out' folder to the folder opened.", Color.LIGHT_CORAL)
			return
	var fa = FileAccess.open("user://console_out/"+filename, FileAccess.WRITE)
	if fa == null:
		DebugManager.console.add_console_message("Failed to open file %s" % [filename], Color.LIGHT_CORAL)
		return
	fa.store_var(data, true)
	fa.close()
	DebugManager.console.add_console_message("Save success!", Color.GREEN)
	DebugManager.console.add_console_message("Path: %s" % [dir], Color.GRAY)
	DebugManager.console.add_console_message("Data: %s" % [data], Color.GRAY)
	return


func help() -> void:
	DebugManager.console.add_console_message("-- Help Menu --", Color.DIM_GRAY)
	await get_tree().create_timer(0.2).timeout
	DebugManager.console.add_console_message("-- Available vars --", Color.LIGHT_CORAL)
	await get_tree().create_timer(0.2).timeout
	for key in HELP_DICT:
		if (key as String).contains("("):
			continue
		DebugManager.console.add_rich_console_message("[color=light_coral]%s[/color]: %s" % [key, HELP_DICT[key]])
		await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	DebugManager.console.add_console_message("-- Available methods --", Color.LIGHT_SKY_BLUE)
	await get_tree().create_timer(0.2).timeout
	for key in HELP_DICT:
		if !(key as String).contains("("):
			continue
		DebugManager.console.add_rich_console_message("[color=light_sky_blue]%s[/color]: %s" % [key, HELP_DICT[key]])
		await get_tree().process_frame
	DebugManager.console.add_console_message("For detailed help on a specific method, type _help(\"method\")", Color.DIM_GRAY)


func _help(method : String = "") -> void:
	match method:
		"spawnNode":
			DebugManager.console.add_rich_console_message("[color=light_coral]func [/color][color=light_sky_blue]spawnNode[/color](node : [color=medium_spring_green]Node[/color], parent : [color=medium_spring_green]Node[/color]) -> [color=medium_spring_green]Node[/color]:")
			DebugManager.console.add_console_message("Calls 'add_child' on the 'parent' node, passing in the 'node'.\nIf no 'parent' node is provided, it defaults to 'world'.\nReturns the provided 'node'.", Color.GRAY)
			return
		"":
			DebugManager.console.add_console_message("Please provide a method. Example : help(\"spawnNode\")", Color.LIGHT_CORAL)
			return
	#Detailed help wasn't provided for this.
	DebugManager.console.add_console_message("Detailed help for this method not found, or the method doesn't exist.", Color.LIGHT_CORAL)
