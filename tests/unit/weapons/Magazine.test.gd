extends VestTest

var magazine: Magazine

func before_case(_case) -> void:
	magazine = Magazine.new()

func after_case(_case) -> void:
	magazine.free()

func test_initial_properties() -> void:
	expect_equal(magazine.capacity, 10)
	expect_equal(magazine.supply_count, 20)
	expect_equal(magazine.discharge_count, 1)
	expect_equal(magazine.fire_rate, 0.5)
	expect_equal(magazine.reload_time, 1.0)
	expect_equal(magazine.rounds_left, 10)
	expect_true(magazine.auto_reload)

func test_action_with_charge_weapon() -> void:
	capture_signal(magazine.charge_started, 1)
	capture_signal(magazine.charge_released, 1)
	capture_signal(magazine.discharged)
	magazine.charge_weapon = true
	
	magazine.action()
	expect_equal(get_signal_emissions(magazine.charge_started).size(), 1, "Charge Started")
	expect_true(magazine.is_charging)
	
	magazine.release_action()
	expect_equal(get_signal_emissions(magazine.charge_released).size(), 1, "Charge Released")
	expect_equal(get_signal_emissions(magazine.discharged).size(), 1, "Discharged")
	expect_false(magazine.is_charging)

func test_action_with_auto_reload() -> void:
	capture_signal(magazine.reloading)
	magazine.rounds_left = 0
	
	magazine.action()
	expect_equal(get_signal_emissions(magazine.reloading).size(), 1)
	expect_equal(magazine.rounds_left, magazine.capacity)

func test_reload() -> void:
	capture_signal(magazine.reloading)
	magazine.rounds_left = 0
	magazine.supply_count = 15
	
	magazine.reload()
	expect_equal(get_signal_emissions(magazine.reloading).size(), 1)
	expect_equal(magazine.rounds_left, magazine.capacity)
	expect_equal(magazine.supply_count, 5)

func test_resupply() -> void:
	var rejected = magazine.resupply(50)
	expect_equal(magazine.supply_count, 70)
	expect_equal(rejected, 0)
	
	rejected = magazine.resupply(50)
	expect_equal(magazine.supply_count, magazine.supply_count_limit)
	expect_equal(rejected, 20)

func test_magazine_depleted_signal() -> void:
	capture_signal(magazine.magazine_depleted)
	magazine.rounds_left = 0
	
	magazine.action()
	expect_equal(get_signal_emissions(magazine.magazine_depleted).size(), 1)

func test_supply_depleted_signal() -> void:
	capture_signal(magazine.supply_depleted)
	magazine.supply_count = 0
	
	magazine.action()
	expect_equal(get_signal_emissions(magazine.supply_depleted).size(), 1)
