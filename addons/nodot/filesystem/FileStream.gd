class_name FileStream extends Node

@export_file var file_path: String = "user://data.dat"
@export var read_chunk_size: int = 5

signal write_queue_empty
signal read_completed

var write_queue: Array = []
var write_thread: Thread = null
var queue_mutex: Mutex = Mutex.new()
var queue_semaphore: Semaphore = Semaphore.new()
var exit_thread: bool = false
var read_in_progress: bool = false

func write(data: Variant) -> void:
	if write_thread == null:
		write_thread = Thread.new()
		write_thread.start(_write_worker.bind(file_path))
	queue_mutex.lock()
	write_queue.append(data)
	queue_mutex.unlock()
	queue_semaphore.post()

func read(read_callback: Callable):
	read_in_progress = true
	var read_chunks: Array = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		read_completed.emit()
		read_in_progress = false
		return
	while true:
		var chunk = []
		for i in range(read_chunk_size):
			var file_var = file.get_var(true)
			if file.eof_reached():
				break
			if file_var != null:
				chunk.append(file_var)
		if chunk.is_empty():
			break
		read_chunks.append_array(chunk)
	file.close()
	read_callback.call(read_chunks)
	read_in_progress = false
	read_completed.emit()

func _write_worker(local_file_path):
	var file = FileAccess.open(local_file_path, FileAccess.WRITE_READ)
	file.seek_end()
	
	while true:
		queue_semaphore.wait()
		if exit_thread:
			break
		queue_mutex.lock()
		var data = null
		if write_queue.size() > 0:
			data = write_queue.pop_front()
		queue_mutex.unlock()
		if data != null:
			file.store_var(data)
			file.flush()
		queue_mutex.lock()
		var is_empty = write_queue.is_empty()
		queue_mutex.unlock()
		if is_empty:
			_emit_write_queue_empty.call_deferred()
	file.close()

func _emit_write_queue_empty() -> void:
	write_queue_empty.emit()

func wait_until_write_queue_empty() -> void:
	while true:
		queue_mutex.lock()
		var is_empty = write_queue.is_empty()
		queue_mutex.unlock()
		if is_empty:
			return
		await get_tree().process_frame

func wait_until_read_queue_empty() -> void:
	if not read_in_progress:
		return
	await read_completed

func finish():
	exit_thread = true
	queue_semaphore.post()
	if write_thread != null and write_thread.is_alive():
		write_thread.wait_to_finish()

func delete():
	var dir: DirAccess = DirAccess.open(file_path.get_base_dir())
	if dir != null and dir.file_exists(file_path):
		dir.remove(file_path)

func _exit_tree():
	finish()
