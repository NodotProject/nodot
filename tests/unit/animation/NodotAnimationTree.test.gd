extends VestTest

var anim_tree: NodotAnimationTree

func before_case(_case):
	anim_tree = NodotAnimationTree.new()
	anim_tree.tree_root = load("tests/resources/animationtree.tres")
	anim_tree.scan_parameters()

func test_scan_parameters():
	var params = anim_tree.list_params()
	print(anim_tree._param_cache)
	expect_true(anim_tree._param_cache.keys().size() > 0)

func test_fire_oneshot():
	anim_tree.fire_oneshot("OneShot")
	var expected = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	expect_equal(anim_tree.get_param("OneShot/request"), expected, "Should fire the one-shot animation")

func test_abort_oneshot():
	anim_tree.abort_oneshot("OneShot")
	var expected = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	expect_equal(anim_tree.get_param("OneShot/request"), expected, "Should abort the one-shot animation")

func test_set_oneshot_fadetimes():
	anim_tree.set_oneshot_fadetimes("OneShot", 0.2, 0.3)
	expect_equal(anim_tree.get_blend_tree_node("OneShot").fadein_time, 0.2, "Should set the fade in time")
	expect_equal(anim_tree.get_blend_tree_node("OneShot").fadeout_time, 0.3, "Should set the fade out time")

func test_is_oneshot_active():
	anim_tree.set_param("OneShot/active", true)
	expect_true(anim_tree.is_oneshot_active("OneShot"), "Should return true when one-shot is active")
	anim_tree.set_param("OneShot/active", false)
	expect_false(anim_tree.is_oneshot_active("OneShot"), "Should return false when one-shot is not active")

func test_request_timeseek():
	anim_tree.request_timeseek("Animation", 1.5)
	expect_equal(anim_tree.get_param("Animation/seek_request"), 1.5, "Should request time seek")

func test_set_and_get_timescale():
	anim_tree.set_timescale("Animation", 2.0)
	expect_equal(anim_tree.get_timescale("Animation"), 2.0, "Should set and get time scale")

func test_set_and_get_blend_amount():
	anim_tree.set_blend_amount("BlendNode", 0.7)
	expect_equal(anim_tree.get_blend_amount("BlendNode"), 0.7, "Should set and get blend amount for Blend2/3")
	
	anim_tree.set_blend_amount("BlendSpace1D", 0.3)
	expect_equal(anim_tree.get_blend_amount("BlendSpace1D"), 0.3, "Should set and get blend amount for BlendSpace1D")

func test_set_and_get_blend_position():
	var pos = Vector2(0.2, 0.8)
	anim_tree.set_blend_position("BlendSpace2D", pos)
	expect_equal(anim_tree.get_blend_position("BlendSpace2D"), pos, "Should set and get blend position for BlendSpace2D")

func test_lerp_blend_amount():
	anim_tree.set_blend_amount("BlendNode", 0.0)
	anim_tree.lerp_blend_amount("BlendNode", 1.0, 0.5)
	expect_true(is_equal_approx(anim_tree.get_blend_amount("BlendNode"), 0.5), "Should lerp blend amount")

func test_lerp_blend_position():
	anim_tree.set_blend_position("BlendSpace2D", Vector2.ZERO)
	anim_tree.lerp_blend_position("BlendSpace2D", Vector2.ONE, 0.5)
	expect_true(anim_tree.get_blend_position("BlendSpace2D").is_equal_approx(Vector2(0.5, 0.5)), "Should lerp blend position")

func test_request_transition():
	anim_tree.request_transition("StateMachine", "my_transition")
	expect_equal(anim_tree.get_param("StateMachine/transition_request"), "my_transition", "Should request a transition")
