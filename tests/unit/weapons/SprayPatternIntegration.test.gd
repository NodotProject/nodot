extends VestTest

var spray_pattern: SprayPattern
var magazine: Magazine

func before_case(_case) -> void:
	spray_pattern = SprayPattern.new()
	magazine = Magazine.new()

func after_case(_case) -> void:
	spray_pattern.free()
	magazine.free()

func test_integration_with_magazine() -> void:
	capture_signal(spray_pattern.spray_offset_updated)
	
	# Connect magazine discharge to spray pattern
	magazine.connect("discharged", func():
		spray_pattern.get_next_offset()
	)
	
	# Fire a few shots through the magazine
	magazine.action()
	magazine.action()
	
	expect_equal(spray_pattern.current_shot_index, 2)
	expect_equal(get_signal_emissions(spray_pattern.spray_offset_updated).size(), 2)

func test_offset_accumulation() -> void:
	# Create a predictable curve for testing
	var curve = Curve2D.new()
	curve.add_point(Vector2(0.0, 0.1))
	curve.add_point(Vector2(1.0, 0.2))
	curve.add_point(Vector2(2.0, 0.3))
	
	spray_pattern.base_curve = curve
	spray_pattern.randomness_pitch = 0.0  # Disable randomness for predictable testing
	spray_pattern.randomness_yaw = 0.0
	
	var first_offset = spray_pattern.get_next_offset()
	var second_offset = spray_pattern.get_next_offset()
	
	# Offsets should accumulate
	expect_true(second_offset.length() > first_offset.length())

func test_pattern_reset_functionality() -> void:
	capture_signal(spray_pattern.pattern_reset)
	
	# Fire some shots
	spray_pattern.get_next_offset()
	spray_pattern.get_next_offset()
	expect_equal(spray_pattern.current_shot_index, 2)
	
	# Manually reset
	spray_pattern.reset_pattern()
	expect_equal(spray_pattern.current_shot_index, 0)
	expect_true(spray_pattern.is_resetting)
	expect_equal(get_signal_emissions(spray_pattern.pattern_reset).size(), 1)

func test_recovery_system() -> void:
	capture_signal(spray_pattern.spray_offset_updated)
	
	# Fire a shot to create offset
	var initial_offset = spray_pattern.get_next_offset()
	expect_not_equal(spray_pattern.current_offset, Vector2.ZERO)
	
	# Reset to start recovery
	spray_pattern.reset_pattern()
	
	# Simulate recovery over time
	for i in range(10):
		spray_pattern._physics_process(0.1)  # 100ms steps
	
	# Offset should be smaller than initial
	expect_true(spray_pattern.current_offset.length() < initial_offset.length())

func test_curve_pattern_following() -> void:
	# Create a specific pattern
	var curve = Curve2D.new()
	curve.add_point(Vector2(0.0, 0.0))   # No recoil on first shot
	curve.add_point(Vector2(1.0, 0.5))   # Medium recoil on second shot
	curve.add_point(Vector2(2.0, 1.0))   # High recoil on third shot
	
	spray_pattern.base_curve = curve
	spray_pattern.randomness_pitch = 0.0
	spray_pattern.randomness_yaw = 0.0
	spray_pattern.apply_speed = 1.0  # 1:1 mapping for predictable testing
	
	# First shot should have minimal offset
	var first = spray_pattern.get_next_offset()
	
	# Second shot should have more offset
	var second = spray_pattern.get_next_offset()
	
	# Third shot should have the most offset
	var third = spray_pattern.get_next_offset()
	
	# Verify progression (allowing for small floating point differences)
	expect_true(second.length() > first.length())
	expect_true(third.length() > second.length())