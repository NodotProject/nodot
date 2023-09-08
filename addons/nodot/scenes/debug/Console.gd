class_name Console extends Node


var usercommand_list : Array[String]
var command_copy_idx = -1
@onready var input_field = $window/control/panel/lineEdit
@onready var scroll : ScrollContainer = $window/control/panel/panel/scrollContainer
@onready var msgbox : VBoxContainer = $window/control/panel/panel/scrollContainer/ConsoleMessageContainer
@onready var console : Window = $window
@onready var cvars : Node = $cvars
var expression = Expression.new()
var safe_mode := false:
	set(value):
		if value:
			add_console_message("-- Console is now in safe mode --", Color.DIM_GRAY)
		else:
			add_console_message("-- Console left safe mode --", Color.DIM_GRAY)
		safe_mode = value


func _ready():
	console.hide()
	await get_tree().process_frame


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text != "" and usercommand_list[0] != new_text:
		usercommand_list.push_front(new_text)
	if usercommand_list.size() > 100:
		usercommand_list.pop_back()
	input_field.text = ""
	command_copy_idx = -1
	expression.parse(new_text)
	expression.execute([], cvars, false, safe_mode)
	if expression.get_error_text() != "":
		add_console_message(expression.get_error_text(), Color.YELLOW)


func add_console_message(message : String, color : Color = Color.WHITE) -> void:
	var new_label = Label.new()
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	new_label.modulate = color
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	print("c:"+message)
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func add_rich_console_message(message : String) -> void:
	var new_label = RichTextLabel.new()
	new_label.fit_content = true
	new_label.bbcode_enabled = true
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	new_label.text = message
	msgbox.add_child(new_label)
	if msgbox.get_child_count() > 300:
		msgbox.get_child(0).queue_free()
	print("c:"+message)
	await get_tree().process_frame
	scroll.scroll_vertical = 50000


func null_catch(variable) -> bool:
	if variable == null:
		DebugManager.console.add_console_message("Currently unavailable.", Color.LIGHT_CORAL)
	return variable == null


func _process(_delta: float) -> void:
	get_viewport().gui_disable_input = console.has_focus()


func warn_restricted(string : String) -> bool:
	if DebugManager.console.safe_mode:
		DebugManager.console.add_console_message("Cannot access '%s' in safe mode." % string, Color.LIGHT_CORAL)
		return true
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_console"):
		console.hide()
		await get_tree().process_frame
		console.show()
		console.grab_focus()
		input_field.grab_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_window_window_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_console"):
		console.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if input_field.has_focus() and event.is_pressed():
		if event.as_text() == "Up" and usercommand_list.size() > 0:
			command_copy_idx += 1
			command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
			input_field.text = usercommand_list[command_copy_idx]
			await get_tree().process_frame
			input_field.caret_column = input_field.text.length()
			return
		if event.as_text() == "Down" and usercommand_list.size() > 0:
			command_copy_idx -= 1
			command_copy_idx = clamp(command_copy_idx, 0, usercommand_list.size() - 1)
			input_field.text = usercommand_list[command_copy_idx]
			await get_tree().process_frame
			input_field.caret_column = input_field.text.length()
			return


func clear() -> void:
	for i in msgbox.get_children():
		i.queue_free()
	add_console_message("Console cleared.", Color.DIM_GRAY)


func _on_window_focus_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
