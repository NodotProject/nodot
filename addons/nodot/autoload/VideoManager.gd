## An autoloader to manage video settings
extends Node

var world_environments: Array[WorldEnvironment] = []
var subviewports: Array[SubViewport] = []

var display_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED: set = _set_display_mode
var screen: int = DisplayServer.window_get_current_screen(0): set = _set_screen
var fps_limit: int = Engine.max_fps: set = _set_fps_limit
var vsync: bool = DisplayServer.window_get_vsync_mode(0): set = _set_vsync
var msaa: Viewport.MSAA = 0: set = _set_msaa
var brightness: float = 1.0: set = _set_brightness
var contrast: float = 1.0: set = _set_contrast

## Triggered when the window is resized
signal window_resized

func _ready() -> void:
	get_tree().root.connect("size_changed", _on_window_resized)
	set_minimum_window_size()
	_on_window_resized()
	
	if SaveManager.config.hasItem("display_mode"):
		display_mode = SaveManager.config.getItem("display_mode")
	if SaveManager.config.hasItem("screen"):
		screen = SaveManager.config.getItem("screen")
	if SaveManager.config.hasItem("fps_limit"):
		fps_limit = SaveManager.config.getItem("fps_limit")
	if SaveManager.config.hasItem("vsync"):
		vsync = SaveManager.config.getItem("vsync")
	if SaveManager.config.hasItem("msaa"):
		msaa = SaveManager.config.getItem("msaa")
	if SaveManager.config.hasItem("brightness"):
		brightness = SaveManager.config.getItem("brightness")
	if SaveManager.config.hasItem("contrast"):
		contrast = SaveManager.config.getItem("contrast")
	
func _on_window_resized() -> void:
	var new_size: Vector2 = get_viewport().size
	emit_signal("window_resized", new_size)

func _set_display_mode(new_value: int):
	display_mode = new_value
	match display_mode:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		3: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		4: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

## Set the current monitor for the game
func _set_screen(index: int):
	screen = index
	DisplayServer.window_set_current_screen(screen, 0)
	
## Set the fps limit
func _set_fps_limit(limit: int):
	fps_limit = limit
	Engine.max_fps = fps_limit
	
## Set vertical sync
func _set_vsync(on: bool):
	vsync = on
	if on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
## Set MSAA settings
func _set_msaa(new_value: Viewport.MSAA):
	msaa = new_value
	var viewport = get_viewport()
	viewport.msaa_2d = msaa
	viewport.msaa_3d = msaa
	for subviewport in subviewports:
		subviewport.msaa_2d = msaa
		subviewport.msaa_3d = msaa
		
## Set brightness
func _set_brightness(new_value: float):
	brightness = new_value
	for world_environment in world_environments:
		world_environment.environment.adjustment_brightness = new_value
		
## Set contrast
func _set_contrast(new_value: float):
	contrast = new_value
	for world_environment in world_environments:
		world_environment.environment.adjustment_contrast = new_value
	
## Forces VideoManager to redeclare the window size
func bump() -> void:
	_on_window_resized()

## Get the number of monitors available
func get_screen_count() -> int:
	return DisplayServer.get_screen_count()

## Set minimum window size
func set_minimum_window_size(size: Vector2 = Vector2(1152, 648)):
	DisplayServer.window_set_min_size(size)

## Register a subviewport or worldenvironment for processing
func register(node: Node):
	if node is WorldEnvironment and !world_environments.has(node):
		world_environments.append(node)
	if node is SubViewport and !subviewports.has(node):
		subviewports.append(node)

## Save the video settings to the config file
func save_config():
	SaveManager.config.setItem("display_mode", display_mode)
	SaveManager.config.setItem("screen", screen)
	SaveManager.config.setItem("fps_limit", fps_limit)
	SaveManager.config.setItem("vsync", vsync)
	SaveManager.config.setItem("msaa", msaa)
	SaveManager.config.setItem("brightness", brightness)
	SaveManager.config.setItem("contrast", contrast)
	SaveManager.save_config()
