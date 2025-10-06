extends VestTest

var spray_pattern: SprayPattern

func before_case(_case) -> void:
	spray_pattern = SprayPattern.new()

func after_case(_case) -> void:
	spray_pattern.free()

func test_initial_properties() -> void:
	expect_not_null(spray_pattern.base_curve)
	expect_equal(spray_pattern.recovery_speed, 5.0)
	expect_equal(spray_pattern.apply_speed, 10.0)
	expect_equal(spray_pattern.randomness_pitch, 0.1)
	expect_equal(spray_pattern.randomness_yaw, 0.1)
	expect_equal(spray_pattern.reset_after_ms, 500)
	expect_false(spray_pattern.loop_pattern)
	expect_equal(spray_pattern.current_shot_index, 0)
	expect_equal(spray_pattern.current_offset, Vector2.ZERO)

func test_default_curve_creation() -> void:
	expect_not_null(spray_pattern.base_curve)
	expect_greater_than(spray_pattern.base_curve.point_count, 0)

func test_get_next_offset() -> void:
	capture_signal(spray_pattern.spray_offset_updated)
	
	var offset = spray_pattern.get_next_offset()
	expect_not_equal(offset, Vector2.ZERO)
	expect_equal(spray_pattern.current_shot_index, 1)
	expect_equal(get_signal_emissions(spray_pattern.spray_offset_updated).size(), 1)

func test_multiple_shots_progression() -> void:
	capture_signal(spray_pattern.spray_offset_updated)
	
	var first_offset = spray_pattern.get_next_offset()
	var second_offset = spray_pattern.get_next_offset()
	
	expect_equal(spray_pattern.current_shot_index, 2)
	expect_not_equal(first_offset, second_offset)
	expect_equal(get_signal_emissions(spray_pattern.spray_offset_updated).size(), 2)

func test_pattern_reset() -> void:
	capture_signal(spray_pattern.pattern_reset)
	
	# Fire some shots
	spray_pattern.get_next_offset()
	spray_pattern.get_next_offset()
	expect_equal(spray_pattern.current_shot_index, 2)
	
	# Reset pattern
	spray_pattern.reset_pattern()
	expect_equal(spray_pattern.current_shot_index, 0)
	expect_equal(get_signal_emissions(spray_pattern.pattern_reset).size(), 1)
	expect_true(spray_pattern.is_resetting)

func test_loop_pattern() -> void:
	spray_pattern.loop_pattern = true
	var curve = Curve2D.new()
	curve.add_point(Vector2(0.0, 0.1))
	curve.add_point(Vector2(1.0, 0.2))
	spray_pattern.base_curve = curve
	
	# Fire shots beyond curve length
	for i in range(5):
		spray_pattern.get_next_offset()
	
	expect_equal(spray_pattern.current_shot_index, 5)

func test_no_loop_pattern() -> void:
	spray_pattern.loop_pattern = false
	var curve = Curve2D.new()
	curve.add_point(Vector2(0.0, 0.1))
	curve.add_point(Vector2(1.0, 0.2))
	spray_pattern.base_curve = curve
	
	# Fire shots beyond curve length
	for i in range(5):
		spray_pattern.get_next_offset()
	
	expect_equal(spray_pattern.current_shot_index, 5)

func test_custom_curve() -> void:
	var custom_curve = Curve2D.new()
	custom_curve.add_point(Vector2(0.0, 0.5))
	custom_curve.add_point(Vector2(1.0, 1.0))
	
	spray_pattern.base_curve = custom_curve
	expect_equal(spray_pattern.base_curve, custom_curve)

func test_setter_validation() -> void:
	# Test recovery speed validation
	spray_pattern.recovery_speed = -1.0
	expect_equal(spray_pattern.recovery_speed, 0.0)
	
	# Test apply speed validation
	spray_pattern.apply_speed = 0.0
	expect_equal(spray_pattern.apply_speed, 0.1)
	
	# Test randomness validation
	spray_pattern.randomness_pitch = -0.5
	expect_equal(spray_pattern.randomness_pitch, 0.0)
	
	spray_pattern.randomness_yaw = -0.5
	expect_equal(spray_pattern.randomness_yaw, 0.0)
	
	# Test reset time validation
	spray_pattern.reset_after_ms = -100
	expect_equal(spray_pattern.reset_after_ms, 0)

func test_get_current_offset() -> void:
	var initial_offset = spray_pattern.get_current_offset()
	expect_equal(initial_offset, Vector2.ZERO)
	
	spray_pattern.get_next_offset()
	var after_shot_offset = spray_pattern.get_current_offset()
	expect_not_equal(after_shot_offset, Vector2.ZERO)

func test_get_current_shot_index() -> void:
	expect_equal(spray_pattern.get_current_shot_index(), 0)
	
	spray_pattern.get_next_offset()
	expect_equal(spray_pattern.get_current_shot_index(), 1)
	
	spray_pattern.get_next_offset()
	expect_equal(spray_pattern.get_current_shot_index(), 2)

func test_time_based_reset() -> void:
	capture_signal(spray_pattern.pattern_reset)
	
	# Fire a shot
	spray_pattern.get_next_offset()
	expect_equal(spray_pattern.current_shot_index, 1)
	
	# Simulate time passing (simulate _physics_process)
	spray_pattern.time_since_last_shot = spray_pattern.reset_after_ms + 1
	spray_pattern._physics_process(0.001)  # Small delta
	
	expect_equal(spray_pattern.current_shot_index, 0)
	expect_equal(get_signal_emissions(spray_pattern.pattern_reset).size(), 1)