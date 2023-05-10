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
## Fade speed
@export var fade_speed: float = 1.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var original_volume = volume_db

func _enter_tree() -> void:
	if trigger_signal == "" or !trigger_node: return
	
	if unbind_count > 0:
		trigger_node.connect(trigger_signal, action.unbind(unbind_count))
	else:
		if !trigger_node.is_connected(trigger_signal, action):
			trigger_node.connect(trigger_signal, action)


## Loads, caches and plays the audio file at the path argument. Use `sfx_root_path` to prefix the path.
func action(index: int = -1) -> void:
	var sfx_size: int = sfx.size()
	if sfx_size <= 0: return
	
	var stream: AudioStream = sfx[0]
	if index >= 0:
		stream = sfx[index]
	else:
		var random_index: int = rng.randi_range(0, sfx_size - 1)
		stream = sfx[random_index]

	set_stream(stream)
	play()

## Fade the sound effect in
func fade_in(index: int = -1):
	if !stream_paused and playing == false: action()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", original_volume, fade_speed)
	stream_paused = false
	tween.play()

## Fade the sound effect out
func fade_out(pause_on_finish: bool = false, index: int = -1):
	if playing == false: return
	var tween = get_tree().create_tween()
	if pause_on_finish:
		tween.connect("finished", func():
			stream_paused = true
		)
	else:
		tween.connect("finished", stop)
	tween.tween_property(self, "volume_db", -80, fade_speed)
	tween.play()
