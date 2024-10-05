extends GutTest

var file_stream: FileStream
var write_error_occurred: bool = false

func before_each():
	# Create a new instance of FileStream and set the test file path
	file_stream = FileStream.new()
	file_stream.file_path = "user://test_1mb.dat"
	add_child(file_stream)
	# Delete the test file if it exists
	file_stream.delete()
	# Connect to write_error signal
	file_stream.connect("write_error", _on_write_error)
	write_error_occurred = false

func _on_write_error(message):
	write_error_occurred = true
	push_error("Write error: %s" % message)

func after_each():
	file_stream.finish()
	file_stream.delete()
	file_stream.free()
	file_stream = null

func test_read_write_1mb_of_data():
	# Step 1: Generate 1 MB of data
	var data_size = 1024 * 1024  # 1 MB
	var chunk_size = 1024        # 1 KB per chunk
	var num_chunks = data_size / chunk_size

	# Create an array to hold the data to write
	var data_to_write: Array = []
	var sample_data = String("a").repeat(chunk_size)  # 1 KB of 'a's

	for i in range(num_chunks):
		data_to_write.append(sample_data)

	# Step 2: Write data to the file stream
	for data in data_to_write:
		file_stream.write(data)

	# Step 3: Wait until all data has been written
	await file_stream.wait_until_write_queue_empty()

	# Check for write errors
	if write_error_occurred:
		push_error("Write error occurred during the test.")
		return

	# Step 4: Read data back from the file
	var read_data: Array = []
	file_stream.read(func(chunks):
		read_data.append_array(chunks)
	)

	await file_stream.wait_until_read_queue_empty()

	# Step 5: Verify that the data read matches the data written
	assert_eq(read_data.size(), data_to_write.size(), "Mismatch in number of chunks read.")

	# Optionally, you can verify the content of each chunk
	for i in range(read_data.size()):
		assert_eq(read_data[i], data_to_write[i], "Data mismatch at chunk %d" % i)
	
