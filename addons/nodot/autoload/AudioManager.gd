## An autoloader to manager audio buses and volume
extends Node

var master_audiobus: Array[String] = ["Master"]
var music_audiobus: Array[String] = ["Music"]
var sfx_audiobus: Array[String] = ["SFX"]

var master_volume: float = 0.0: set = _set_master_volume
var music_volume: float = 0.0: set = _set_music_volume
var sfx_volume: float = 0.0: set = _set_sfx_volume

signal master_volume_changed(new_volume: float)
signal music_volume_changed(new_volume: float)
signal sfx_volume_changed(new_volume: float)

func _ready():
	for bus in master_audiobus: _set_bus_volume(bus, master_volume)
	for bus in music_audiobus: _set_bus_volume(bus, music_volume)
	for bus in sfx_audiobus: _set_bus_volume(bus, sfx_volume)
	
	if SaveManager.config.hasItem("master_volume"):
		master_volume = SaveManager.config.getItem("master_volume")
	if SaveManager.config.hasItem("music_volume"):
		music_volume = SaveManager.config.getItem("music_volume")
	if SaveManager.config.hasItem("sfx_volume"):
		sfx_volume = SaveManager.config.getItem("sfx_volume")
		
func _set_bus_volume(bus_name: String, volume: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, volume)

func _set_master_volume(new_volume: float):
	master_volume = new_volume
	for bus in master_audiobus: _set_bus_volume(bus, master_volume)
	emit_signal("master_volume_changed", master_volume)
	
func _set_music_volume(new_volume: float):
	music_volume = new_volume
	for bus in music_audiobus: _set_bus_volume(bus, music_volume)
	emit_signal("music_volume_changed", music_volume)
	
func _set_sfx_volume(new_volume: float):
	sfx_volume = new_volume
	for bus in sfx_audiobus: _set_bus_volume(bus, sfx_volume)
	emit_signal("sfx_volume_changed", sfx_volume)
	
func _convert_decimal_volume(decimal: float):
	return -80 + (86 * decimal)
	
func _convert_volume(volume: float):
	return (volume + 80) / 86

func set_master_volume(new_volume: float):
	master_volume = new_volume
	
func set_music_volume(new_volume: float):
	music_volume = new_volume
	
func set_sfx_volume(new_volume: float):
	sfx_volume = new_volume
	
func set_master_volume_decimal(new_volume: float):
	set_master_volume(_convert_decimal_volume(new_volume))
	
func set_music_volume_decimal(new_volume: float):
	set_music_volume(_convert_decimal_volume(new_volume))
	
func set_sfx_volume_decimal(new_volume: float):
	set_sfx_volume(_convert_decimal_volume(new_volume))
	
func add_master_bus(bus_name: String):
	master_audiobus.append(bus_name)
	
func add_music_bus(bus_name: String):
	music_audiobus.append(bus_name)
	
func add_sfx_bus(bus_name: String):
	sfx_audiobus.append(bus_name)

func save_config():
	SaveManager.config.setItem("master_volume", master_volume)
	SaveManager.config.setItem("music_volume", music_volume)
	SaveManager.config.setItem("sfx_volume", sfx_volume)
	SaveManager.save_config()
