class_name SFXPlayer3D extends AudioStreamPlayer3D

@export var sfx: Array[AudioStream] = []

var rng = RandomNumberGenerator.new()

## Loads, caches and plays the audio file at the path argument. Use `sfx_root_path` to prefix the path.
func action(index = -1):
  var sfx_size = sfx.size()
  if sfx_size > 0:
    var stream = sfx[0]
    if index == null:
      if sfx_size > 0:
        var random_index = rng.randi_range(0, sfx_size)
        stream = sfx[random_index]
    else:
      stream = sfx[index]
      
    set_stream(stream)
    play()
