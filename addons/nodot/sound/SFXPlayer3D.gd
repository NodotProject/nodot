## A sound effect player with randomization and trigger options
class_name SFXPlayer3D extends AudioStreamPlayer3D

## An array of audiostreams chosen at random on action
@export var sfx: Array[AudioStream] = []
## (optional) A node containing a signal to trigger the sound effect
@export var trigger_node: Node
## (optional) The signal name fired from the "trigger_node"
@export var trigger_signal: String = ""
## Arguments to unbind from signal
@export var unbind_count: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
  if trigger_node:
    if unbind_count > 0:
      trigger_node.connect(trigger_signal, action.unbind(unbind_count))
    else:
      trigger_node.connect(trigger_signal, action)

## Loads, caches and plays the audio file at the path argument. Use `sfx_root_path` to prefix the path.
func action(index: int = -1) -> void:
  var sfx_size: int = sfx.size()
  if sfx_size > 0:
    var stream: AudioStream = sfx[0]
    if index >= 0:
      stream = sfx[index]
    else:
      var random_index: int = rng.randi_range(0, sfx_size - 1)
      stream = sfx[random_index]

    set_stream(stream)
    play()
