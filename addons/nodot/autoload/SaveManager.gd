## Manages saving game data to the file system
extends Node

## On a successful file save
signal saved
## On a successful file load
signal loaded

var savers: Array[Saver] = []

## Register a saver node
func register_saver(saver_node: Saver):
  if !savers.has(saver_node):
    savers.append(saver_node)

## Unregister a saver node
func unregister_saver(saver_node: Saver):
  var index = savers.find(saver_node)
  savers.remove_at(index)

func save(slot: int = 0) -> void:
  var file_path = "user://save%s.sav" % slot
  var file = FileAccess.open(file_path, FileAccess.WRITE)
  var save_data: Dictionary = {}
  
  for saver in savers:
    var saver_data = saver.save()
    save_data[saver.get_instance_id()] = saver_data
    
  file.store_var(save_data)
  file.close()
  emit_signal("saved")

func load(slot: int = 0) -> void:
  var file_path = "user://save%s.sav" % slot
  if FileAccess.file_exists(file_path):
    var file := FileAccess.open(file_path, FileAccess.READ)
    var save_data = file.get_var(true)
    
    for saver_id in save_data:
      for saver in savers:
        if saver.get_instance_id() == saver_id:
          saver.load(save_data[saver_id])
    file.close()
    emit_signal("loaded")
