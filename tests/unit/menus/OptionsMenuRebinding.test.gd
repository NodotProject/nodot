extends VestTest

## Covers the options menu's rebind prompt deciding whether an input event is a
## deliberate binding or something to keep waiting through.
##
## The prompt is an embedded GDScript on the controls GridContainer inside
## options_menu.tscn, so it is pulled off the packed scene's state here. Only
## resolve_binding() is exercised: it is deliberately free of node/tree access
## so the decision is testable without standing up the whole menu. The
## surrounding _input plumbing (erasing the column's old events, refreshing the
## button label, hiding the panel) still needs a live menu.

const OPTIONS_MENU := "res://addons/nodot/scenes/menus/options_menu.tscn"

const KEYBOARD_COLUMN := false
const JOYPAD_COLUMN := true

var prompt: GridContainer


func before_case(_case):
	var script := _keybindings_script()
	expect_true(script != null, "no node in the options menu carries the rebind prompt script")
	if script:
		prompt = script.new()


func after_case(_case):
	if prompt:
		prompt.free()
		prompt = null


## A .tscn's embedded sub-resources aren't addressable by path at runtime, so
## the script is read off the packed scene's state. Matched by the method it
## declares rather than by node path or sub-resource id, so moving or renaming
## either doesn't quietly turn this suite into a no-op.
func _keybindings_script() -> GDScript:
	var packed: PackedScene = load(OPTIONS_MENU)
	var state := packed.get_state()
	for node_index in state.get_node_count():
		for prop_index in state.get_node_property_count(node_index):
			if str(state.get_node_property_name(node_index, prop_index)) != "script":
				continue
			var script := state.get_node_property_value(node_index, prop_index) as GDScript
			if script == null:
				continue
			# has_method() would ask the GDScript *resource* what it can do, not
			# the class it declares - get_script_method_list() is the latter.
			for method in script.get_script_method_list():
				if method.name == "resolve_binding":
					return script
	return null


func _motion(axis: int, axis_value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	return event


func _key(keycode: Key, pressed: bool = true, echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	event.echo = echo
	return event


func _joy_button(button_index: int, pressed: bool = true) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = pressed
	return event


## A resting stick still emits small non-zero axis events, and the prompt used
## to consume the first one it saw.
func test_stick_drift_is_not_treated_as_a_binding():
	for drift in [0.01, 0.1, 0.3, 0.5, -0.4]:
		expect_true(
			prompt.resolve_binding(_motion(0, drift), JOYPAD_COLUMN).is_empty(),
			"an axis at %s is drift, not a deliberate bind" % drift
		)


func test_a_deliberate_deflection_binds_the_axis():
	var binding: Dictionary = prompt.resolve_binding(_motion(1, -1.0), JOYPAD_COLUMN)
	expect_equal(
		binding.get("source"),
		InputManager.INPUT_KEY_SOURCE.JOYPAD_MOTION,
		"a full deflection should bind as joypad motion"
	)
	expect_equal(binding.get("code"), 1, "the axis index should be bound")
	expect_equal(
		binding.get("value"),
		-1.0,
		"only the sign is kept - magnitude comes from the action's own deadzone"
	)


func test_a_deflection_is_normalised_to_the_sign_not_how_hard_it_was_pushed():
	var binding: Dictionary = prompt.resolve_binding(_motion(4, 0.8), JOYPAD_COLUMN)
	expect_equal(binding.get("value"), 1.0, "0.8 and 1.0 should bind identically")


## The keyboard column can't be reached by a controller at all, so drift can
## never disturb a keyboard binding regardless of the threshold.
func test_joypad_input_cannot_bind_the_keyboard_column():
	expect_true(
		prompt.resolve_binding(_motion(0, 1.0), KEYBOARD_COLUMN).is_empty(),
		"an axis should not bind the keyboard column"
	)
	expect_true(
		prompt.resolve_binding(_joy_button(0), KEYBOARD_COLUMN).is_empty(),
		"a joypad button should not bind the keyboard column"
	)


func test_keyboard_input_cannot_bind_the_joypad_column():
	expect_true(
		prompt.resolve_binding(_key(KEY_J), JOYPAD_COLUMN).is_empty(),
		"a key should not bind the joypad column"
	)


func test_key_press_binds_the_keyboard_column():
	var binding: Dictionary = prompt.resolve_binding(_key(KEY_J), KEYBOARD_COLUMN)
	expect_equal(
		binding.get("source"), InputManager.INPUT_KEY_SOURCE.KEYBOARD, "should bind as a key"
	)
	expect_equal(binding.get("code"), int(KEY_J), "the keycode should be bound")


## Releases and autorepeat used to end the prompt just like a press, so letting
## go of the key you'd just bound could immediately rebind over it.
func test_key_release_and_echo_are_ignored():
	expect_true(
		prompt.resolve_binding(_key(KEY_J, false), KEYBOARD_COLUMN).is_empty(),
		"a key release should not bind"
	)
	expect_true(
		prompt.resolve_binding(_key(KEY_J, true, true), KEYBOARD_COLUMN).is_empty(),
		"an autorepeat echo should not bind"
	)


func test_joypad_button_release_is_ignored():
	expect_true(
		prompt.resolve_binding(_joy_button(0, false), JOYPAD_COLUMN).is_empty(),
		"a joypad button release should not bind"
	)


func test_joypad_button_press_binds_the_joypad_column():
	var binding: Dictionary = prompt.resolve_binding(_joy_button(3), JOYPAD_COLUMN)
	expect_equal(
		binding.get("source"), InputManager.INPUT_KEY_SOURCE.JOYPAD, "should bind as a joypad button"
	)
	expect_equal(binding.get("code"), 3, "the button index should be bound")


func test_mouse_motion_never_binds_anything():
	var event := InputEventMouseMotion.new()
	expect_true(
		prompt.resolve_binding(event, KEYBOARD_COLUMN).is_empty(),
		"mouse motion should not bind the keyboard column"
	)
	expect_true(
		prompt.resolve_binding(event, JOYPAD_COLUMN).is_empty(),
		"mouse motion should not bind the joypad column"
	)
