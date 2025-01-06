extends Node

var coins_per_level = {} # Динамический словарь для любого количества уровней
var current_level = 1
var total_levels = 4 # Общее количество уровней

func _ready():
	reset_progress()

func get_level_max_coins(level: int) -> int:
	var max_coins = {
		1: 15,
		2: 11,
		3: 13,
		4: 17
	}
	return max_coins.get(level, 0)

func reset_progress():
	coins_per_level.clear()
	# Инициализируем все уровни
	for level in range(1, total_levels + 1):
		coins_per_level[level] = 0
	current_level = 1

func set_current_level(level: int):
	print("Setting current level to: ", level)
	current_level = level
	if not coins_per_level.has(current_level):
		coins_per_level[current_level] = 0
	print("Current coins_per_level state: ", coins_per_level)

func add_coin():
	print("Adding coin to level: ", current_level)
	if not coins_per_level.has(current_level):
		coins_per_level[current_level] = 0
	coins_per_level[current_level] += 1
	print("Updated coins for level ", current_level, ": ", coins_per_level[current_level])
	print("Total coins_per_level state: ", coins_per_level)

func get_level_coins(level: int) -> int:
	var coins = coins_per_level.get(level, 0)
	print("Getting coins for level ", level, ": ", coins)
	return coins

func get_total_coins() -> int:
	var total = 0
	for coins in coins_per_level.values():
		total += coins
	return total


func get_max_total_coins() -> int:
	var total = 0
	for level in range(1, total_levels + 1):
		total += get_level_max_coins(level)
	return total
