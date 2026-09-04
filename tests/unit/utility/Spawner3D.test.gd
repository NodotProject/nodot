extends VestTest

## A template that counts how many times it was made ready, so a test can tell a
## spawned duplicate apart from the template the spawner duplicates
class ReadyProbe extends Node3D:
	static var ready_count: int = 0

	func _ready() -> void:
		ReadyProbe.ready_count += 1


var _spawners: Array[Spawner3D] = []


func before_case(_case):
	ReadyProbe.ready_count = 0


func after_case(_case):
	for spawner in _spawners:
		if is_instance_valid(spawner):
			spawner.free()
	_spawners.clear()


func test_spawns_with_the_default_spawns_left():
	var spawner := _make_spawner(1)
	spawner.spawn_all_on_start = true
	await _start(spawner)

	expect_equal(_live_spawns(spawner), 1, "Should spawn up to the limit")
	expect_equal(spawner.spawns_left, 0, "Should spend the spawn budget")


func test_stops_at_the_spawn_limit():
	var spawner := _make_spawner(2)
	await _start(spawner)

	var limit_reached := [false]
	spawner.spawn_limit_reached.connect(func(): limit_reached[0] = true)
	spawner.action()
	spawner.action()
	spawner.action()
	await _next_frame()

	expect_equal(_live_spawns(spawner), 2, "Should not spawn past the limit")
	expect_true(limit_reached[0], "Should report the limit being reached")


func test_does_not_overspawn_while_a_delayed_spawn_is_pending():
	var spawner := _make_spawner(1)
	spawner.spawn_delay = 0.4
	spawner.deletion_check_interval = 0.1
	spawner.spawn_all_on_start = true
	spawner.auto_spawn_all = true
	spawner.monitor_deletions = true
	await _start(spawner)
	await _wait(0.7)

	expect_equal(_live_spawns(spawner), 1, "Should spawn once on start")

	_free_spawns(spawner)
	await _wait(1.2)

	expect_equal(_live_spawns(spawner), 1, "Should replace a lost spawn exactly once")


func test_refunds_the_budget_when_a_spawn_is_lost():
	var spawner := _make_spawner(2)
	spawner.deletion_check_interval = 0.1
	spawner.monitor_deletions = true
	spawner.spawn_all_on_start = true
	await _start(spawner)

	var despawn_count := [0]
	spawner.despawned.connect(func(): despawn_count[0] += 1)
	_free_spawns(spawner)
	await _wait(0.4)

	expect_equal(despawn_count[0], 2, "Should report one despawn per lost spawn")
	expect_equal(spawner.spawns_left, 2, "Should refund the lost spawns")


func test_never_readies_the_template():
	var spawner := _make_spawner(2)
	spawner.spawn_all_on_start = true
	await _start(spawner)

	expect_equal(_live_spawns(spawner), 2, "Should spawn up to the limit")
	expect_equal(ReadyProbe.ready_count, 2, "Should ready the spawns but never the template")


func test_survives_having_no_template_to_spawn():
	var spawner := Spawner3D.new()
	spawner.spawn_limit = 1
	spawner.auto_spawn_all = true
	spawner.deletion_check_interval = 0.1
	_spawners.append(spawner)
	await _start(spawner)
	await _wait(0.3)

	expect_equal(_live_spawns(spawner), 0, "Should spawn nothing")


func test_frees_its_templates_with_itself():
	var spawner := _make_spawner(1)
	await _start(spawner)

	var template_id: int = spawner.saved_children[0].get_instance_id()
	spawner.free()
	await _next_frame()

	expect_false(is_instance_id_valid(template_id), "Should not leave the template orphaned")


func test_any_save_system_can_restore_deleted_spawns():
	var original := _make_spawner(4)
	original.spawn_all_on_start = true
	await _start(original)
	var deleted := original.get_children().filter(func(node): return node is Node3D).back() as Node
	deleted.queue_free()

	var state: Dictionary = original.get_spawn_state()
	var restored := _make_spawner(4)
	restored.spawn_all_on_start = true
	await _start(restored)
	restored.restore_spawn_state(state)

	expect_equal(state["spawned_count"], 3, "Should capture only living batches")
	expect_equal(_live_spawns(restored), 3, "Should restore the saved live count")
	expect_equal(restored.spawns_left, 1, "Should restore the matching budget")


func test_can_restore_state_before_ready():
	var spawner := _make_spawner(4)
	spawner.spawn_all_on_start = true
	spawner.restore_spawn_state({"spawned_count": 2})
	await _start(spawner)

	expect_equal(_live_spawns(spawner), 2, "Should prefer restored state to startup spawning")
	expect_equal(spawner.spawns_left, 2, "Should restore the matching budget")


func test_restore_cancels_delayed_startup_spawns():
	var spawner := _make_spawner(4)
	spawner.spawn_all_on_start = true
	spawner.spawn_delay = 0.3
	await _start(spawner)
	spawner.restore_spawn_state({"spawned_count": 2})
	await _wait(0.5)

	expect_equal(_live_spawns(spawner), 2, "Should not append stale delayed spawns")
	expect_equal(spawner.spawns_left, 2, "Should keep the restored budget")


func test_persistent_deletions_override_auto_respawn():
	var spawner := _make_spawner(2)
	spawner.spawn_all_on_start = true
	spawner.auto_spawn_all = true
	spawner.persist_deletions = true
	spawner.deletion_check_interval = 0.1
	await _start(spawner)
	var deleted := spawner.get_children().filter(func(node): return node is Node3D).back() as Node
	deleted.queue_free()
	await _wait(0.3)

	expect_equal(_live_spawns(spawner), 1, "Should leave a persistent deletion empty")
	expect_equal(spawner.spawns_left, 1, "Should refund the deleted spawn")


func test_saver_is_an_optional_adapter():
	var original := _make_spawner(2)
	original.spawn_all_on_start = true
	original.persist_deletions = true
	var original_saver := Saver.new()
	original.add_child(original_saver)
	await _start(original)
	var deleted := original.get_children().filter(func(node): return node is Node3D).back() as Node
	deleted.queue_free()
	var saved_data: Dictionary = original_saver.save()

	var restored := _make_spawner(2)
	restored.spawn_all_on_start = true
	restored.persist_deletions = true
	var restored_saver := Saver.new()
	restored.add_child(restored_saver)
	await _start(restored)
	restored_saver.load(saved_data)

	expect_equal(_live_spawns(restored), 1, "Should restore through Nodot's Saver")


func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


func _make_spawner(spawn_limit: int) -> Spawner3D:
	var spawner := Spawner3D.new()
	spawner.spawn_limit = spawn_limit
	var template := ReadyProbe.new()
	template.name = "Template"
	spawner.add_child(template)
	_spawners.append(spawner)
	return spawner


func _start(spawner: Spawner3D) -> void:
	_tree().root.add_child(spawner)
	await _next_frame()


func _next_frame() -> void:
	await _tree().process_frame


func _wait(seconds: float) -> void:
	await _tree().create_timer(seconds).timeout


func _free_spawns(spawner: Spawner3D) -> void:
	for child in spawner.get_children():
		if child is Node3D:
			child.queue_free()


func _live_spawns(spawner: Spawner3D) -> int:
	var count := 0
	for child in spawner.get_children():
		if child is Node3D and !child.is_queued_for_deletion():
			count += 1
	return count
