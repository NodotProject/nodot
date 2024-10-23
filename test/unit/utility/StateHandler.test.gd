extends GutTest

var sh_path = load("res://addons/nodot/utility/StateHandler.gd")

var sh_double
var sh: StateHandler
var sm: StateMachine

func before_each():
	sh = StateHandler.new()
	sm = StateMachine.new()
	sm.add_child(sh)
	sh._ready()
	
	# This function runs before each test case
	sh_double = partial_double(sh_path).new()
	sh_double.sm = sm

func after_each():
	# Clean up after each test case
	sh_double = null
	sh = null
	sm = null

func test_sh_initialization():
	# Test that the StateHandler initializes with default values
	var sh = StateHandler.new()
	assert_true(sh.enabled, "StateHandler should be enabled by default.")
	assert_eq(sh.handled_states.size(), 0, "Handled states should be empty by default.")
	assert_null(sh.sm, "StateMachine should be null by default.")

func test_ready_sets_sm_when_parent_is_state_machine():
	# Ensure sm is set correctly in _ready()
	assert_eq(sh.sm, sm, "StateHandler.sm should be set to parent StateMachine.")

func test_set_state_active_calls_enter():
	# Setup handled state
	sh_double.handled_states.append("STATE_A")
	sh_double.sm.state = "STATE_A"

	# Simulate state change
	sh_double._set_state_active()
	assert_called(sh_double, "enter")

func test_set_state_active_calls_exit():
	# Setup initial active state
	sh_double.handled_states.append("STATE_A")
	sh_double.sm.state = "STATE_A"
	sh_double.state_active = true
	sh_double._old_state_active = true

	# Change to a state not handled
	sh_double.sm.state = "STATE_B"
	sh_double._set_state_active()
	assert_called(sh_double, "exit")

func test_process_calls_process_when_active():
	# Setup active state
	sh_double.handled_states.append("STATE_A")
	sh_double.sm.state = "STATE_A"
	sh_double.state_active = true

	sh_double._process(0.016)
	assert_called(sh_double, "process")

func test_process_does_not_call_process_when_inactive():
	# Setup inactive state
	sh_double.handled_states.append("STATE_A")
	sh_double.sm.state = "STATE_B"
	sh_double.state_active = false

	sh_double._process(0.016)
	assert_not_called(sh_double, "process")

func test_physics_process_calls_physics_when_active():
	# Setup active state
	sh_double.state_active = true

	sh_double._physics_process(0.016)
	assert_called(sh_double, "physics")

func test_physics_process_does_not_call_physics_when_inactive():
	# Setup inactive state
	sh_double.state_active = false

	sh_double._physics_process(0.016)
	assert_not_called(sh_double, "physics")

func test_can_enter_prevents_enter():
	# Setup to prevent entering state
	sh_double.handled_states.append("STATE_A")
	sh_double.sm.state = "STATE_A"

	sh_double._set_state_active()
	assert_not_called(sh_double, "enter")

func test_enabled_false_skips_ready():
	# Disable StateHandler
	sh_double.enabled = false

	sh_double._ready()
	assert_not_called(sh_double, "ready")

func test_enabled_false_skips_process():
	# Disable StateHandler
	sh_double.enabled = false

	sh_double._process(0.016)
	assert_not_called(sh_double, "process")
