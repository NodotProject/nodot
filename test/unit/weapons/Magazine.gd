extends GutTest

var magazine: Magazine

func before_each() -> void:
    magazine = Magazine.new()
    add_child(magazine)

func after_each() -> void:
    remove_child(magazine)
    magazine.free()

func test_initial_properties() -> void:
    assert_eq(magazine.capacity, 10)
    assert_eq(magazine.supply_count, 20)
    assert_eq(magazine.discharge_count, 1)
    assert_eq(magazine.fire_rate, 0.5)
    assert_eq(magazine.reload_time, 1.0)
    assert_eq(magazine.rounds_left, 10)
    assert_true(magazine.auto_reload)

func test_action_with_charge_weapon() -> void:
    magazine.charge_weapon = true
    watch_signals(magazine)
    
    magazine.action()
    assert_signal_emitted(magazine, "charge_started")
    assert_true(magazine.is_charging)
    
    magazine.release_action()
    assert_signal_emitted(magazine, "charge_released")
    assert_signal_emitted(magazine, "discharged")
    assert_false(magazine.is_charging)

func test_action_with_auto_reload() -> void:
    magazine.rounds_left = 0
    watch_signals(magazine)
    
    magazine.action()
    assert_signal_emitted(magazine, "reloading")
    assert_eq(magazine.rounds_left, magazine.capacity)

func test_reload() -> void:
    magazine.rounds_left = 0
    magazine.supply_count = 15
    watch_signals(magazine)
    
    magazine.reload()
    assert_signal_emitted(magazine, "reloading")
    assert_eq(magazine.rounds_left, magazine.capacity)
    assert_eq(magazine.supply_count, 5)

func test_resupply() -> void:
    var rejected = magazine.resupply(50)
    assert_eq(magazine.supply_count, 70)
    assert_eq(rejected, 0)
    
    rejected = magazine.resupply(50)
    assert_eq(magazine.supply_count, magazine.supply_count_limit)
    assert_eq(rejected, 20)

func test_magazine_depleted_signal() -> void:
    magazine.rounds_left = 0
    watch_signals(magazine)
    
    magazine.action()
    assert_signal_emitted(magazine, "magazine_depleted")

func test_supply_depleted_signal() -> void:
    magazine.supply_count = 0
    watch_signals(magazine)
    
    magazine.action()
    assert_signal_emitted(magazine, "supply_depleted")
