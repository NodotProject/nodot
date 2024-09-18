class_name Replayer extends Node

@export var target_node: NodePath  # The node whose properties we want to capture
@export var properties_to_record: Array = ["position"]  # The properties to record (can be expanded)
@export var enable_hotkeys: bool = false

var file_stream: FileStream
var is_recording: bool = false
var is_replaying: bool = false
var start_time: int = 0  # To track the start of recording for relative timestamps

# Called when the node enters the scene tree
func _ready() -> void:
	# Create the FileStream node to handle data
	file_stream = FileStream.new()
	file_stream.file_path = "user://replay.dat"
	add_child(file_stream)
	
func _input(event: InputEvent) -> void:
	if !enable_hotkeys: return
	
	if event.is_action_just_pressed("record"):
		if is_recording:
			stop_recording()
		else:
			start_recording()
	if event.is_action_just_pressed("replay"):
		if is_replaying:
			stop_replay()
		else:
			start_replay()

# Start recording properties (every frame via _process)
func start_recording() -> void:
	is_recording = true
	file_stream.delete()  # Clear previous recordings
	start_time = Time.get_ticks_msec()  # Set the recording start time

# Stop recording properties
func stop_recording() -> void:
	is_recording = false

# Capture the target node's properties every frame
func _process(delta: float) -> void:
	if is_recording and has_node(target_node):
		var target = get_node(target_node)
		var data_to_record = {}
		
		# Store the selected properties
		for prop in properties_to_record:
			if target.has_method("get_" + prop):
				data_to_record[prop] = target.get(prop)
			elif target.has_property(prop):
				data_to_record[prop] = target.get(prop)

		# Store the relative timestamp to replay data in sequence
		data_to_record["timestamp"] = Time.get_ticks_msec() - start_time

		# Write the captured properties to the FileStream every frame
		file_stream.write_chunk([data_to_record])

# Start replaying recorded properties
func start_replay() -> void:
	is_replaying = true
	file_stream.read_chunk(_apply_chunk)

# Callback to apply a chunk of recorded properties
func _apply_chunk(chunk: Array) -> void:
	if has_node(target_node):
		var target = get_node(target_node)
		
		# Apply properties in the chunk to the target node
		for data in chunk:
			var timestamp = data.get("timestamp", 0)
			for prop in properties_to_record:
				if data.has(prop):
					target.set(prop, data[prop])

		# Simulate the delay between property captures based on timestamps
		if chunk.size() > 0:
			var delay = chunk[0]["timestamp"] - Time.get_ticks_msec() + start_time
			delay = max(delay, 0)
			# Schedule the next chunk application after the appropriate delay
			get_tree().create_timer(delay / 1000.0).connect("timeout", Callable(self, "start_replay"))

# Stop replaying recorded properties
func stop_replay() -> void:
	is_replaying = false
