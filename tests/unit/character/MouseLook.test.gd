extends VestTest
## Mouse-look feel: InputManager's look model (units, invert, zoom matching, cm/360, legacy
## save conversion), FirstPersonCharacter.rotate_look (pitch clamp), and FirstPersonMouseInput
## applying EVERY motion event immediately from screen_relative.
##
## The FirstPersonMouseInput cases are the regression for the original bug: the handler stored
## each event with `=` and consumed it once per physics tick, so when several events landed in
## one tick (any frame rate above the physics rate) all but the last were dropped; it also read
## the stretch-scaled `relative`, so sensitivity changed with the window size.

const _KEYS := ["mouse_sensitivity", "mouse_y_scale", "invert_mouse_y", "ads_sensitivity_scale", "mouse_dpi"]
const _EPS := 1e-6

var _saved := {}
var _character: FirstPersonCharacter
var _mouse: FirstPersonMouseInput

func before_case(_case) -> void:
	for k in _KEYS:
		_saved[k] = InputManager.get(k)
	InputManager.reset_mouse_settings()

func after_case(_case) -> void:
	for k in _saved:
		InputManager.set(k, _saved[k])
	if _character != null:
		if _mouse != null:
			_mouse.disable()
		_character.queue_free()
		_character = null
		_mouse = null

func _rad_per_count() -> float:
	return deg_to_rad(InputManager.YAW_DEG_PER_COUNT) * InputManager.mouse_sensitivity

func _spawn_character(with_mouse: bool) -> void:
	_character = FirstPersonCharacter.new()
	if with_mouse:
		_mouse = FirstPersonMouseInput.new()
		_character.add_child(_mouse)
	(Engine.get_main_loop() as SceneTree).root.add_child(_character)

func _motion(screen_rel: Vector2, rel: Vector2) -> InputEventMouseMotion:
	var ev := InputEventMouseMotion.new()
	ev.screen_relative = screen_rel
	ev.relative = rel
	return ev

func test_look_radians_uses_source_units() -> void:
	var r := InputManager.look_radians(Vector2(100, 50))
	expect_true(absf(r.x - 100 * _rad_per_count()) < _EPS, "100 counts = 100 x sens x 0.022 deg")
	expect_true(absf(r.y - 50 * _rad_per_count()) < _EPS, "vertical uses the same scale by default")

func test_invert_and_vertical_scale() -> void:
	InputManager.invert_mouse_y = true
	InputManager.mouse_y_scale = 0.5
	var r := InputManager.look_radians(Vector2(0, 100))
	expect_true(absf(r.y + 50 * _rad_per_count()) < _EPS, "inverted, half-speed vertical")

func test_zoom_factor_matches_tan_ratio() -> void:
	expect_equal(InputManager.zoom_factor(75.0, 75.0), 1.0, "no zoom = 1")
	var k := tan(deg_to_rad(15.0)) / tan(deg_to_rad(37.5))
	expect_true(absf(InputManager.zoom_factor(30.0, 75.0) - k) < _EPS, "0% monitor-distance match")
	InputManager.ads_sensitivity_scale = 2.0
	expect_true(absf(InputManager.zoom_factor(30.0, 75.0) - 2.0 * k) < _EPS, "ADS multiplier applies when zoomed")
	expect_true(absf(InputManager.zoom_factor(74.99, 75.0) - 1.0) < 0.01, "continuous at the resting FOV (no step as sights ease in)")

func test_cm_per_360() -> void:
	InputManager.mouse_sensitivity = 1.5
	expect_true(absf(InputManager.cm_per_360(800) - 2.54 * 360.0 / (800.0 * 1.5 * 0.022)) < 0.001)

func test_legacy_conversion() -> void:
	var converted := InputManager.legacy_to_source_scale(0.2)
	expect_true(converted > 0.0, "legacy value converts to a positive Source-scale sensitivity")

func test_rotate_look_clamps_to_a_pure_pitch() -> void:
	_spawn_character(false)
	_character.rotate_look(0.0, 100.0)
	expect_true(absf(_character.head.rotation.x - FirstPersonCharacter.PITCH_LIMIT) < _EPS, "parked at the upper limit")
	expect_true(absf(_character.head.rotation.y) < _EPS and absf(_character.head.rotation.z) < _EPS, "no yaw/roll at the pole")
	_character.rotate_look(0.0, -0.1)
	expect_true(absf(_character.head.rotation.x - (FirstPersonCharacter.PITCH_LIMIT - 0.1)) < _EPS, "moves off the pole by exactly the delta")
	_character.rotate_look(10.0 * PI + 0.25, 0.0)
	expect_true(absf(_character.rotation.y) <= PI + _EPS, "yaw stays wrapped")

func test_mouse_input_counts_every_event_immediately() -> void:
	_spawn_character(true)
	var yaw0 := _character.rotation.y
	for i in 6:
		_mouse._input(_motion(Vector2(10, 0), Vector2(10, 0)))
	var turned := -angle_difference(yaw0, _character.rotation.y)
	expect_true(absf(turned - 60 * _rad_per_count()) < _EPS,
		"6 events in one tick all turn the view, before any physics tick (turned %f, expected %f)" % [turned, 60 * _rad_per_count()])

func test_mouse_input_ignores_stretched_relative() -> void:
	_spawn_character(true)
	var yaw0 := _character.rotation.y
	# What a 1080p window makes of `relative` with a 1152x648 base and canvas_items stretch.
	_mouse._input(_motion(Vector2(100, 0), Vector2(100, 0) / 1.6667))
	var turned := -angle_difference(yaw0, _character.rotation.y)
	expect_true(absf(turned - 100 * _rad_per_count()) < _EPS, "turn follows screen_relative counts")

func test_mouse_input_is_zoom_matched() -> void:
	_spawn_character(true)
	_character.camera.fov = 30.0
	var yaw0 := _character.rotation.y
	_mouse._input(_motion(Vector2(100, 0), Vector2(100, 0)))
	var turned := -angle_difference(yaw0, _character.rotation.y)
	var k := tan(deg_to_rad(15.0)) / tan(deg_to_rad(_character.fov * 0.5))
	expect_true(absf(turned - 100 * _rad_per_count() * k) < _EPS, "scoped turn scaled by the zoom ratio")
